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
	
	import jp.co.genephics.pavo.pdf.parser.constants.PdfConst;
	
	/**
	 * ByteArrayオブジェクトの指定の位置がPDFファイル構造の各区切り位置かどうかをジャッジするクラス。
	 * 
	 * @author genephics design Inc.
 	 */
	public class Judgement
	{
		/**
		 * コンストラクタ。
		 * 注）static 関数ばかりです。
		 */
		public function Judgement()
		{
			super();
		}
		
		/**
		 * ヘッダーが始まるかどうか。
		 * 
		 * @param targetSource 対象のデータ
		 * @return 判定結果
		 */
		public static function isStartHeader(targetSource:ByteArray, position:uint=0):Boolean
		{
			if (!targetSource ||
				targetSource.length - PdfConst.VERSION_INFO.length < position)
				return false;
			
			targetSource.position = position;
			return targetSource.readUTFBytes(PdfConst.VERSION_INFO.length) == PdfConst.VERSION_INFO;
		}
		
		/**
		 * EOFが始まるかどうか。
		 * 
		 * @param targetSource 対象のデータ
		 * @return 判定結果
		 */
		public static function isStartEof(targetSource:ByteArray, position:uint):Boolean
		{
			if (!targetSource ||
				targetSource.length - PdfConst.EOF.length < position)
				return false;
			
			targetSource.position = position;
			return targetSource.readUTFBytes(PdfConst.EOF.length) == PdfConst.EOF;
		}
		
		/**
		 * white-spacesかどうか
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isWhiteSpace(targetSource:ByteArray, position:uint):Boolean
		{
			var ret:Boolean = false;
			
			switch (targetSource[position])
			{
				case PdfConst.NULL:
				case PdfConst.TAB:
				case PdfConst.LINE_FEED_CODE:
				case PdfConst.FORM_FEED:
				case PdfConst.CARRIAGE_RETURN_CODE:
				case PdfConst.SPACE_CODE:
					ret = true;
					break;
				default:
					break;
			}
			return ret;
		}

		/**
		 * line feed かどうか
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isLineFeed(targetSource:ByteArray, position:uint):Boolean
		{
			return (targetSource[position] == PdfConst.LINE_FEED_CODE);
		}

		/**
		 * コメント行が始まるかどうか。
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isStartComments(targetSource:ByteArray, position:uint):Boolean
		{
			if (targetSource[position] == PdfConst.COMMENTS_SIGN)
			{
				if (isStartHeader(targetSource, position) ||
					isStartEof(targetSource, position))
				{
					return false;
				}
				return true;
			}
			return false;
		}
		
		/**
		 * xrefが始まるかどうか。
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isStartXref(targetSource:ByteArray, position:uint):Boolean
		{
			if (targetSource.length - PdfConst.XREF.length < position)
				return false;
			
			targetSource.position = position;
			
			if (targetSource.readUTFBytes(PdfConst.XREF.length) == PdfConst.XREF)
			{
				targetSource.position = position - 5; // "start"の長さ
				return (targetSource.readUTFBytes(PdfConst.START_XREF.length) != PdfConst.START_XREF);
			}
			return false;
		}
		
		/**
		 * trailerが始まるかどうか。
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isStartTrailer(targetSource:ByteArray, position:uint):Boolean
		{
			if (targetSource.length - PdfConst.TRAILER.length < position)
				return false;
			
			targetSource.position = position;
			return targetSource.readUTFBytes(PdfConst.TRAILER.length) == PdfConst.TRAILER;
		}
		
		/**
		 * Dictionaryが始まるかどうか。("<<"タグが出現するかどうか
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isStartBeginingOfDictionaryTag(targetSource:ByteArray, position:uint):Boolean
		{
			if (targetSource.length - PdfConst.BEGIN_DOUBLE_ANGLE_BRACKETS.length < position)
				return false;
			
			targetSource.position = position;
			return targetSource.readUTFBytes(PdfConst.BEGIN_DOUBLE_ANGLE_BRACKETS.length) == PdfConst.BEGIN_DOUBLE_ANGLE_BRACKETS;
		}

		/**
		 * Dictionaryが終わるかどうか。(">>"タグが出現するかどうか)
		 * 
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isStartEndingOfDictionaryTag(targetSource:ByteArray, position:uint):Boolean
		{
			if (targetSource.length - PdfConst.END_DOUBLE_ANGLE_BRACKETS.length < position)
				return false;
			
			targetSource.position = position;
			return targetSource.readUTFBytes(PdfConst.END_DOUBLE_ANGLE_BRACKETS.length) == PdfConst.END_DOUBLE_ANGLE_BRACKETS;
		}

		/**
		 * targetSource の position 番目からキーワード文字列が始まるかどうか。
		 * 
		 * @param keyword 対象のキーワード
		 * @param targetSource 対象のデータ
		 * @param position 判定するByteArrayの位置
		 * @return 判定結果
		 */
		public static function isStartKeyword(keyword:String, targetSource:ByteArray, position:uint):Boolean
		{
			if (!keyword || targetSource.length - keyword.length < position)
				return false;
			
			targetSource.position = position;
			return targetSource.readUTFBytes(keyword.length) == keyword;
		}

	}
}