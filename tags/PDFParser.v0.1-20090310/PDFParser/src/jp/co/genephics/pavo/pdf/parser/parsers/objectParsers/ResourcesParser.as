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
	import __AS3__.vec.Vector;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import jp.co.genephics.pavo.pdf.parser.models.Resource;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.models.fonts.Font;
	import jp.co.genephics.pavo.pdf.parser.models.fonts.FontType0;
	import jp.co.genephics.pavo.pdf.parser.parsers.DictionaryParser;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;
	import jp.co.genephics.utils.StringUtil;
	
	public class ResourcesParser
	{
		private var _target:ByteArray;
		private var _xrefList:Array;
		
		public function ResourcesParser(xrefList:Array, byteArray:ByteArray)
		{
			_xrefList = xrefList;
			_target = byteArray;
		}
		
		public function parse(resoucesXRef:XRef):Resource
		{
			var parser:DictionaryParser = new DictionaryParser("", _target);
			var array:Array = parser.extract(resoucesXRef.index);
			
			var resoucesDictionary:Dictionary = array[1];
			if (!resoucesDictionary)
			{
				return null;
			}
			else
			{
				var resource:Resource = new Resource();
				var fontParser:FontParser = new FontParser(_xrefList, _target);
				var fontStrings:Array = _devideFontElement(resoucesDictionary["/Font"]);
				for each (var fontString:String in fontStrings)
				{
					var font:Object = _getFontObj(fontString, fontParser);
					var fontName:String = fontString.split(" ")[0];
					resource.fonts[fontName] = font;
					if (font is FontType0)
					{
						var fontType0:FontType0 = FontType0(font);
						fontType0.descendantFontList = _getDescendantFontList(fontType0);
					}
				}
				
				for (var key:String in resoucesDictionary)
				{
					var member:String = key.replace("/", "");
					member = member.substring(0,1).toLowerCase() + member.substring(1);
					resource[member] = resoucesDictionary[key];
				}

				return resource;
			}
		}
		
		public function parseFromString(parseTarget:String):Resource
		{
			var result:Array = parseTarget.match(/\/.+?<<.+?>>|\/.+?\[.+?\]|\/.+?\s\d+\s\d+\s\w+/ig);
			var fontPattern1:RegExp = /\/Font.*<<.+?>>/ig;
			var fontPattern2:RegExp = /\/Font.*\d+\s\d+\s\w+/ig;
			var fontParser:FontParser = new FontParser(_xrefList, _target);
			
			var resource:Resource = new Resource();
			for each (var element:String in result)
			{
				// Font情報のみさらにパースする
				if (fontPattern1.test(element))
				{
					// value値にフォント情報が格納されているパターン
					var fonts:Array = element.match(/\/\w+\d+\s\d+\s\d\s\w+/ig); 
					for each (var fontValue:String in fonts)
					{
						var fontObj:Object = _getFontObj(fontValue, fontParser);
						var fontName:String = fontValue.split(" ")[0];
						resource.fonts[fontName] = fontObj;
					}
				}
				else if (fontPattern2.test(element))
				{
					// value値にフォント情報が格納されておらず、オブジェクトIDが格納されているパターン
					// objectIdが指すところに、Font情報が入っている
					var objectID:String = element.split(" ")[1];
					var fontXref:XRef = ParserUtil.findByObjectId(_xrefList, objectID);
					var dictionaryParser:DictionaryParser = new DictionaryParser("", _target);
					var dictArray:Array = dictionaryParser.extract(fontXref.index);
					for (var key:String in dictArray[1])
					{
						// _getFontObjコール用に引数を作成
						var fontString:String = key.substring(1) + " " + dictArray[1][key];
						var font:Object = _getFontObj(fontString, fontParser);
						resource.fonts[key] = font;
					}
				}
				else
				{
					var devideElementPattern:RegExp = /(\/.+?)([\s\[\(\<].*)/;
					var devideElements:Array = devideElementPattern.exec(element);
					var member:String = devideElements[1].replace("/", "");
					member = member.substring(0,1).toLowerCase() + member.substring(1);
					resource[member] = devideElements[2];
				}
			}
			return resource;
		}
		
		private function _getDescendantFontList(font:FontType0):Vector.<Font>
		{
			var fontParser:FontParser = new FontParser(_xrefList, _target);
			var fontRegExp:RegExp = /(\d+)\s\d+\s\w/ig;
			var targetRegExp:String = StringUtil.trim(font.descendantFonts);
			var result:Array = fontRegExp.exec(targetRegExp);
			while(result)
			{
				var objectID:String = result[1];
				var fontXref:XRef = ParserUtil.findByObjectId(_xrefList, objectID);
				var descendantFont:Object = fontParser.parse(fontXref);
				font.descendantFontList.push(descendantFont);
				result = fontRegExp.exec(targetRegExp);
			}
			
			return font.descendantFontList;
		}

		private function _devideFontElement(parseTarget:String):Array
		{
			var devidedArray:Array = [];
			
			var myPattern:RegExp = /\/\S+\s\S+\s\S+\sR/ig;
			var result:Object = myPattern.exec(parseTarget);
			
			while (result != null) {
				devidedArray.push(result[0]);
				result = myPattern.exec(parseTarget);
			}
			
			return devidedArray;
		}

		private function _getFontObj(elementString:String, fontParser:FontParser):Object
		{
			var devideMembers:Array = elementString.split(" ");
			// 先頭の'/'を取り除く
			var name:String = String(devideMembers[0]).replace("/", "");
			var objectID:String = devideMembers[1];
			
			var fontXref:XRef = ParserUtil.findByObjectId(_xrefList, objectID);
			var font:Object = fontParser.parse(fontXref);
			
			if (!font) return null;
			
			font.generationNumber = fontXref.generationNumber;
			font.index = fontXref.index;
			font.inUse = fontXref.inUse;
			font.objectID = fontXref.objectID;
			
			return font;
		}
	}
}