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

package jp.co.genephics.pavo.pdf.parser.constants
{
	/**
	 * ステータス
	 */
	public class Status
	{
		public function Status(l_status:int, l_message:String)
		{
			super();
			status = l_status;
			message = l_message;
		}
		
		public var status:int;
		
		public var message:String;
		
		/**
		 * 解析状況(初期)
		 */
		public static const STATUS_INIT:Status = new Status(0, "");

		/**
		 * 解析状況(PDFファイルを開いている)
		 */
		public static const STATUS_PDF_OPEN:Status = new Status(1, "PDFファイル読込");

		/**
		 * 解析状況(ヘッダー読み取り)
		 */
		public static const STATUS_ANALYZE_HEADER:Status = new Status(10, "ヘッダー解析");

		/**
		 * 解析状況(フッター(XREF,Trailer)読み取り)
		 */
		public static const STATUS_ANALYZE_FOOTER:Status = new Status(20, "フッター(XRef,Trailer)解析");

		/**
		 * 解析状況(/Infoオブジェクト読み取り)
		 */
		public static const STATUS_ANALYZE_INFO:Status = new Status(30, "Infoエントリ解析");

		/**
		 * 解析状況(/Catalogオブジェクト読み取り)
		 */
		public static const STATUS_ANALYZE_CATALOG:Status = new Status(40, "カタログ辞書(Root)解析");

		/**
		 * 解析状況(オブジェクトの読み取り)
		 */
		public static const STATUS_ANALYZE_OBJECT:Status = new Status(50, "オブジェクトツリー解析");

		/**
		 * 解析状況(NamedDestオブジェクトの読み取り)
		 */
		public static const STATUS_ANALYZE_NAMED_DEST:Status = new Status(51, "宛先(Dests)解析");

		/**
		 * 解析状況(NamedDestオブジェクトの整列)
		 */
		public static const STATUS_CREATE_NAMED_DEST_MAP:Status = new Status(52, "宛先(Dests)整列");

		/**
		 * 解析状況(/Pages,/Pageオブジェクト読み取り)
		 */
		public static const STATUS_ANALYZE_PAGE_TREE:Status = new Status(53, "ページ(Page,Pages)解析");

		/**
		 * 解析状況(/Outlinesオブジェクト読み取り)
		 */
		public static const STATUS_ANALYZE_OUTLINE_TREE:Status = new Status(54, "しおり(Outlines)解析");

		/**
		 * 解析状況(/Resourcesオブジェクトの読み取り)
		 */
		public static const STATUS_ANALYZE_RESOURCE:Status = new Status(55, "リソース(Resources)解析");

		/**
		 * 解析状況(/Contentsオブジェクトの読み取り)
		 */
		public static const STATUS_ANALYZE_CONTENTS:Status = new Status(56, "コンテンツ解析");

		/**
		 * 解析状況(ユニコード文字列への変換)
		 */
		public static const STATUS_CONVERT_CHARCODE:Status = new Status(60, "ユニコード文字列取得");
		
	}
}