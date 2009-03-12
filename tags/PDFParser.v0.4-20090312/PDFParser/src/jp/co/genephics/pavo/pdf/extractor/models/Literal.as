package jp.co.genephics.pavo.pdf.extractor.models
{
	public class Literal
	{
		/**
		 * 0から始まるページ番号
		 */
		public var page:int;
		
		/**
		 * ソート用キー。[{ページ番号4桁}{9999-Y座標4桁}{X座標4桁}]<br />
		 * ※Y座標はページ下端からの座標なので9999から引いた値を採用する。
		 */
		public var sortKey:int;
		
		/**
		 * リテラル文字列
		 */
		public var literal:String;
		
		/**
		 * アウトライン情報かどうか
		 * trueならアウトライン、falseならコンテンツ文書文字列
		 */
		public var isOutline:Boolean;
	}
}