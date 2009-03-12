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

package jp.co.genephics.pavo.pdf.parser.utils
{
	import flash.utils.ByteArray;
	
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	
	/**
	 * Parser に関するユーティリティクラス
	 * 
	 * @author genephics design, Inc.
	 */
	public class ParserUtil
	{
		/**
		 * 対象のオブジェクトIDからXRef情報を取り出します
		 * 
		 * @param xrefList XRefリスト
		 * @param targetObjectId 対象のオブジェクトID
		 * 
		 * @return XRef情報
		 */
		public static function findByObjectId(xrefList:Array, targetObjectId:String):XRef
		{
			if (!targetObjectId) return null;
			
			var objectId:int = Number(targetObjectId.split(" ")[0]);
			return xrefList[objectId];
		}
		
		/**
		 * PDF文書のバイナリからASCIIコードを取り出します。パラメーターのtargetの位置からlength分が対象です。
		 * 
		 * @param target PDF文書のバイナリ
		 * @param length 取り出す長さ
		 * @return ASCII文字列
		 */
		public static function readAsciiString(target:ByteArray, length:int):String
		{
			var byteArray:ByteArray = new ByteArray();
			
			for (var i:int=0; i<length; i++)
			{
				var uniByte:int = target.readByte();
				
				byteArray.writeByte(uniByte);
			}
			
			if (byteArray[0] == 0xFE && byteArray[1] == 0xFF)
			{
				// Unicodeとして扱う
				
				var newByteArray:ByteArray = new ByteArray();
				
				byteArray.position = 0;
				var byteArrayLength:int = byteArray.length;
				for (var j:int=0; j<byteArrayLength; j++)
				{
					var newByte:int = byteArray.readByte();
					
					// バックスラッシュ
					if (j > 0 && byteArray[j-1] == 0x5C && byteArray[j] == 0x5C)
					{
						
					}
					// エスケープはとばす
					else if (byteArray[j] == 0x5C && byteArrayLength > j+1 && (byteArray[j+1] == 0x28 ||byteArray[j+1] == 0x29 ||byteArray[j+1] == 0x6e||byteArray[j+1] == 0x72||byteArray[j+1] == 0x74||byteArray[j+1] == 0x62||byteArray[j+1] == 0x66 ) )
					{
					}
					// VT: Vertical Tabulation (垂直タブ)
					else if (j > 0 && byteArray[j-1] == 0x00 && byteArray[j] == 0x0B)
					{
						newByteArray.writeByte(0x20);
					}
					else
					{
						newByteArray.writeByte(newByte);
					}
				}
				newByteArray.position = 2;
				return newByteArray.readMultiByte(newByteArray.length-2, "unicodeFFFE");
//				return byteArray.readMultiByte(byteArray.length, "unicode");
			}
			
			byteArray.position = 0;
			return byteArray.readMultiByte(byteArray.length, "us-ascii");
		}
	}
}