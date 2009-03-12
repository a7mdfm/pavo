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

package jp.co.genephics.pavo.pdf.extractor.threads
{
	import __AS3__.vec.Vector;
	
	import jp.co.genephics.events.MixInEventDispatcher;
	import jp.co.genephics.pavo.pdf.extractor.events.PDFExtractorEvent;
	import jp.co.genephics.pavo.pdf.extractor.models.PDFOutlineEntity;
	import jp.co.genephics.pavo.pdf.parser.constants.Status;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserProgressEvent;
	import jp.co.genephics.pavo.pdf.parser.models.Outline;
	import jp.co.genephics.pavo.pdf.parser.models.Page;
	import jp.co.genephics.pavo.pdf.parser.threads.ThreadBase;

	/**
	 * アウトラインの位置を基準にPDF文書情報を区切ります。
	 * 
	 * @author genephics design, Inc.
	 */
	public dynamic class OutlineDeviderThread extends ThreadBase
	{
		private var _sectionArray:Vector.<PDFOutlineEntity>;
		private var _pageList:Array;
		private var _pageLength:int;
		private var _pageCounter:int;
		private var _section:PDFOutlineEntity;
		
		/**
		 * コンストラクタ
		 */
		public function OutlineDeviderThread(sectionArray:Vector.<PDFOutlineEntity>, pageList:Array)
		{
			super();
			__progress(Status.STATUS_CONVERT_CHARCODE);

			MixInEventDispatcher.initialize(this);
			_sectionArray = sectionArray;
			_pageList = pageList;
			_pageLength = _pageList.length;
			
			_pageCounter = 0;
			_section = new PDFOutlineEntity();
			_section.page = 1;
			_section.body = "";
			_sectionArray.push(_section);
		}
		
		/**
		 * スレッド実行関数。すべてのページを処理するまで再帰的に実行されます。
		 */
		override protected function run():void
		{
			__progress(Status.STATUS_CONVERT_CHARCODE, "(" + (_pageCounter+1) +"/" + _pageLength +")");
			error(Error, __errorHandler);
			
			var page:Page = _pageList[_pageCounter] as Page;
			page.outlines.sort(_outlinesSortFunction);
			
			// ContentsTextループ
			var contentsTextBuilderThread:ContentsTextBuilderThread = new ContentsTextBuilderThread(_sectionArray, page, _pageCounter);
			contentsTextBuilderThread.start();
			contentsTextBuilderThread.join();
			
			_pageCounter++;
			
			if (_pageCounter < _pageLength)
			{
				__next(run);
			}
			else
			{
				__next(_complete);
			}
		}
		
		/**
		 * @private
		 */
		private function _complete():void
		{
			this.dispatchEvent(new PDFExtractorEvent(PDFExtractorEvent.COMPLETE));
		}

		/**
		 * @private
		 */
		private function _outlinesSortFunction(x:Outline, y:Outline):Number
		{
			if (x.destElement.top > y.destElement.top) return -1;
			if (x.destElement.top < y.destElement.top) return 1;
			return 0;
		}

	}
}