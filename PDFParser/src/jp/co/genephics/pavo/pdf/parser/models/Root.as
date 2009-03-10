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

package jp.co.genephics.pavo.pdf.parser.models
{
	/**
	 * カタログオブジェクト(Root)
	 * 
	 * @author genephics design, Inc.
	 */
	public class Root extends XRef
	{
		
		/**
		 * この辞書が記述するPDFオブジェクトのタイプ
		 */		
		public var type:String;

		/**
		 * PDFのバージョン
		 */		
		public var version:String;

		/**
		 * ページツリーのルートであるページツリーノード
		 */		
		public var pages:String;

		/**
		 * キーにページインデックス、値にページラベル辞書を持つ数値ツリー
		 */		
		public var pageLabels:String;

		/**
		 * 文書の名前
		 */		
		public var names:String;

		/**
		 * 名前に対応するあて先
		 */		
		public var dests:String;

		/**
		 * 文書の画面表示方法を定義する
		 */		
		public var viewerPreferences:String;

		/**
		 * 文書を開いたときに使用されるレイアウト
		 */		
		public var pageLayout:String;

		/**
		 * 文書を開いたときの表示方法
		 */		
		public var pageMode:String;

		/**
		 * 文書のアウトライン階層のルート
		 */		
		public var outlines:String;

		/**
		 * 文書のアーティクル・スレッド辞書の配列
		 */		
		public var threads:String;

		/**
		 * 文書が開かれたときに表示されるあて先、または実行されるアクション
		 */		
		public var openAction:String;

		/**
		 * トリガイベントの結果として実行される追加アクションの辞書
		 */		
		public var aA:String;

		/**
		 * 文書レベルのURIアクションの情報を含む
		 */		
		public var uRI:String;

		/**
		 * 文書の対話フォーム辞書
		 */		
		public var acroForm:String;

		/**
		 * 文書のメタデータを含む
		 */		
		public var metadata:String;

		/**
		 * 文書の構造ツリーのルート
		 */		
		public var structTreeRoot:String;

		/**
		 * 文書のTagged PDF表現の使い方を含むマーク情報辞書
		 */		
		public var markInfo:String;

		/**
		 * 文書中のテキストで使われている自然言語
		 */		
		public var lang:String;

		/**
		 * Acrobat Web Capture(AcroSpider)プラグインが使用する、状態を含むウェブキャプチャ情報
		 */		
		public var spiderInfo:String;

		/**
		 * 文書が描画される出力デバイスの色の特性を定義する出力目的辞書の配列
		 */		
		public var outputIntents:String;
	}
}