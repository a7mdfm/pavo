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
	
	import jp.co.genephics.pavo.pdf.parser.constants.Status;
	import jp.co.genephics.pavo.pdf.parser.events.PDFEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.models.Page;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.objectParsers.ResourcesParser;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;

	/**
	 * /Resources が指すオブジェクトを解析します。Threadクラスです。
	 * 
	 * @author genephics design, Inc.
	 */
	public class ResourceParserThread extends ThreadBase
	{
		protected var __progressEventDispatcher:PDFEventDispatcher;

		private var _target:ByteArray;
		private var _xrefList:Array;
		private var _pageList:Array;
		private var _counter:int = 0;
		
		/**
		 * コンストラクタ
		 */
		public function ResourceParserThread(target:ByteArray, xrefList:Array, pageList:Array)
		{
			super();
			_target = target;
			_xrefList = xrefList;
			_pageList = pageList;
		}
		
		/**
		 * Resourceオブジェクトを再帰的に解析します。
		 * 
		 */
		override protected function run():void
		{
			__progress(Status.STATUS_ANALYZE_RESOURCE, "(" + (_counter+1) +"/" + _pageList.length +")");
			error(Error, __errorHandler);
			
			var page:Page = _pageList[_counter];

			var myPattern:RegExp = /^([0-9]+)\s([0-9]+)\s([a-zA-Z]+)$/ig;
			var result:Object = myPattern.exec(page.resources);

			/*
			   Resourceの情報は2パターンに存在する為、処理方法を分ける
			   ・パターン1(オブジェクトIDが格納されている) --> 11120 0 R
			   ・パターン2(データがそのまま格納されている) --> <</Font<</F1 5 0 R/F2 7 0 R>>/ProcSet[/PDF/Text/ImageB/ImageC/ImageI] >>
			*/

			var parser:ResourcesParser = new ResourcesParser(_xrefList, _target);
			if (result != null)
			{
				var resourcesXref:XRef = ParserUtil.findByObjectId(_xrefList, page.resources);
				page.resource = parser.parse(resourcesXref);
			}
			else
			{
				page.resource = parser.parseFromString(page.resources);
			}
			
			_counter++;
			
			if (_counter < _pageList.length)
			{
				__next(run);
			}
		}
	}
}