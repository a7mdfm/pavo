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
	
	import jp.co.genephics.pavo.pdf.parser.cmap.models.CMap;
	
	/**
	 * CMAPファイルのロードを行うクラス
	 * 
	 * @author genephics design inc.
	 */
	public class CMapMapper
	{
		/**
		 * コンストラクタ
		 */
		public function CMapMapper()
		{
		}

		/**
		 * 引数に指定したCMapファイルを読み込み、Vectorにして返します。
		 * 
		 */
		public static function fileToVector(cmapFile:File):KeyValueStore
		{
			
			var cmapStream:FileStream = new FileStream();
			cmapStream.open(cmapFile,FileMode.READ);
			
			var cmapString:String = cmapStream.readUTFBytes(cmapFile.size);
			
			return stringToArray(cmapString);
		}
		
		/**
		 * CMAP文字列をVectorに変換して返します。
		 * 
		 * @param
		 * @return CMapデータ
		 */
//		public static function stringToVector(cmapString:String):KeyValueStore
//		{
//			
//			var array:Array = cmapString.split(/(\r\n|\n)/);
//			
//			var cmapData:Vector.<CMap> = new Vector.<CMap>();
//
//			for (var i:int=0; i<array.length; i++)
//			{
//				if (!array[i] || array[i] == ""|| array[i] == "\r\n" || array[i] == "\n")
//				{
//					continue;
//				}
//
//				var myPattern:RegExp = /\<(.+?)\>/ig;
//				var result:Object = myPattern.exec(array[i]);
//				
//				var devidedArray:Array = [];
//				
//				if (result == null)
//				{
//					continue;
//				}
//
//				while(result != null)
//				{
//					devidedArray.push(result[1]);
//					result = myPattern.exec(array[i]);
//				}
//				
//				var cmapElement:CMap = new CMap();
//				
//				if (devidedArray.length == 2)
//				{
//					cmapElement.rangeBegin = devidedArray[0];
//					cmapElement.rangeEnd = devidedArray[0];
//					cmapElement.value = devidedArray[1];
//				}
//				else if (devidedArray.length == 3)
//				{
//					cmapElement.rangeBegin = devidedArray[0];
//					cmapElement.rangeEnd = devidedArray[1];
//					cmapElement.value = devidedArray[2];
//				}
//				
//				cmapData.push(cmapElement);
//			}
//			return cmapData;
//		}

		public static function stringToArray(cmapString:String):KeyValueStore
		{
			var store:KeyValueStore = new KeyValueStore();
			var cmapArray:Array = cmapString.split(/(\r\n|\n)/);
			var cmapArrayLen:int = cmapArray.length;
			var value:String = "";
			
			for (var i:int = 0; i < cmapArrayLen; i++)
			{
				value = cmapArray[i];
				if (!value || value == ""|| value == "\r\n" || value == "\n")
				{
					continue;
				}

				var myPattern:RegExp = /\<(.+?)\>/ig;
				var result:Object = myPattern.exec(value);
				
				var devidedArray:Array = [];
				
				if (!result) continue;

				while (result)
				{
					devidedArray.push(result[1]);
					result = myPattern.exec(value);
				}
				
				var cmapElement:CMap = new CMap();
				
				if (devidedArray.length == 2)
				{
					cmapElement.rangeBegin = devidedArray[0];
					cmapElement.rangeEnd = devidedArray[0];
					cmapElement.value = devidedArray[1];
				}
				else if (devidedArray.length == 3)
				{
					cmapElement.rangeBegin = devidedArray[0];
					cmapElement.rangeEnd = devidedArray[1];
					cmapElement.value = devidedArray[2];
				}
				
				addStore(store, cmapElement);
			}
			
			return store;
		}

		public static function addStore(target:KeyValueStore, cmap:CMap):KeyValueStore
		{
			if (cmap.rangeBegin == cmap.rangeEnd)
			{
				target.add(cmap, Number("0x" + cmap.rangeBegin));
				return target;
			}
			
			var b:Number = Number("0x" + cmap.rangeBegin);
			var e:Number = Number("0x" + cmap.rangeEnd);
			var v:Number = Number("0x" + cmap.value);
			var c:CMap;
			
			while (b <= e)
			{
				c = new CMap();
				c.rangeBegin = b.toString(16);
				c.rangeEnd = b.toString(16);
				c.value = v.toString(16);
				target.add(c, b);
				b++;
				v++;
			}
			
			return target;
		}

	}
}