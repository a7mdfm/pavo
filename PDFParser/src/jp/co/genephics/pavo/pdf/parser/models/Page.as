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
	import __AS3__.vec.Vector;
	
	/**
	 * Pageオブジェクト
	 * 
	 * @author genephics design, Inc.
	 */
	public class Page extends XRef
	{
		public function Page()
		{
			super();
			outlines = new Vector.<Outline>();
			contentsTextArray = [];
		}

		/**
		 * PDFオブジェクトのタイプ('Page'固定)
		 */		
		public var type:String;
		
		/**
		 * 親のPageオブジェクト
		 */
		public var parent:String;
		
		/**
		 * 最終更新日時
		 */
		public var lastModified:String;
		
		/**
		 * リソース辞書
		 */
		public var resources:String;
		
		/**
		 * 出力可能最大領域
		 */
		public var mediaBox:String;
		
		/**
		 * ページの内容が表示又は印刷されるときにクリッピングされる領域
		 */
		public var cropBox:String;
		
		/**
		 * 制作環境での出力時にページの内容がクリッピングされることになる領域
		 */
		public var bleedBox:String;
		
		/**
		 * トリミング後の完成ページで意図する寸法
		 */
		public var trimBox:String;
		
		/**
		 * 作成社が意図するページの意味がある内容の範囲
		 */
		public var artBox:String;
		
		/**
		 * さまざまなページ境界を画面上に表示するのに使われる、色その他のビジュアル要素
		 */
		public var boxColorInfo:String;
		
		/**
		 * ページのコンテンツ。このエントリがない場合は、ページは空
		 */
		public var contents:String;
		
		/**
		 * 表示または印刷時に回転させる角度(時計回り)
		 */
		public var rotate:String;
		
		/**
		 * 透過イメージングモデルで使用されるページグループの属性を指定する辞書
		 */
		public var group:String;
		
		/**
		 * 	サムネイル画像を定義するストリーム
		 */
		public var thumb:String;
		
		/**
		 * 	ページに出現するアーティクルビーズ
		 */
		public var b:String;
		
		/**
		 * 	プレゼンテーション中、ビューアプリケーションが自動でページ替えするまでの秒単位の最長時間
		 */
		public var dur:String;
		
		/**
		 * プレゼンテーション中、ページ替え時に使用されるエフェクト
		 */
		public var trans:String;
		
		/**
		 * ページに関連づけられた注釈
		 */ 
		public var annots:String;
		
		/**
		 * ページが開かれたり閉じられたりしたときに実行される追加アクション
		 */
		public var aA:String;
		
		/**
		 * ページのメタデータを含むメタデータストリーム
		 */
		public var metadata:String;
		
		/**
		 * ページに関連づけられたページピース辞書
		 */ 
		public var pieceInfo:String;
		
		/**
		 * 構造ペアレントツリーにおけるページのエントリのキー
		 */
		public var structParents:String;
		
		/**
		 * 識別子
		 */  
		public var iD:String;
		
		/**
		 * ページの優先ズーム倍率
		 */
		public var pZ:String;
		
		/**
		 * 色分解辞書
		 */
		public var separationInfo:String;
		
		/**
		 * リソースオブジェクト
		 */
		public var resource:Resource;
		
		/**
		 * 設定されているアウトライン
		 */
		public var outlines:Vector.<Outline>;
		
		/**
		 * ページ内テキスト
		 */ 
		public var contentsTextArray:Array;
	}
}