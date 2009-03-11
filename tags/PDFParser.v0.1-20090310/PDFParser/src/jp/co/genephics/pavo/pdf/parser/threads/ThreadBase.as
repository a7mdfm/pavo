/*

PDFParser - project pavo(http://code.google.com/p/pavo/)

Licensed under the MIT License

Copyright (c) 2009 genephics design, Inc.(http://www.genephics.co.jp/)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル（以下「ソフトウェ
ア」）の複製を取得するすべての人に対し、ソフトウェアを無制限に扱うことを無償で
許可します。これには、ソフトウェアの複製を使用、複写、変更、結合、掲載、頒布、
サブライセンス、および/または販売する権利、およびソフトウェアを提供する相手に
同じことを許可する権利も無制限に含まれます。

上記の著作権表示および本許諾表示を、ソフトウェアのすべての複製または重要な部分に
記載するものとします。

ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証も
なく提供されます。ここでいう保証とは、商品性、特定の目的への適合性、および権利非
侵害についての保証も含みますが、それに限定されるものではありません。
作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、ソフトウェア
に起因または関連し、あるいはソフトウェアの使用またはその他の扱いによって生じる
一切の請求、損害、その他の義務について何らの責任も負わないものとします。 

*/

package jp.co.genephics.pavo.pdf.parser.threads
{
	import jp.co.genephics.pavo.pdf.parser.constants.Status;
	import jp.co.genephics.pavo.pdf.parser.events.PDFEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserFaultEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserProgressEvent;
	import jp.co.genephics.pavo.pdf.parser.threads.utils.ThreadUtil;
	
	import org.libspark.thread.Thread;

	/**
	 * 基底Threadクラス
	 * 
	 * @author genephics design, Inc.
	 */
	public class ThreadBase extends Thread
	{
		/**
		 * 現在のステータス
		 */
		protected var __status:Status = Status.STATUS_INIT;

		/**
		 * PDFEventDispatcherインスタンス(シングルトン)
		 */
		protected var __pdfEventDispatcher:PDFEventDispatcher;
		
		/**
		 * コンストラクタ。
		 * 
		 */
		public function ThreadBase()
		{
			super();
			__pdfEventDispatcher = PDFEventDispatcher.instance;
		}
		
		/**
		 * 任意のタイミングでプログレスイベントをディスパッチします。
		 * 
		 * @param ステータス
		 * @param メッセージ
		 */
		protected function __progress(status:Status, option:String=""):void
		{
			__status = status;
			var event:PDFParserProgressEvent = new PDFParserProgressEvent(PDFParserProgressEvent.PROGRESS);
			event.status = status.status;
			event.message = status.message + option;
			__pdfEventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * キャンセルかどうかを判断しnext()引数の関数を決定します
		 * 
		 * @param 次に実行させる関数
		 */
		protected function __next(nextFunc:Function):void
		{
			if (ThreadUtil.isCanceled())
			{
				next(__cancel);
			}
			else
			{
				next(nextFunc);
			}
		}
		
		/**
		 * PDFEventDispatcher に PDFParserEvent.CANCELED イベントをディスパッチさせます
		 */
		protected function __cancel():void
		{
			var event:PDFParserEvent = new PDFParserEvent(PDFParserEvent.CANCELED);
			__pdfEventDispatcher.dispatchEvent(event);
		}
		
		/**
		 * 次のタイミングで__fault()を実行します
		 */
		protected function __errorHandler(error:Error, thread:Thread):void
		{
			next(__fault);
		}

		/**
		 * PDFEventDispatcher に PDFParserFaultEvent.FAULT イベントをディスパッチさせます
		 */
		protected function __fault():void
		{
			var event:PDFParserFaultEvent = new PDFParserFaultEvent(PDFParserFaultEvent.FAULT);
			
			event.faultMessage = __status.message + " でエラーが発生しました";
			__pdfEventDispatcher.dispatchEvent(event);
		}
	}
}