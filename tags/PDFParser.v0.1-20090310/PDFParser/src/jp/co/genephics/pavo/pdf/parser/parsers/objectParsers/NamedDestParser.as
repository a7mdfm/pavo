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

package jp.co.genephics.pavo.pdf.parser.parsers.objectParsers
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import jp.co.genephics.events.MixInEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.events.NamedDestEvent;
	import jp.co.genephics.pavo.pdf.parser.events.PDFEventDispatcher;
	import jp.co.genephics.pavo.pdf.parser.events.PDFParserFaultEvent;
	import jp.co.genephics.pavo.pdf.parser.models.Dests;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.DictionaryParser;
	import jp.co.genephics.pavo.pdf.parser.threads.ThreadBase;
	import jp.co.genephics.pavo.pdf.parser.threads.utils.ThreadUtil;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;
	
	import org.libspark.thread.utils.SerialExecutor;
	
	/**
	 * NamedDestParserクラス
	 * 
	 * @author gd, Inc.
	 */
	public dynamic class NamedDestParser extends ThreadBase
	{
		private var _target:ByteArray;
		private var _destsXRef:XRef;
		private var _tree:Dests;
		private var _xrefList:Array;
		
		private var _dictionaryParser:DictionaryParser;

		private var _kidsRegExp:RegExp = /\S+\s\S+\sR/ig;
		private var _namesRegExp:RegExp = /\((.+?)\)(.+?R)/g;
		
		/**
		 * コンストラクタ
		 * 
		 * @param tree Dests
		 * @param target ByteArray
		 * @param xrefList Array
		 * @param destsXRef XRef
		 */
		public function NamedDestParser(tree:Dests, target:ByteArray, xrefList:Array, destsXRef:XRef)
		{
			MixInEventDispatcher.initialize(this);
			_target = target;
			_destsXRef = destsXRef;
			_xrefList = xrefList;
			_tree = tree;
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function run():void
		{
			// DictionaryParser			
			_dictionaryParser = new DictionaryParser("Dests", _target);

			// Dests ツリー作成			
			_createDestsTree(_tree, _destsXRef);
			__next(_loadComplete);
		}

		/**
		 * Destsツリー作成ファンクション
		 * 
		 * <p>子が存在するときは内部でNamedDestParserを生成し、SerialExecutorで実行します</p>
		 * 
		 * @param $dest Dest
		 * @param $destsXref XRef
		 */
		private function _createDestsTree($dests:Dests, $destsXRef:XRef):Dests
		{
			_setDestsData($dests, $destsXRef);
			
			if ($dests.hasOwnProperty("kids") && $dests.kids)
			{
				var kids:Array = _devideKids($dests.kids);
				var serial:SerialExecutor = new SerialExecutor();
				
				for (var i:int = 0; i < kids.length; i++)
				{
					$dests.childList[i] = new Dests();
					var xRef:XRef = ParserUtil.findByObjectId(_xrefList, kids[i]);
					serial.addThread(new NamedDestParser($dests.childList[i], _target, _xrefList, xRef));
				}
				serial.start();
				serial.join();
			}
			
			return $dests;
		}

// 一気に処理を行う場合（内部でスレッドを使用しない）
//		private function _createDestsTree($dests:Dests, $destsXRef:XRef):Dests
//		{
//			_setDestsData($dests, $destsXRef);
//			
//			if ($dests.hasOwnProperty("kids") && $dests.kids)
//			{
//				var kids:Array = _devideKids($dests.kids);
//				
//				for (var i:int = 0; i < kids.length; i++)
//				{
//					$dests.childList[i] = new Dests();
//					var xRef:XRef = ParserUtil.findByObjectId(_xrefList, kids[i]);
//					_createDestsTree($dests.childList[i], xRef);
//				}
//			}
//			
//			return $dests;
//		}
		
		/**
		 * Dests作成ファンクション
		 * 
		 * <p>パラメータで与えられた値から、Destsデータを作成します</p>
		 * 
		 * @param $dest Dest
		 * @param $destsXref XRef
		 */
		private function _setDestsData($dests:Dests, $destsXRef:XRef):Dests
		{
			var destsObject:Array = _dictionaryParser.extract($destsXRef.index);
			
			$dests.generationNumber = $destsXRef.generationNumber;
			$dests.objectID = $destsXRef.objectID;
			$dests.inUse = $destsXRef.inUse;
			$dests.index = $destsXRef.index;

			$dests.kids = destsObject[1]["/Kids"];
			$dests.limits = destsObject[1]["/Limits"];
			$dests.names = destsObject[1]["/Names"];
			$dests.namesDictionary = _devideNames($dests.names);
			
			return $dests;
		}
		
		/**
		 * スレッド完了ファンクション
		 * 
		 * <p>NamedDestParserスレッド完了イベントを発送します</p>
		 */
		private function _loadComplete():void
		{
			var event:NamedDestEvent = new NamedDestEvent(NamedDestEvent.COMPLETE);
			event.dests = _tree;
			this.dispatchEvent(event);
		}
		
		/**
		 * kids分割ファンクション
		 * 
		 * <p>Dests内kids文字列からkidsリストを作成します</p>
		 * 
		 * @param kids String Dests内kids文字列
		 * @return Array kidsリスト
		 */
		private function _devideKids(kids:String):Array
		{
			var devidedArray:Array = [];
			
			var result:Object = _kidsRegExp.exec(kids);
			
			while (result != null) {
				devidedArray.push(result[0]);
				result = _kidsRegExp.exec(kids);
			}
			return devidedArray;
		}
		
		/**
		 * names分割ファンクション
		 * 
		 * <p>Dests内names文字列からnamesディクショナリーを作成します</p>
		 * 
		 * @param names String Dests内names文字列
		 * @return Dictionary namesディクショナリー
		 */
		private function _devideNames(names:String):Dictionary
		{
			if (!names) return null;
			
			var dictionary:Dictionary = new Dictionary();
			
			// key(括弧に囲まれている) そのあとValue(オブジェクトID)
			
			var result:Object = _namesRegExp.exec(names);
			
			while (result)
			{
				dictionary[result[1]] = result[2];
				result = _namesRegExp.exec(names);
			}
			
			return dictionary;
		}
	}
}