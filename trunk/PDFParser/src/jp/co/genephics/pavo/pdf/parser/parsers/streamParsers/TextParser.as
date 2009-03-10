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

package jp.co.genephics.pavo.pdf.parser.parsers.streamParsers
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	public class TextParser
	{
		private var _startedAscii:Boolean = false;
		private var _startedText:Boolean = false;
		private var _isComment:Boolean = false;
		private var _currentIndex:int = 0;
		private var _target:ByteArray = null;
		private var _charCheckers:Array = null;
		
		private var _array:Array = [];
		private var _buffer:String = "";
		private var _binaryBuffer:String = "";

		public function TextParser()
		{
			_charCheckers = new Array();
			_charCheckers[40000000] = [_isAscii, _ascii, true];
			_charCheckers[41000000] = [_isAscii, _ascii, false];

			_charCheckers[66084000] = [_isNotStartedAscii, _startBT, null];	// _target[currentIndex] == 66 && target[i+1] == 84					-> BT

			_charCheckers[84102000] = [_isStartedText, _textBlock, "Tf"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 102	-> Tf
			_charCheckers[84109000] = [_isStartedText, _textBlock, "Tm"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 109	-> Tm
			_charCheckers[84074000] = [_isStartedText, _textBlock, "TJ"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 74		-> TJ
			_charCheckers[84106000] = [_isStartedText, _textBlock, "Tj"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 106	-> Tj
			_charCheckers[84099000] = [_isStartedText, _textBlock, "Tc"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 99		-> Tc
			_charCheckers[84119000] = [_isStartedText, _textBlock, "Tw"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 119	-> Tw
			_charCheckers[84068000] = [_isStartedText, _textBlock, "TD"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 68		-> TD
			_charCheckers[84100000] = [_isStartedText, _textBlock, "Td"];	// _target[currentIndex] == 84 && _target[currentIndex+1] == 100	-> Td

			_charCheckers[69084000] = [_isNotStartedAscii, _endET, null];	// _target[currentIndex] == 69 && target[i+1] == 84					-> ET

			// 以下、処理対象外のオペレーター
			_charCheckers[66068067] = [_isStartedText, _textBlock_NotApplicable, "BDC"];	// _target[currentIndex] == 66 && _target[currentIndex+1] == 68 && _target[currentIndex+1] == 67	-> BDC
			_charCheckers[66077067] = [_isStartedText, _textBlock_NotApplicable, "BMC"];	// _target[currentIndex] == 66 && _target[currentIndex+1] == 77 && _target[currentIndex+1] == 67	-> BMC
			_charCheckers[69077067] = [_isStartedText, _textBlock_NotApplicable, "EMC"];	// _target[currentIndex] == 69 && _target[currentIndex+1] == 77 && _target[currentIndex+1] == 67	-> EMC
			_charCheckers[83067078] = [_isStartedText, _textBlock_NotApplicable, "SCN"];	// _target[currentIndex] == 83 && _target[currentIndex+1] == 67 && _target[currentIndex+1] == 78	-> SCN
			_charCheckers[115099110] = [_isStartedText, _textBlock_NotApplicable, "scn"];	// _target[currentIndex] == 115 && _target[currentIndex+1] == 99 && _target[currentIndex+1] == 110	-> scn

			_charCheckers[73068000] = [_isStartedText, _textBlock_NotApplicable, "ID"];	// _target[currentIndex] == 73 && _target[currentIndex+1] == 68	-> ID
			_charCheckers[69073000] = [_isStartedText, _textBlock_NotApplicable, "EI"];	// _target[currentIndex] == 69 && _target[currentIndex+1] == 73	-> EI
			_charCheckers[68080000] = [_isStartedText, _textBlock_NotApplicable, "DP"];	// _target[currentIndex] == 68 && _target[currentIndex+1] == 80	-> DP
			_charCheckers[67083000] = [_isStartedText, _textBlock_NotApplicable, "CS"];	// _target[currentIndex] == 67 && _target[currentIndex+1] == 83	-> CS
			_charCheckers[69084000] = [_isStartedText, _textBlock_NotApplicable, "ET"];	// _target[currentIndex] == 69 && _target[currentIndex+1] == 84	-> ET
			_charCheckers[77080000] = [_isStartedText, _textBlock_NotApplicable, "MP"];	// _target[currentIndex] == 77 && _target[currentIndex+1] == 80	-> MP
			_charCheckers[68111000] = [_isStartedText, _textBlock_NotApplicable, "Do"];	// _target[currentIndex] == 68 && _target[currentIndex+1] == 111	-> Do
			_charCheckers[115099000] = [_isStartedText, _textBlock_NotApplicable, "sc"];	// _target[currentIndex] == 115 && _target[currentIndex+1] == 99	-> sc
			_charCheckers[99115000] = [_isStartedText, _textBlock_NotApplicable, "cs"];	// _target[currentIndex] == 99 && _target[currentIndex+1] == 115	-> cs
			_charCheckers[103115000] = [_isStartedText, _textBlock_NotApplicable, "gs"];	// _target[currentIndex] == 103 && target[i+1] == 115				-> gs
			_charCheckers[114105000] = [_isStartedText, _textBlock_NotApplicable, "ri"];	// _target[currentIndex] == 114 && _target[currentIndex+1] == 105	-> ri
			_charCheckers[115104000] = [_isStartedText, _textBlock_NotApplicable, "sh"];	// _target[currentIndex] == 115 && _target[currentIndex+1] == 104	-> sh

			_charCheckers[81000000] = [_isStartedText, _textBlock_NotApplicable, "Q"];	// _target[currentIndex] == 81										-> Q
			_charCheckers[83000000] = [_isStartedText, _textBlock_NotApplicable, "S"];	// _target[currentIndex] == 83										-> S
			_charCheckers[87000000] = [_isStartedText, _textBlock_NotApplicable, "W"];	// _target[currentIndex] == 87										-> W
			_charCheckers[102000000] = [_isStartedText, _textBlock_NotApplicable, "f"];	// _target[currentIndex] == 102										-> f
			_charCheckers[103000000] = [_isStartedText, _textBlock_NotApplicable, "g"];	// _target[currentIndex] == 103										-> g
			_charCheckers[107000000] = [_isStartedText, _textBlock_NotApplicable, "k"];	// _target[currentIndex] == 107										-> k
			_charCheckers[110000000] = [_isStartedText, _textBlock_NotApplicable, "n"];	// _target[currentIndex] == 110										-> n
			_charCheckers[113000000] = [_isStartedText, _textBlock_NotApplicable, "q"];	// _target[currentIndex] == 113										-> q

		}

		public function parse(target:ByteArray):Array
		{
			_array = [];
			_buffer = "";
			_binaryBuffer = "";
			
			_target = target;
			_startedAscii = false;
			_startedText = false;
			_isComment = false;
			
			var charChecker:Array = null;

//			var file:File = File.desktopDirectory.resolvePath("log.txt");
//			var fileStream:FileStream = new FileStream();
//			fileStream.open(file, FileMode.WRITE);
//			fileStream.writeBytes(_target, 0, _target.length);
//			fileStream.close();

			for (_currentIndex = 0; _currentIndex < _target.length - 1; _currentIndex++)
			{
				if (_isEndCommentChar())
				{
					_isComment = false;
					continue;
				}

				if (_isComment)
				{
					continue;
				}
				else if(_isCommentChar() && !_isComment)
				{
					_isComment = true;
					continue;
				}
				
				// BDC, BMC, EMC, SCN, scn
				if
				(
					(_currentIndex + 3) <= _target.length && _isCR_or_LF_or_SPACE(_currentIndex+3)
					&&
					(_target[_currentIndex] == 66 || _target[_currentIndex] == 69 || _target[_currentIndex] == 83 || _target[_currentIndex] == 115)
				)
				{
					charChecker = _charCheckers[_target[_currentIndex] * 1000000 + _target[_currentIndex+1] * 1000 + _target[_currentIndex+2]];
				}
				if
				(
					!charChecker
					&&
					(_currentIndex + 2) <= _target.length && _isCR_or_LF_or_SPACE(_currentIndex+2)
					&&
					(
						   _target[_currentIndex] == 66
						|| _target[_currentIndex] == 84
						|| _target[_currentIndex] == 73
						|| _target[_currentIndex] == 69
						|| _target[_currentIndex] == 68
						|| _target[_currentIndex] == 67
						|| _target[_currentIndex] == 77
						|| _target[_currentIndex] == 115
						|| _target[_currentIndex] == 99
						|| _target[_currentIndex] == 103
						|| _target[_currentIndex] == 114
					)
				)
				{
					charChecker = _charCheckers[_target[_currentIndex] * 1000000 + _target[_currentIndex+1] * 1000];
				}
				if (!charChecker && (_target[_currentIndex] == 40 || _target[_currentIndex] == 41 || _isCR_or_LF_or_SPACE(_currentIndex+1)))
				{
					charChecker = _charCheckers[_target[_currentIndex] * 1000000];
				}

				if (charChecker && charChecker[0].call())
				{
					charChecker[1].call(this, charChecker[2]);
				}
				else if (_startedText && !_isComment)
				{
					_buffer += String.fromCharCode(_target[_currentIndex]);
					_binaryBuffer += _target[_currentIndex].toString(16);
				}
				charChecker = null;
			}
			
			return _array;	
		}

		private function _isCommentChar():Boolean
		{
			if (_target[_currentIndex] == 37 && (_currentIndex == 0 || (_currentIndex >= 1 && _target[_currentIndex-1] != 92)) && !_startedAscii)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		private function _isEndCommentChar():Boolean
		{
			if (_target[_currentIndex] == 10 && _isComment) // \n
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		private function _isAscii():Boolean
		{
			if ((_currentIndex == 0 || (_currentIndex >= 1 && _target[_currentIndex-1] != 92)))
			{
				return true;
			}
			else
			{
				return false;
			}			
		}

		private function _ascii(asciiFlg:Boolean):void
		{
			_startedAscii = asciiFlg;
			_buffer += String.fromCharCode(_target[_currentIndex]);
			_binaryBuffer += _target[_currentIndex].toString(16);
		}

		private function _isNotStartedAscii():Boolean
		{
			return !_startedAscii;
		}

		private function _startBT(dummy:Object):void
		{
			_startedText = true;
			_currentIndex++;
		}

		private function _endET(dummy:Object):void
		{
			_startedText = false;
			_currentIndex++;
			_buffer = "";
			_binaryBuffer = "";
		}
		
		private function _isStartedText():Boolean
		{
			return (_startedText && !_startedAscii);
		}

		private function _isCR_or_LF_or_SPACE(targetIndex:int):Boolean
		{
			return (_target[targetIndex] == 10 || _target[targetIndex] == 13 || _target[targetIndex] == 32) ? true : false;
		}

		private function _textBlock(operator:String):void
		{
			_array.push(new Array(operator, _buffer, _binaryBuffer));
			_buffer = "";
			_binaryBuffer = "";
			_currentIndex += operator.length;
		}

		private function _textBlock_NotApplicable(operator:String):void
		{
			_buffer = "";
			_binaryBuffer = "";
			_currentIndex += operator.length;
		}
	}
}