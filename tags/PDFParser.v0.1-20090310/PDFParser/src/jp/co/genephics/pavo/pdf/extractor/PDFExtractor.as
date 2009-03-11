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

package jp.co.genephics.pavo.pdf.extractor
{
	import __AS3__.vec.Vector;
	
	import flash.events.IEventDispatcher;
	
	import jp.co.genephics.pavo.pdf.extractor.events.PDFExtractorEvent;
	import jp.co.genephics.pavo.pdf.extractor.models.PDFFileEntity;
	import jp.co.genephics.pavo.pdf.extractor.models.PDFOutlineEntity;
	import jp.co.genephics.pavo.pdf.extractor.threads.OutlineDeviderThread;
	import jp.co.genephics.pavo.pdf.parser.PDFParser;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent;
	import jp.co.genephics.pavo.pdf.parser.threads.utils.ThreadUtil;
	
	[Event(name="complete", type="jp.co.genephics.pavo.pdf.parser.events.ADBPDFParserEvent")]

	/**
	 * PDFExtractor
	 * Outline単位で文字列を取得します
	 * 
	 * @author genephics design, Inc.
	 */
	public class PDFExtractor extends PDFParser
	{
		/**
		 * @private
		 */
		private var _adbEvent:PDFExtractorEvent;
		
		/**
		 * @private
		 */
		private var _outlineDeviderThread:OutlineDeviderThread;
		
		/**
		 * コンストラクタ。
		 * 
		 */
		public function PDFExtractor(target:IEventDispatcher = null)
		{
			super(target);
		}
		
		/**
		 * complete イベントハンドラー<br />
		 * イベントのpdfDocumentプロパティのPDFデータからアウトライン(しおり)単位でユニコード文字列を取り出します。
		 * 
		 */
		override protected function __completeHandler(event:PDFParserEvent):void
		{
			
			_adbEvent = new PDFExtractorEvent(PDFExtractorEvent.COMPLETE);
			_adbEvent.pdfDocument = event.pdfDocument;
			
			// ファイル情報の生成
			var pdfFileEntity:PDFFileEntity = new PDFFileEntity();

			pdfFileEntity.title = event.pdfDocument.information.title;
			pdfFileEntity.last_modified = event.pdfDocument.information.modDate;

			pdfFileEntity.file_size = event.pdfDocument.fileInformation.size;	//KB
			pdfFileEntity.path = event.pdfDocument.fileInformation.path;
			pdfFileEntity.file_name = event.pdfDocument.fileInformation.fileName;
			
			_adbEvent.pdfFileEntity = pdfFileEntity;
			
			_adbEvent.sectionArray = new Vector.<PDFOutlineEntity>();
			_outlineDeviderThread = new OutlineDeviderThread(_adbEvent.sectionArray,event.pdfDocument.pageList);
			_outlineDeviderThread.start();
			_outlineDeviderThread.addEventListener(PDFExtractorEvent.COMPLETE, _outlineCompleteHandler);
			_outlineDeviderThread.join();
			
		}
		
		/**
		 * @private
		 * アウトライン(しおり)単位でのユニコード文字列取得完了イベントをディスパッチします。
		 */
		private function _outlineCompleteHandler(event:PDFExtractorEvent):void
		{
			dispatchEvent(_adbEvent);
			removeEventListener(PDFExtractorEvent.COMPLETE, _outlineCompleteHandler);
		}

		/**
		 * イベントリスナーを削除します。
		 * 
		 */
		override protected function __removeEventListeners():void
		{
			if (_outlineDeviderThread)
			{
				_outlineDeviderThread.removeEventListener(PDFExtractorEvent.COMPLETE, _outlineCompleteHandler);
			}
			super.__removeEventListeners();
		}

	}
}