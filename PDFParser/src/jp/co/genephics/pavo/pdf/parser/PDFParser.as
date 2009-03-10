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

package jp.co.genephics.pavo.pdf.parser
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import jp.co.genephics.pavo.pdf.parser.events.PDFEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserFaultEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserProgressEvent;
	import jp.co.genephics.pavo.pdf.parser.threads.PDFParserThread;
	import jp.co.genephics.pavo.pdf.parser.threads.utils.ThreadUtil;
	
	import org.libspark.thread.EnterFrameThreadExecutor;
	import org.libspark.thread.Thread;
	
	[Event(name="complete", type="jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent")]
	[Event(name="progress", type="jp.co.genephics.pavo.pdf.parser.events.PDFParserProgressEvent")]
	[Event(name="cancel", type="jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent")]
	[Event(name="fault", type="jp.co.genephics.pavo.pdf.parser.events.PDFParserFaultEvent")]
	
	/**
	 * PDFParser
	 * 
	 * @author genephics design, Inc.
	 */
	public class PDFParser extends EventDispatcher
	{
		
		protected var __pdfEventDispathcer:PDFEventDispatcher;
		
		/**
		 * コンストラクタ
		 */
		public function PDFParser(target:IEventDispatcher = null)
		{
			super(target);
			Thread.initialize(new EnterFrameThreadExecutor());
			__pdfEventDispathcer = PDFEventDispatcher.instance;
		}
		
		/**
		 * @private
		 */
		protected var __thread:PDFParserThread;
		
		// ---------------------------------------------------------------
		//  filePath
		// ---------------------------------------------------------------
		
		private var _filePath:String;
		public function set filePath(value:String):void
		{
			_filePath = value;
		}
		public function get filePath():String
		{
			return _filePath;
		}
		
		/**
		 * filePathで指定したPDFファイルを非同期で解析します。
		 * 
		 */
		public function asyncParse():void
		{
			__pdfEventDispathcer.addEventListener(PDFParserProgressEvent.PROGRESS, __progressHandler);
			__pdfEventDispathcer.addEventListener(PDFParserFaultEvent.FAULT, __faultHandler);
			__pdfEventDispathcer.addEventListener(PDFParserEvent.CANCELED, __cancelHandler);
			__thread = new PDFParserThread(filePath);
			__thread.addEventListener(PDFParserEvent.COMPLETE, __completeHandler);
			__thread.start();
		}
		
		/**
		 * PDFの解析をキャンセルします。
		 * 
		 */
		public function cancel():void
		{
			ThreadUtil.status = ThreadUtil.STATUS_CANCEL;
		}
		
		/**
		 * progress イベントハンドラー<br />
		 * PDFParserProgressEvent.PROGRESSイベントをこのクラスから再ディスパッチします。
		 * 
		 */
		protected function __progressHandler(event:PDFParserProgressEvent):void
		{
			var newEvent:PDFParserProgressEvent = new PDFParserProgressEvent(PDFParserProgressEvent.PROGRESS);
			newEvent.status = event.status;
			newEvent.message = event.message;
			dispatchEvent(newEvent);
		}
		
		/**
		 * complete イベントハンドラー<br />
		 * PDFParserEvent.COMPLETEイベントをこのクラスから再ディスパッチします。
		 * 
		 */
		protected function __completeHandler(event:PDFParserEvent):void
		{
			__removeEventListeners();
			
			var newEvent:PDFParserEvent = new PDFParserEvent(PDFParserEvent.COMPLETE);
			newEvent.pdfDocument = event.pdfDocument;
			dispatchEvent(newEvent);
		}
		
		/**
		 * fault イベントハンドラー<br />
		 * PDFParserFaultEvent.FAULTイベントをこのクラスから再ディスパッチします。
		 * 
		 */
		protected function __faultHandler(event:PDFParserFaultEvent):void
		{
			__removeEventListeners();
			var newEvent:PDFParserFaultEvent = new PDFParserFaultEvent(PDFParserFaultEvent.FAULT);
			newEvent.faultMessage = event.faultMessage;
			dispatchEvent(newEvent);
		}
		
		/**
		 * cancel イベントハンドラー<br />
		 * PDFParserEvent.CANCELEDイベントをこのクラスから再ディスパッチします。
		 * 
		 */
		protected function __cancelHandler(event:PDFParserEvent):void
		{
			__removeEventListeners();
			var newEvent:PDFParserEvent = new PDFParserEvent(PDFParserEvent.CANCELED);
			dispatchEvent(newEvent);
		}
		
		/**
		 * イベントリスナーを削除します。
		 * 
		 */
		protected function __removeEventListeners():void
		{
			__pdfEventDispathcer.removeEventListener(PDFParserProgressEvent.PROGRESS, __progressHandler);
			__pdfEventDispathcer.removeEventListener(PDFParserFaultEvent.FAULT, __faultHandler);
			__pdfEventDispathcer.removeEventListener(PDFParserEvent.CANCELED, __cancelHandler);
			__thread.addEventListener(PDFParserEvent.COMPLETE, __completeHandler);
			ThreadUtil.status = ThreadUtil.STATUS_DEFAULT;
		}
	}
}