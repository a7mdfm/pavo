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
	import flash.utils.ByteArray;
	
	import jp.co.genephics.events.MixInEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.constants.Status;
	import jp.co.genephics.pavo.pdf.parser.events.PagesParserEvent;
	import jp.co.genephics.pavo.pdf.parser.models.Page;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.objectParsers.PagesParser;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;
	
	import org.libspark.thread.utils.SerialExecutor;

	/**
	 * 
	 * @author genephics design, Inc.
	 */
	public dynamic class PagesParserThread extends ThreadBase
	{
		
		private var _target:ByteArray;
		private var _pagesXRef:XRef;
		private var _pageList:Array;
		private var _xrefList:Array;
		
		/**
		 * コンストラクタ
		 */
		public function PagesParserThread(target:ByteArray, xrefList:Array, pagesXRef:XRef, pageList:Array)
		{
			super();
			MixInEventDispatcher.initialize(this);
			__status = Status.STATUS_ANALYZE_PAGE_TREE;
			_target = target;
			_pagesXRef = pagesXRef;
			_pageList = pageList;
			_xrefList = xrefList;
		}
		
		override protected function run():void
		{
			error(Error, __errorHandler);
			
			// 分析
			var parser:PagesParser = new PagesParser(_target);
			var parsedPage:Object = parser.parse(_pagesXRef);
			
			if (!parsedPage)
			{
				throw new Error();
			}
			if (parsedPage is Page)
			{
				_pageList.push(parsedPage);
			}
			
			// 子供の分析
			if (parsedPage.hasOwnProperty("kids") && parsedPage.kids)
			{
				var kidsStringList:Array = _devideKids(parsedPage.kids);
				
				var serial:SerialExecutor = new SerialExecutor();

				for (var i:int=0; i< kidsStringList.length; i++)
				{
					// kids を分解してkidsの数だけ再帰
					var childXref:XRef = ParserUtil.findByObjectId(_xrefList, kidsStringList[i]);
					
					serial.addThread(new PagesParserThread(_target, _xrefList, childXref, _pageList));
				}
				serial.start();
				serial.join();
			}

			__next(_loadComplete);
		}

		private function _devideKids(kids:String):Array
		{
			var devidedArray:Array = [];
			
			var myPattern:RegExp = /\S+\s\S+\sR/ig;
			var result:Object = myPattern.exec(kids);
			
			while (result != null) {
				devidedArray.push(result[0]);
				result = myPattern.exec(kids);
			}
			
			return devidedArray;
		}

		private function _loadComplete():void
		{
			var event:PagesParserEvent = new PagesParserEvent(PagesParserEvent.COMPLETE);
			event.pageList = _pageList;
			this.dispatchEvent(event);
		}
	}
}