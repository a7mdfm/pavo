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
	import jp.co.genephics.pavo.pdf.parser.models.Destination;
	import jp.co.genephics.utils.StringUtil;
	
	/**
	 * Destエントリに関するユーティリティ。
	 * 
	 * @author genephics design, Inc.
	 */
	public class DestinationUtil
	{
		/**
		 * top(Y座標)の上限値
		 */
		public static const MAX_TOP:int = 9999;
		
		/**
		 * Destエントリを読み、結果をObjectで返します。<br />
		 * 
		 * @param Destエントリの値
		 * @return 読み取った結果
		 */
		public static function devideDestinationValue(value:String):Destination
		{
			value = StringUtil.trim(value);
			if (value.indexOf("[") == 0)
			{
				value = value.substr(1,value.length-1);
			}
			if (value.lastIndexOf("]") == value.length-1)
			{
				value = value.substr(0, value.length-1);
			}
			
			var regExp:RegExp = /([0-9]+\s[0-9]\sR)(\/XYZ\s(.+)\s(.+)\s(.+)|\/FitBH\s(.+)|\/FitBV\s(.+)|\/FitH\s(.+)|\/FitV\s(.+)|\/FitR\s(.+)\s(.+)\s(.+)\s(.+)|\/FitB|\/Fit)/;
			
			var retArray:Array = regExp.exec(value);
			
			var reg:RegExp = /\/[a-zA-Z]+/;
			
			var key:Array = reg.exec(retArray[2]);
			
			var ret:Destination = new Destination();
			ret.data = retArray[0];
			ret.objectId = retArray[1];

			ret.type = key[0];
			ret.left = 0;
			ret.top = MAX_TOP;
			ret.z = 0;
			
			switch (ret.type)
			{
				case Destination.XYZ:
					ret.left = Number(retArray[3]);
					ret.top = Number(retArray[4]);
					ret.z = Number(retArray[5]);
					break;
				case Destination.FITBH:
					ret.top = Number(retArray[6]);
					break;
				case Destination.FITBV:
					ret.top = Number(retArray[7]);
					break;
				case Destination.FITH:
					ret.top = Number(retArray[8]);
					break;
				case Destination.FITV:
					ret.top = Number(retArray[9]);
					break;
				case Destination.FITR:
					ret.left = Number(retArray[10]);
					ret.top = Number(retArray[13]);
					break;
				case Destination.FITB:
					break;
				case Destination.FIT:
					break;
			}
			return ret;
		}
	}
}