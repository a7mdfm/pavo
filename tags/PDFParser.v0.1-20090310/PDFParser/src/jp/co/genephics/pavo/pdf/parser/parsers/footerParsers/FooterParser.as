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
	import jp.co.genephics.pavo.pdf.parser.models.Footer;
	import jp.co.genephics.pavo.pdf.parser.models.Trailer;
	import jp.co.genephics.pavo.pdf.parser.models.XRef;
	import jp.co.genephics.pavo.pdf.parser.utils.Judgement;
	
	
	/**
	 * フッター部（xref + trailer）を解析します。<br />
	 * ファイルのバイナリデータの終端から startxref を探し、ファイル内のすべてのフッターを解析します。
	 * 
	 * @author genephics design Inc.
	 */
	public class FooterParser
	{
		
		private var _xrefParser:XRefParser;
		
		public function FooterParser()
		{
		}
		
		/**
		 * フッターを解析します。手順は以下の通り。
		 *  <pre>
		 *  ・target の終端から最初の"startxref"を検出
		 *  ・最後(つまりPDFファイルの先頭側)のフッターを解析
		 *  ・最後から二番目のフッターを解析
		 *  ・最後からN番目のフッターを解析
		 *  ・最初(つまりPDFファイルの終端側)のフッターを解析
		 *  </pre>
		 * 
		 * @param target PDFファイルのバイナリデータ
		 * @return Footer フッター情報
		 */
		public function parse(target:ByteArray):Footer
		{
			var i:int = target.length-1;
			
			var startXref:String = "";
			
			for (; i >= 0; i--)
			{

				if (Judgement.isStartKeyword(PdfConst.START_XREF, target, i))
				{
					// startxref の値と
					var tmp:int = i + PdfConst.START_XREF.length;
					
					target.position = tmp;

					while(1)
					{
						var data:String = target.readUTFBytes(1);
						if (!isNaN(Number(data)))
						{
							startXref += data;
						}
						else if (startXref != "")
						{
							break;
						}
					}
					trace("[FILE_END_TRAILER]startXref:"+Number(startXref));
					break;
				}
				
				if (Judgement.isStartKeyword(PdfConst.OBJ, target, i))
				{
					// ボディ部に入ったのでエラー終了
					// TODO: エラー処理
					break;
				}
			}
			
			// 順にフッターを解析しよう
			var nextFooterOffset:Number = Number(startXref);
			
			var footer:Footer = new Footer();
			footer.xrefList = [];
			footer.trailer = new Trailer();
			
			while(1)
			{
				
				footer.xrefList = footer.xrefList.concat(_parseXRef(target, nextFooterOffset));
				
				var tmpTrailer:Trailer = _parseTrailer(target);
				
				footer.trailer = _updateTrailer(footer.trailer, tmpTrailer);
				
				if (tmpTrailer.prev)
				{
					nextFooterOffset = Number(tmpTrailer.prev);
				}
				else
				{
					break;
				}
			}
			
			//-----------------------
			// パフォーマンス改善
			// xrefArrayのキーをobjectIDにする
			var xrefArray:Array = footer.xrefList;
			var newXrefArray:Array = [];
			for each (var xref:XRef in xrefArray)
			{
				newXrefArray[xref.objectID] = xref;
			}
			footer.xrefList = newXrefArray;
			//-----------------------
			
			
			if (!_checkSize(footer))
			{
				trace("Bad Size!!");
			}
			
			return footer;
		}

		private function _updateTrailer(trailer:Trailer, tmpTrailer:Trailer):Trailer
		{
			if (!trailer.encrypt) trailer.encrypt = tmpTrailer.encrypt;
			if (!trailer.id) trailer.id = tmpTrailer.id;
			if (!trailer.info) trailer.info = tmpTrailer.info;
			if (!trailer.prev) trailer.prev = tmpTrailer.prev;
			if (!trailer.root) trailer.root = tmpTrailer.root;
			if (!trailer.size) trailer.size = tmpTrailer.size;
			if (!trailer.xrefstm) trailer.xrefstm = tmpTrailer.xrefstm;
			if (trailer.startxref == "0") trailer.startxref = tmpTrailer.startxref;
			
			return trailer;
		}

		private function _checkSize(footer:Footer):Boolean
		{
			if (footer.xrefList.length == Number(footer.trailer.size))
			{
				return true;
			}
			else
			{
				return false;
			}
		}

		/**
		 * @private
		 * Trailerを発見し解析する。終端は%%EOF。
		 * 
		 * @param xrefIndex Trailerの検索開始位置
		 * @return Trailer 解析結果
		 */
		private function _parseTrailer(target:ByteArray):Trailer
		{
			var parser:TrailerParser = new TrailerParser();
			return parser.parse(target);
		}
		
		/**
		 * @private
		 * パラメーターの開始位置ちょうどからXREFが始まっていた場合はXREFを解析する。
		 * 
		 * @param xrefIndex XRefの開始位置
		 * @return Dictionary 解析結果
		 */
		private function _parseXRef(target:ByteArray, position:int):Array
		{
			target.position = position;
			if (!_xrefParser) _xrefParser = new XRefParser(target);
			return _xrefParser.parse();
		}

	}
}