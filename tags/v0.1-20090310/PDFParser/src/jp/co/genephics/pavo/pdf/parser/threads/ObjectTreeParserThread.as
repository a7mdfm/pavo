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
	import flash.utils.Dictionary;
	
	import jp.co.genephics.events.MixInEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.constants.Status;
	import jp.co.genephics.pavo.pdf.parser.events.NamedDestEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserProgressEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PagesParserEvent;
	import jp.co.genephics.pavo.pdf.parser.models.Action;
	import jp.co.genephics.pavo.pdf.parser.models.Dests;
	import jp.co.genephics.pavo.pdf.parser.models.Outline;
	import jp.co.genephics.pavo.pdf.parser.models.PDFDocument;
	import jp.co.genephics.pavo.pdf.parser.models.Page;
	import jp.co.genephics.pavo.pdf.parser.models.Root;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.objectParsers.ActionParser;
	import jp.co.genephics.pavo.pdf.parser.parsers.objectParsers.NamedDestTreeParser;
	import jp.co.genephics.pavo.pdf.parser.parsers.objectParsers.OutlineParser;
	import jp.co.genephics.pavo.pdf.parser.parsers.objectParsers.PagesParser;
	import jp.co.genephics.pavo.pdf.parser.utils.DestinationUtil;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;

	[Event(name="complete", type="jp.co.genephics.pavo.pdf.parser.events.PDFParserEvent")]
	
	/**
	 * PDF文書のツリー構造的Object情報を順に解析する。<br />
	 * （PDF文書のバイト配列から、XREFテーブル情報とTrailer情報を頼りにPDFボディ部分（オブジェクト集合）を解析する。）
	 * 
	 * @author genephics design Inc. 
	 */
	public dynamic class ObjectTreeParserThread extends ThreadBase
	{
		
		private var _target:ByteArray;

		private var _pdfDocument:PDFDocument;
		
		private var _xrefList:Array;
		private var _catalog:Root;
		
		private var _namedDestTree:Dests;
		private var _page:Object;
		
		private var _outlineParser:OutlineParser;
		private var _actionParser:ActionParser;
		private var _pagesParser:PagesParser;
		private var _dic:Dictionary;
		private var _namedDestTreeParser:NamedDestTreeParser;
		private var _namedDestLineUpThread:NamedDestLineUpThread;
		private var _pagesParserThread:PagesParserThread;

		protected var __eventDispatcher:PDFEventDispatcher;
		
		/**
		 * コンストラクタ
		 */
		public function ObjectTreeParserThread(target:ByteArray, pdfDocument:PDFDocument)
		{
			super();
			__eventDispatcher = PDFEventDispatcher.instance;
			MixInEventDispatcher.initialize(this);
			
			_target = target;
			_pdfDocument = pdfDocument;
			_catalog = pdfDocument.catalog;
			_xrefList = pdfDocument.footer.xrefList;
			
			_pdfDocument.outlines = [];
			_pdfDocument.pageList = [];
			
			_outlineParser = new OutlineParser(_target);
			_actionParser = new ActionParser(_target);
			_pagesParser = new PagesParser(_target);
		}
		
		override protected function run():void
		{
			// 名前付き飛び先が定義されていなければ、Pageツリーの解析を行う
			if (_catalog.names)
			{
				__next(_parseNamedDestination);
			}
			else
			{
				__next(_parsePagesList);
			}
		}
		
		private function _parseNamedDestination():void
		{
			__progress(Status.STATUS_ANALYZE_NAMED_DEST);
			error(Error, __errorHandler);
			
			// NamedDestinationマップの作成
			var namesXRef:XRef = ParserUtil.findByObjectId(_xrefList, _catalog.names);
			_namedDestTreeParser = new NamedDestTreeParser(_target);
			_namedDestTreeParser.addEventListener(NamedDestEvent.COMPLETE, _namedDestCompleteHandler);
			_namedDestTreeParser.parse(_xrefList, namesXRef);
		}

		private function _namedDestCompleteHandler(event:NamedDestEvent):void
		{
			event.currentTarget.removeEventListener(NamedDestEvent.COMPLETE, _namedDestCompleteHandler);

			_namedDestTree = event.dests;
			__next(_parseNamesDictionaries);
		}
		
		private function _parseNamesDictionaries():void
		{
			__progress(Status.STATUS_CREATE_NAMED_DEST_MAP);
			error(Error, __errorHandler);
			
			// namedDictionaryをパース
			_dic = new Dictionary();
			_namedDestLineUpThread = new NamedDestLineUpThread(_target, _xrefList, _namedDestTree, _dic);
			_namedDestLineUpThread.addEventListener(NamedDestEvent.LINE_UP_COMPLETE, _namedDestLineUpCompleteHandler);
			_namedDestLineUpThread.start();
		}

		private function _namedDestLineUpCompleteHandler(event:NamedDestEvent):void
		{
			event.currentTarget.removeEventListener(NamedDestEvent.LINE_UP_COMPLETE, _namedDestLineUpCompleteHandler);

			_pdfDocument.namedDestDictionary = event.lineUppedDic;

			__next(_parsePagesList);
		}
		
		private function _parsePagesList():void
		{
			__progress(Status.STATUS_ANALYZE_PAGE_TREE);
			error(Error, __errorHandler);
			
			// Pages を取得
			var pagesXRef:XRef = ParserUtil.findByObjectId(_xrefList, _catalog.pages);

			if (pagesXRef == null)
			{
				throw new Error();
				return;
			}
			
			_pagesParserThread = new PagesParserThread(_target, _xrefList, pagesXRef, []);
			_pagesParserThread.addEventListener(PagesParserEvent.COMPLETE, _pagesParserCompleteHandler);
			_pagesParserThread.start();
		
		}
		
		private function _pagesParserCompleteHandler(event:PagesParserEvent):void
		{
			_pagesParserThread.removeEventListener(PagesParserEvent.COMPLETE, _pagesParserCompleteHandler);
			_pdfDocument.pageList = event.pageList;

			__next(_parseOutlineList);
		}
		
		private function _parseOutlineList():void
		{
			__progress(Status.STATUS_ANALYZE_OUTLINE_TREE);
			error(Error, __errorHandler);
			
			// Outline を取得
			var outlineXRef:XRef = ParserUtil.findByObjectId(_xrefList, _catalog.outlines);
			if (outlineXRef != null)
			{
				_pdfDocument.outlines = _parseOutlines(outlineXRef, _pdfDocument.namedDestDictionary);
			}
			
			__next(_parseResources);
		}
		
		private function _parseResources():void
		{
			__progress(Status.STATUS_ANALYZE_RESOURCE);
			error(Error, __errorHandler);
			
			var resourceParserThread:ResourceParserThread = new ResourceParserThread(_target, _xrefList, _pdfDocument.pageList);
			resourceParserThread.start();
			resourceParserThread.join();
			
			__next(_parseContents);
		}
		
		private function _parseContents():void
		{
			__progress(Status.STATUS_ANALYZE_CONTENTS);

			var contentsParserThread:ContentsParserThread = new ContentsParserThread(_target, _xrefList, _pdfDocument.pageList);
			contentsParserThread.start();
			contentsParserThread.join();

			__next(_verify);
		}
		
		private function _verify():void
		{
			var event:PDFParserEvent = new PDFParserEvent(PDFParserEvent.COMPLETE);
			event.pdfDocument = _pdfDocument;
			this.dispatchEvent(event);
		}
		
		private function _parseOutlines(outlineXRef:XRef, namesDictionary:Dictionary):Array
		{
			var outlineList:Array = new Array();

			while(1)
			{
				// アウトライン分析
				var parsedOutline:Outline = _outlineParser.parse(outlineXRef);
				if (parsedOutline.dest && parsedOutline.dest != "undefined" && parsedOutline.a == null)
				{
					// destElement 0番目はPageオブジェクトID, 1番目はX座標, 2番目はY座標, 3番目はZ座標, 4番目は対象のXREF
					parsedOutline.destElement = namesDictionary[parsedOutline.dest];
					parsedOutline.destElement.objectXRef = ParserUtil.findByObjectId(_xrefList, parsedOutline.destElement.objectId);
				}
				else if (parsedOutline.a)
				{
					var actionXRef:XRef = ParserUtil.findByObjectId(_xrefList, parsedOutline.a);
					var parsedAction:Action = _actionParser.parse(actionXRef);
					if (parsedAction.s == "/GoTo" && parsedAction.d)
					{
						parsedOutline.destElement = DestinationUtil.devideDestinationValue(parsedAction.d);
						parsedOutline.destElement.objectXRef = ParserUtil.findByObjectId(_xrefList, parsedOutline.destElement.objectId);
					}
				}
				
				// 子供のアウトライン分析
				if (parsedOutline.first)
				{
					var childXref:XRef = ParserUtil.findByObjectId(_xrefList, parsedOutline.first);

					// 再帰
					parsedOutline.childList = _parseOutlines(childXref, namesDictionary);
				}
				
				// PageとOutlineを対応付け
				if (parsedOutline.destElement)
				{
					toOutlineSetOfPage(parsedOutline);
				}

				// 配列へ格納
				outlineList.push(parsedOutline);
				
				if(!parsedOutline.next)
				{
					// 同じ階層のアウトラインがなければ、抜ける
					break;
				}
				else
				{
					outlineXRef = ParserUtil.findByObjectId(_xrefList, parsedOutline.next);
				}
			}
			
			return outlineList;
		}

		private function toOutlineSetOfPage(outline:Outline):void
		{
			for each (var page:Page in _pdfDocument.pageList)
			{
				if (page.objectID == Number(outline.destElement.objectXRef.objectID))
				{
					page.outlines.push(outline);
					break;
				}
			}
		}
	}
}