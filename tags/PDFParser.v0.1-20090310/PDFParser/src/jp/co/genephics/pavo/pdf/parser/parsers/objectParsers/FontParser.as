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
	
	import jp.co.genephics.pavo.pdf.parser.cmap.CIDToGIDMapper;
	import jp.co.genephics.pavo.pdf.parser.cmap.UnicodeMapper;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.parsers.DictionaryParser;
	import jp.co.genephics.pavo.pdf.parser.utils.FontFactory;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;
	
	public class FontParser
	{
		private var _target:ByteArray;
		private var _xrefList:Array;
		
		public function FontParser(xrefList:Array, byteArray:ByteArray)
		{
			_xrefList = xrefList;
			_target = byteArray;
		}

		public function parse(fontXRef:XRef):Object
		{
			var dictionaryParser:DictionaryParser = new DictionaryParser("", _target);
			var dictArray:Array = dictionaryParser.extract(fontXRef.index);
			
			var subtype:String = dictArray[1]["/Subtype"];
			var font:Object = FontFactory.create(subtype);
			
			if (!font) return null;
			
			font.type = dictArray[1]["/Type"];
			font.subType = dictArray[1]["/Subtype"];
			switch(subtype)
			{
				case "/Type0":
					font = _createFontType0(dictArray[1], font);
					break;
				case "/Type1":
					font = _createFontType1(dictArray[1], font);
					break;
				case "/MMType1":
					font = _createFontMMType1(dictArray[1], font);
					break;
				case "/Type3":
					font = _createFontType3(dictArray[1], font);
					break;
				case "/TrueType":
					font = _createFontTrueType(dictArray[1], font);
					break;
				case "/CIDFontType0":
					font = _createFontCIDFontType0(dictArray[1], font);
					break;
				case "/CIDFontType2":
					font = _createFontCIDFontType2(dictArray[1], font);
					break;
				default:
					font = null;
					break;
			}
			
			if (font && font.hasOwnProperty("toUnicodeObj") && font["toUnicodeObj"])
			{
				font.toUnicodeMap = UnicodeMapper.toUnicodeObjectToVector(_xrefList, font["toUnicodeObj"], _target);
			}
			return font;
		}
		
		private function _createFontType0(value:Object, font:Object):Object
		{
			font.encoding = value["/Encoding"];
			font.encodingObj = _getToEncodingObj(font);
			font.descendantFonts = value["/DescendantFonts"];
			font.toUnicode = value["/ToUnicode"];
			font.toUnicodeObj = _getByteArrayFromObjectIdIncludeString(font.toUnicode);

			return font;
		}

		private function _createFontType1(value:Object, font:Object):Object
		{
			font.name = value["/Name"];
			font.baseFont = value["/BaseFont"];
			font.firstChar = value["/FirstChar"];
			font.lastChar = value["/LastChar"];
			font.widths = value["/Widths"];
			font.fontDescriptor = value["/FontDescriptor"];
			font.encoding = value["/Encoding"];
			font.encodingObj = _getToEncodingObj(font);
			font.toUnicode = value["/ToUnicode"];
			font.toUnicodeObj = _getByteArrayFromObjectIdIncludeString(font.toUnicode);
			
			return font;
		}

		private function _createFontMMType1(value:Object, font:Object):Object
		{
			return _createFontType1(value, font);
		}

		private function _createFontType3(value:Object, font:Object):Object
		{
			font.name = value["/Name"];
			font.fontBBox = value["/FontBBox"];
			font.fontMatrix = value["/FontMatrix"];
			font.charProcs = value["/CharProcs"];
			font.encoding = value["/Encoding"];
			font.encodingObj = _getToEncodingObj(font);
			font.firstChar = value["/FirstChar"];
			font.lastChar = value["/LastChar"];
			font.widths = value["/Widths"];
			font.fontDescriptor = value["/FontDescriptor"];
			font.resources = value["/Resources"];
			font.toUnicode = value["/ToUnicode"];
			font.toUnicodeObj = _getByteArrayFromObjectIdIncludeString(font.toUnicode);

			return font;
		}

		private function _createFontTrueType(value:Object, font:Object):Object
		{
			return _createFontType1(value, font);
		}
		
		private function _createFontCIDFontType0(value:Object, font:Object):Object
		{
			font.baseFont = value["/BaseFont"];
			font.cIDSystemInfo = value["/CIDSystemInfo"];
			font.fontDescriptor = value["/FontDescriptor"];
			font.dW = value["/DW"];
			font.w = value["/W"];
			font.dW2 = value["/DW2"];
			font.w2 = value["/W2"];
			font.cIDToGID = value["/CIDToGIDMap"];
			if (font.cIDToGID)
			{
				font.cIDToGIDObj = _getByteArrayFromObjectIdIncludeString(value["/CIDToGIDMap"]);
				font.cIDToGIDMap = CIDToGIDMapper.cIDToGIDObjectToVector(_xrefList, font.cIDToGIDObj, _target);
			}
			
			return font;
		}
		
		private function _createFontCIDFontType2(value:Object, font:Object):Object
		{
			return _createFontCIDFontType0(value, font);
		}

		private function _getToEncodingObj(font:Object):Object
		{
			var myPattern:RegExp = /^([0-9]+)\s([0-9]+)\s([a-zA-Z]+)$/ig;
			var result:Object = myPattern.exec(font.encoding);

			if (result == null)
			{
				return null;
			}
			
			var objectId:String = result[1];
			var encodingXRef:XRef = ParserUtil.findByObjectId(_xrefList, objectId);
			var dictionaryParser:DictionaryParser = new DictionaryParser("", _target);
			var dictArray:Array = dictionaryParser.extract(encodingXRef.index);
			
			return null;
		}
		
		private function _getByteArrayFromObjectIdIncludeString(objectIdIncludeString:String):ByteArray
		{
			if (!objectIdIncludeString || objectIdIncludeString.length == 0)
			{
				return null;
			}
			
			var toUnicodeXRef:XRef = ParserUtil.findByObjectId(_xrefList, objectIdIncludeString);
			var dictionaryParser:DictionaryParser = new DictionaryParser("", _target);
			var dictArray:Array = dictionaryParser.extract(toUnicodeXRef.index);

			_target.position = toUnicodeXRef.index;
				
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

			var length:uint = _target.position - toUnicodeXRef.index + Number(dictArray[1]["/Length"]);

			var newData:ByteArray = new ByteArray();
			_target.position = toUnicodeXRef.index;
			newData.writeBytes(_target, _target.position, length);

			newData.position = 0;
			
			return newData;
		}
	}
}