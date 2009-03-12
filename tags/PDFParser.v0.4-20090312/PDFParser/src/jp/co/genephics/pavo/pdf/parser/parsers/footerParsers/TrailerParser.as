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

package jp.co.genephics.pavo.pdf.parser.parsers.footerParsers
{
	import flash.utils.ByteArray;
	
	import jp.co.genephics.pavo.pdf.parser.constants.PdfConst;
	import jp.co.genephics.pavo.pdf.parser.models.Trailer;
	import jp.co.genephics.pavo.pdf.parser.parsers.CommentParser;
	import jp.co.genephics.pavo.pdf.parser.parsers.DictionaryParser;
	import jp.co.genephics.pavo.pdf.parser.utils.Judgement;
	import jp.co.genephics.utils.StringUtil;
	
	
	public class TrailerParser
	{
		public function TrailerParser()
		{
		}

		public function parse(target:ByteArray):Trailer
		{
			// startxref と trailerを取り出す
			var trailer:Trailer;
			var endFlag:Boolean = false;
			var index:uint=target.position;
			var basePosition:int = index;
			
			for (; index<target.length; index++)
			{
				// trailer
				if (target.length - PdfConst.EOF.length < index)
					break;
			
				if (Judgement.isStartEof(target, index))
				{
					target.position = basePosition + PdfConst.TRAILER.length;
					
					var data:ByteArray = new ByteArray();
					target.readBytes(data, 0, index - basePosition - PdfConst.TRAILER.length);
					
					trailer = _devideElements(data);
					
					endFlag = true;
					break;
				}
			}

			if (!endFlag)
			{
				throw new Error("illegal file format !!!(trailerの終端なし)");
			}
			
			return trailer;
		}

		/**
		 * @private
		 * 各要素に分割し格納する
		 */
		private function _devideElements(data:ByteArray):Trailer
		{
			if (!data || data.length <= 0) return null;

			var l_length:int = 0;
			
			var pos:int = data.position;
			data.position = 0;
			
			var parser:DictionaryParser = new DictionaryParser(Trailer.TYPE, data);

			var array:Array = parser.extract(0);
			var model:Trailer = array[1] as Trailer;
			model.startxref = StringUtil.trim(_extractStartXref(data, array[0]));
			
			trace("--- TRAILER INFO ---");
			trace("encrypt  :"+model.encrypt);
			trace("id       :"+model.id);
			trace("info     :"+model.info);		// info オブジェクトのID
			trace("prev     :"+model.prev);		// xref の位置 (複数の場合)
			trace("root     :"+model.root);		// root となるオブジェクトのID
			trace("size     :"+model.size);		// XRef の項目数
			trace("xrefstm  :"+model.xrefstm);
			trace("startxref:"+model.startxref);	// 0はダミー
			trace("--- TRAILER INFO ---");
			return model;
		}
		
		/**
		 * @private
		 * StartXRef の取り出し
		 */
		private function _extractStartXref(data:ByteArray, position:int):String
		{
			var mode:Boolean = false;
			var value:String;
			
			for (; position<data.length; position++)
			{
				data.position = position;
				position = CommentParser.skipComment(data);
				if (Judgement.isStartKeyword(Trailer.START_XREF, data, position))
				{
					mode = true;
					position += Trailer.START_XREF.length;
				}
				
				if (mode)
				{
					if (Judgement.isWhiteSpace(data, position)) continue;
					
					data.position = position;
					value = data.readUTFBytes(data.length-position);
					break;
				}
			}
			return value;
		}

	}
}