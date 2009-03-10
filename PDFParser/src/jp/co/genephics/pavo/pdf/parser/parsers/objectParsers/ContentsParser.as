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
	import flash.utils.CompressionAlgorithm;
	
	import jp.co.genephics.pavo.pdf.parser.models.Contents;
	import jp.co.genephics.pavo.pdf.parser.models.Page;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.DictionaryParser;
	import jp.co.genephics.pavo.pdf.parser.parsers.streamParsers.TextParser;
	
	public class ContentsParser
	{
		private var _target:ByteArray;
		private var _contentsTextArray:Array;
		
		public function ContentsParser(target:ByteArray)
		{
			_target = target;
			_contentsTextArray = [];
		}

		private var _page:Page;
		public function set page(value:Page):void
		{
			_page = value;
		}
		
		public function parse(xrefList:*):Array
		{
			if (xrefList is Array)
			{
				for each (var xref:XRef in xrefList)
				{
					var dictionaryParser:DictionaryParser = new DictionaryParser("Contents", _target);
					var dictArray:Array = dictionaryParser.extract(xref.index);
					
					var contents:Contents = new Contents();
					contents.length = dictArray[1]["/Length"];
					contents.filter = dictArray[1]["/Filter"];
					
					// streamキーの次の改行コードの次までポジションを移動する。
					var tmp:String = "";
					while(true)
					{
						tmp += _target.readUTFBytes(1);
						var streamStartPosition:int = tmp.indexOf("stream");
						if (streamStartPosition >= 0)
						{
							// データ読み出し位置までポジションを移動する
							var dummy:String = _target.readUTFBytes(1);
							while(dummy == "\r" || dummy == "\n")
							{
								dummy = _target.readUTFBytes(1);
							}
							_target.position--;
							break;
						}
					}

					var newData:ByteArray = new ByteArray();
					
					newData.writeBytes(_target, _target.position, Number(contents.length));
					
					newData.position = 0;

					/***********************************************************
					 * 
					 * FilterはFlateDecodeのみ対応
					 * 
					 ***********************************************************/
					
					if (contents.filter)
					{
						newData.uncompress(CompressionAlgorithm.ZLIB);
					}
					
					/***********************************************************
					 * 
					 * 文字列(BT～ET)オブジェクトのみを取り出すのでそれ以外のデータは非対象
					 * 
					 ***********************************************************/
					
					var textParser:TextParser = new TextParser();
					_contentsTextArray = _contentsTextArray.concat(textParser.parse(newData));
				}
			}
			else if (xrefList is XRef)
			{
				
			}
			else
			{
				return _contentsTextArray;
			}
			
			return _contentsTextArray;
		}
	}
}