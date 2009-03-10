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

package jp.co.genephics.pavo.pdf.parser.cmap
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.DictionaryParser;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;
	
	/**
	 * /CIDToGIDマッピングクラス
	 * 
	 * @author genephics design, Inc.
	 */
	public class CIDToGIDMapper
	{
		/**
		 * コンストラクタ
		 */
		public function CIDToGIDMapper()
		{
			super();
		}

		/**
		 * PDFのToUnicodeオブジェクトを解析し、Arrayにて返します。
		 * 
		 * @param toUnicodeObject PDFのToUnicodeオブジェクト(ByteArray)
		 * @return UnicodeMapの配列
		 */
		public static function cIDToGIDObjectToVector(xrefList:Array, cIDToGIDObject:ByteArray, target:ByteArray):KeyValueStore
		{
			// Dictionaryの解析
			var parser:DictionaryParser = new DictionaryParser("", cIDToGIDObject);
			var dictionaryArray:Array = parser.extract(0);
			
			var filter:String = dictionaryArray[1]["/Filter"];
			if (filter != "/FlateDecode")
			{
				return null;
			}
			
			var length:String = dictionaryArray[1]["/Length"];
			
			if (isNaN(Number(length)))
			{
				var oldPosition:uint = target.position;

				// lengthの部分がオブジェクトIDとなっているので、そのオブジェクトを見に行って取る必要あり
				var xref:XRef = ParserUtil.findByObjectId(xrefList, length);

				// DictionaryParserで取得できないので、手動で行う。
				// streamキーの次の改行コードの次までポジションを移動する。
				target.position = xref.index;
				length = "";
				while(true)
				{
					length += target.readUTFBytes(1);
					var lengthEndPosition:int = length.indexOf("endobj");
					if (lengthEndPosition >= 0)
					{
						break;
					}
				}
				
				// 以下の形式なので、正規表現で抽出
				// 6 0 obj 481 endobj
				length = length.replace(/\n/g, "");
				var pattern:RegExp = /\d+\s\d+\sobj(\d+)endobj/g;
				var lengthObj:Object = pattern.exec(length);
				length = lengthObj[1];
				
				target.position = oldPosition;				
			}
			
			// streamキーの次の改行コードの次までポジションを移動する。
			var tmp:String = "";
			while(true)
			{
				tmp += cIDToGIDObject.readUTFBytes(1);
				var streamStartPosition:int = tmp.indexOf("stream");
				if (streamStartPosition >= 0)
				{
					// データ読み出し位置までポジションを移動する
					var dummy:String = cIDToGIDObject.readUTFBytes(1);
					while(dummy == "\r" || dummy == "\n")
					{
						dummy = cIDToGIDObject.readUTFBytes(1);
					}
					cIDToGIDObject.position--;
					break;
				}
			}
			
			// stream部分の取り出し
			var stream:ByteArray = new ByteArray();
			
			stream.writeBytes(cIDToGIDObject, cIDToGIDObject.position, Number(length));
			
			return byteToVector(stream);
		}

		/**
		 * UnicodeMapのstreamデータを解析し、配列にして返します。<br />
		 * 引数は、PDFファイルのToUnicodeオブジェクトのデータ部分(stream～endstreamの部分)である必要があります。<br />
		 * データ部分は、FlateDecodeで圧縮されているものが対象です。<br />
		 * 
		 * @param UnicodeMapのstreamデータ
		 * @return UnicodeMapの配列
		 */
		public static function byteToVector(unicodeMap:ByteArray):KeyValueStore
		{
			unicodeMap.position = 0;

//			var file:File = File.desktopDirectory.resolvePath("ng1.txt");
//			var fileStream:FileStream = new FileStream();
//			fileStream.open(file, FileMode.WRITE);
//			fileStream.writeBytes(unicodeMap, 0, unicodeMap.length);
//			fileStream.close();

			unicodeMap.uncompress(CompressionAlgorithm.ZLIB);

//			var file2:File = File.desktopDirectory.resolvePath("ng2.txt");
//			var fileStream2:FileStream = new FileStream();
//			fileStream2.open(file2, FileMode.WRITE);
//			fileStream2.writeBytes(unicodeMap, 0, unicodeMap.length);
//			fileStream2.close();
			
			var cmapString:String = unicodeMap.readUTFBytes(unicodeMap.length);

			return stringToVector(cmapString);
		}

		/**
		 * UnicodeMapのString文字列を解析し、配列にして返します。<br />
		 * 
		 * 
		 * @param UnicodeMapのString文字列
		 * @return UnicodeMapの配列
		 */
		public static function stringToVector(cmapString:String):KeyValueStore
		{
			return CMapMapper.stringToArray(cmapString);
		}
	}
}