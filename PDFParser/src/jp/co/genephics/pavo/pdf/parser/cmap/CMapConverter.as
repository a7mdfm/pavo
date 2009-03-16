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
	import mx.core.ByteArrayAsset;
	
	/**
	 * CMapコンバーター。(シングルトン)<br /> 
	 * デフォルトでは Adobe-Japan1-UCS2 を使用します。
	 * 
	 * @author genephics design, Inc.
	 */
	public class CMapConverter
	{
		[Embed(source="cmap/Adobe-Japan1-UCS2", mimeType="application/octet-stream")]
		private var _adobe_Japan1_UCS2Class:Class;

		[Embed(source="cmap/90ms-RKSJ-UCS2", mimeType="application/octet-stream")]
		private var _90ms_RKSJ_UCS2Class:Class;

		private var _cmapStore:KeyValueStore;
		private var _defaultCmapStore:KeyValueStore;
		private var _msCmapStore:KeyValueStore;

		/**
		 * コンストラクタ
		 */
		public function CMapConverter(singleton:CMapConverterInternal)
		{
			super();
			if(!singleton)
				throw new Error("Singleton Error!");
				
			initialize();
		}
		
		/**
		 * 初期化
		 */
		public function initialize():void
		{
			var cmapByteArray:ByteArrayAsset = ByteArrayAsset(new _adobe_Japan1_UCS2Class());
			var cmapString:String = cmapByteArray.readUTFBytes(cmapByteArray.length);

			_cmapStore = CMapMapper.stringToArray(cmapString);
			_defaultCmapStore = _cmapStore;

			var msByteArray:ByteArrayAsset = ByteArrayAsset(new _90ms_RKSJ_UCS2Class());
			var msString:String = msByteArray.readUTFBytes(msByteArray.length);

			_msCmapStore = CMapMapper.stringToArray(msString);

		}
		
		/**
		 * 自クラスインスタンス(シングルトンです)
		 */
		public static function get instance():CMapConverter
		{
			return CMapConverterInternal.instance;
		}

		/**
		 * CMAPの変更
		 */
		public function changeCmap(value:KeyValueStore=null, encoding:String=null):void
		{
			if (value)
			{
				_cmapStore = value;
			}
			else if (encoding == "90ms-RKSJ")
			{
				_cmapStore = _msCmapStore;
			}
			else if (encoding == "Adobe-Japan1")
			{
				_cmapStore = _defaultCmapStore;
			}
			else
			{
				_cmapStore = _defaultCmapStore;
			}
		}
		
		/**
		 * 現在使用しているCMAPがデフォルト(Adobe-Japan1-UCS2)かどうか
		 */
		public function isDefaultCmap():Boolean
		{
			return (_cmapStore === _defaultCmapStore);
		}
		
		/**
		 * ユニコード文字へ変換します。
		 * 
		 * @param 対象のコード
		 * @return ユニコード文字
		 */
		public function covertToUnicode(cd:String):String
		{
			var cmapArray:Array = _cmapStore.getObjectList(Number("0x" + cd));
			if (!cmapArray || cmapArray.length <= 0) return "";
			return cmapArray[0].value;
		}
	}
}
import jp.co.genephics.pavo.pdf.parser.cmap.CMapConverter;
class CMapConverterInternal
{
    public static var instance:CMapConverter
        = new CMapConverter(new CMapConverterInternal());
}
