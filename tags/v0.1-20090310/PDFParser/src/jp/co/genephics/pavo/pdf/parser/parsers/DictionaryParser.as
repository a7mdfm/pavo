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

package jp.co.genephics.pavo.pdf.parser.parsers
{
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import jp.co.genephics.pavo.pdf.parser.constants.PdfConst;
	import jp.co.genephics.pavo.pdf.parser.models.Trailer;
	import jp.co.genephics.pavo.pdf.parser.utils.Judgement;
	import jp.co.genephics.pavo.pdf.parser.utils.ParserUtil;
	import jp.co.genephics.utils.StringUtil;
	
	public class DictionaryParser
	{

		private var _source:ByteArray;
		private var _type:String;
		
		/**
		 * コンストラクタ
		 */
		public function DictionaryParser(type:String, byteArray:ByteArray)
		{
			super();
			_type = type;
			_source = byteArray;
		}

		/**
		 * dictionary の抽出
		 * 
		 * @param basePosition 基準位置
		 * @return array 取り出した後の位置,Trailerオブジェクト
		 */
		public function extract(basePosition:uint):Array
		{
			var endFlag:Boolean = false;
			var index:uint = basePosition;
			var startPosition:int = 0;
			var model:Object;
			
			var beginBracketCount:int = 0;
			var endBracketCount:int = 0;
			
			
			for (; index<_source.length; index++)
			{
				if (_source.length - PdfConst.END_DOUBLE_ANGLE_BRACKETS.length < index)
					break;
				
				if (Judgement.isStartKeyword(PdfConst.BEGIN_DOUBLE_ANGLE_BRACKETS, _source, index))
				{
					beginBracketCount++;
					
					if (beginBracketCount == 1)
					{
						startPosition = index + PdfConst.BEGIN_DOUBLE_ANGLE_BRACKETS.length;
					}
					index += (PdfConst.BEGIN_DOUBLE_ANGLE_BRACKETS.length - 1);
					continue;
				}
				
				if (Judgement.isStartKeyword(PdfConst.END_DOUBLE_ANGLE_BRACKETS, _source, index))
				{
					endBracketCount++;
					
					if (beginBracketCount == endBracketCount)
					{
						// 終了
						_source.position = startPosition;
						if (_type == Trailer.TYPE)
						{
							model = _devideElements(_source.readUTFBytes(index - startPosition));
						}
						else
						{
							model = _devideDictionary(startPosition, index - startPosition + 1);
						}
						endFlag = true;
						break;
					}
					else
					{
						index += (PdfConst.END_DOUBLE_ANGLE_BRACKETS.length - 1);
					}
				}
			}

			if (!endFlag)
			{
				throw new Error("illegal file format !!!(dictionary の終端なし)");
			}
			
			return [index-1, model];
		}
		
		private function _devideDictionary(startIndex:int, length:int):Dictionary
		{
			var model:Dictionary = new Dictionary();
			
			var tmpKey:String;
			var tmpValue:String;
			
			var mode:int = 0;
			var keywordStartPoint:int = 0;
			var valueStartPoint:int = 0;
			var bracketIndex:int = -1;
			
			for (var i:int=startIndex; i<startIndex+length; i++)
			{
				_source.position = i;
				var tmpStr:String = _source.readUTFBytes(1);

				// キーワード開始
				if (mode == 0 && tmpStr == PdfConst.SLASH)
				{
					mode = 1;
					keywordStartPoint = i;
					continue;
				}
				
				// キーワード終了
				if (mode == 1 && ( tmpStr == PdfConst.SLASH || tmpStr == " " || tmpStr == "(" || tmpStr == "[" || tmpStr == "<" || tmpStr == "\n"))
				{
					// スペースの次がBracketならそれをキーワード終了とする
					if (_isNextWordBracket(_source))
					{
						continue;
					}
					mode = 2;

					bracketIndex = _findBracketIndex(tmpStr);
					
					_source.position = keywordStartPoint;
					tmpKey = StringUtil.trim(_source.readUTFBytes(i - keywordStartPoint));
					_source.position = i;
					
					// valueの開始
					valueStartPoint = i;
					continue;
				}

				//value終了
				if ((mode == 2 && ( tmpStr == PdfConst.SLASH || tmpStr == ")" || tmpStr == "]" || tmpStr == ">")) || (mode == 2 && i == startIndex+length-1))
				{
					if (valueStartPoint + 1 == i)
					{
						// valuesの開始区切りが'/"でその前がスペースだった場合、スペースの部分でキーワードが終了とみなされ、
						// その後の'/'でvalueが終了とみなされてしまうので、それを防ぐ
						continue;
					}

					if (bracketIndex > -1)
					{
						if (tmpStr != PdfConst.BRACKET_WORDS[bracketIndex][1])
						{
							continue;
						}
					}
					
					_source.position = valueStartPoint;
					
					// "(",")"で括っているのはASCII文字列
					if(_source[valueStartPoint] == 0x28)
					{
						//ASCII 文字列
						var l_length:int = i - valueStartPoint;
						_source.position = _source.position+1;
						tmpValue = ParserUtil.readAsciiString(_source, l_length);
					}
					else
					{
						tmpValue = StringUtil.trim(_source.readUTFBytes(i - valueStartPoint));
					}
					
					if (!_checkKeywordAppearanceCount(tmpValue))
					{
						if (tmpStr == ")" || tmpStr == "]" || tmpStr == ">")
						{
							tmpValue += tmpStr;
							if (!_checkKeywordAppearanceCount(tmpValue))
							{
								continue;
							}
						}
						else
						{
							// 括弧の始まりと終わりの数が一致していなければ、処理継続する。
							continue;
						}
					}
					
					mode = 0;
					i--;
					
					
					if (tmpValue.indexOf("[") == 0 )
					{
						tmpValue = tmpValue.substr(1,tmpValue.length-1);
					}
					
					model[tmpKey] = tmpValue;
					
					bracketIndex = -1;
					continue;
				}
			}
			
			return model;
		}

		private function _checkKeywordAppearanceCount(value:String):Boolean
		{
			var keywordAppearanceCount:Dictionary = new Dictionary();

			keywordAppearanceCount["("] = 0;
			keywordAppearanceCount[")"] = 0;
			keywordAppearanceCount["["] = 0;
			keywordAppearanceCount["]"] = 0;
			keywordAppearanceCount["<"] = 0;
			keywordAppearanceCount[">"] = 0;

			for (var i:int = 0; i < value.length; i++)
			{
				var char:String = value.substr(i, 1);

				if (char == "(" || char == ")" || char == "[" || char == "]" || char == "<" || char == ">")
				{
					keywordAppearanceCount[char]++;
				}
			}

			if (keywordAppearanceCount["("] == 0 && keywordAppearanceCount["["] == 0 && keywordAppearanceCount["<"] == 0)
			{
				return true;
			}
			else if (keywordAppearanceCount["("] == keywordAppearanceCount[")"]
				&& keywordAppearanceCount["["] == keywordAppearanceCount["]"]
				&& keywordAppearanceCount["<"] == keywordAppearanceCount[">"])
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function _findBracketIndex(bracketWord:String):int
		{
			var retValue:int = -1;
			
			for (var i:int = 0; i < PdfConst.BRACKET_WORDS.length; i++)
			{
				if (PdfConst.BRACKET_WORDS[i][0] == bracketWord)
				{
					retValue = i;
				}
			}
			return retValue;
		}
		
		private function _isNextWordBracket(target:ByteArray):Boolean
		{
			var retValue:Boolean = false;

			_source.position++;
			var nextWord:String = _source.readUTFBytes(1);
			if (nextWord == "(" || nextWord == "[" || nextWord == "<")
			{
				retValue = true;
			}
			_source.position--;
			
			return retValue;
		}
		
		private function _devideElements(elements:String):Trailer
		{
			// TODO: TRACE POINT
			trace("ELEMENTS["+elements+"]");
			
			if (!elements || elements.length == 0) return null;
			
			var model:Trailer = new Trailer();

			var arrayElements:Array = elements.split("/");

			for each (var element:String in arrayElements)
			{
				if (!element || element.length == 0 ) continue;
				
				var devidePoint:int = element.search(/\W/);
				var key:String = "/" + element.substr(0, devidePoint);
				var value:String = StringUtil.trim(element.substring(devidePoint,element.length));
				
				switch (key)
				{
					case Trailer.KEY_ROOT:
					model.root = value;
					break;
					case Trailer.KEY_INFO:
					model.info = value;
					break;
					case Trailer.KEY_SIZE:
					model.size = value;
					break;
					case Trailer.KEY_PREV:
					model.prev = value;
					break;
					case Trailer.KEY_ID:
					model.id = value;
					break;
					case Trailer.KEY_ENCRYPT:
					model.encrypt = value;
					break;
					case Trailer.KEY_XREFSTM:
					model.xrefstm = value;
					break;
				}
			}
			return model;
		}
	}
}