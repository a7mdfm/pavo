/**
* StringUtil
* 
* @author		: gd incorporated.
* @version		: 1.0.21
* @update		: -
*/

package jp.co.genephics.utils {
	/**
	 * StringUtil は、ストリング関連の静的ユーティリティクラスです。<br>
	 */
	public class StringUtil {
		
		/**
		 * エンティティコードに置換
		 * @param	char : 置換したい文字列
		 * @return	String : エンティティコードに置換された文字列
		 */
		public static function replaceEntitiesFromString(char:String):String{
			var lstr:String = char.replace(new RegExp("\&", "gi"), "&amp;");
			lstr = lstr.replace(new RegExp("\<", "gi"), "&lt;");
			lstr = lstr.replace(new RegExp("\>", "gi"), "&gt;");
			lstr = lstr.replace(new RegExp("\"", "gi"), "&quot;");
			lstr = lstr.replace(new RegExp("\'", "gi"), "&#039;");
			return lstr;
		}
		
		/**
		 * エンティティコードを実体に置換
		 * @param	char : 置換したい文字列
		 * @return	String : エンティティコードが実体に置換された文字列
		 */
		public static function replaceStringFromEntities(char:String):String{
			var lstr:String = char.replace(new RegExp("\&lt;", "gi"), "\<");
			
			lstr = lstr.replace(new RegExp("\&gt;", "gi"), "\>");
			lstr = lstr.replace(new RegExp("\&quot;", "gi"), "\"");
			lstr = lstr.replace(new RegExp("\&#039;", "gi"), "\'");
			lstr = lstr.replace(new RegExp("\&amp;", "gi"), "\&");
			return lstr;
		}
		
		/**
		 * 数値を3桁区切りに置換する。（1000000→1,000,000）
		 * @param	char : 置換したい文字列
		 * @return	String : 3桁区切りの文字列
		 */
		public static function separateThousands(char:String):String{
			var l_ptrn:RegExp = /(\d{1,3})(?=(?:\d\d\d)+(?!\d))/g;
			return char.replace(l_ptrn, "$&" + ",");
		}
		
		/**
		 * 左右の全角半角空白を削除
		 * @param	char : 文字列
		 * @return	String : 左右の全角半角空白を除いた文字列
		 */
		public static function trim(char:String):String{
			if(char == null) return null;
			//return StringUtil.ltrim(StringUtil.rtrim(char));
			return rtrim(ltrim(char));
		}
		
		/**
		 * 左側の全角半角空白を削除
		 * @param	char : 文字列
		 * @return	String : 左側の全角半角空白を除いた文字列
		 */
		public static function ltrim(char:String):String{
			/*
			var size:Number = char.length;
			for(var i:Number = 0; i < size; i++){
				if(char.charCodeAt(i) > 32){
					return char.substring(i);
				}
			}
			return "";
			*/
			if(char == null) return null;
			var l_ptrn:RegExp = /^\s*/;
			return char.replace(l_ptrn, "");
		}
		
		/**
		 * 右側の全角半角空白を削除
		 * @param	char : 文字列
		 * @return	String : 右側の全角半角空白を除いた文字列
		 */
		public static function rtrim(char:String):String{
			/*
			var size:Number = char.length;
			for(var i:Number = size; i > 0; i--){
				if(char.charCodeAt(i - 1) > 32){
					return char.substring(0, i);
				}
			}
			return "";
			*/
			if(char == null) return null;
			var l_ptrn:RegExp = /\s*$/;
			return char.replace(l_ptrn, "");
		}
		
		/**
		 * 文字列の比較
		 * @param	char1 : 比較したい文字列1
		 * @param	char2 : 比較したい文字列2
		 * @param	caseSensitive : 大文字・小文字の区別
		 * @return	Boolean : 比較結果
		 */
		public static function equals(char1:String, char2:String, caseSensitive:Boolean):Boolean{
			if(caseSensitive){
				return char1 == char2;
			}
			return (char1.toUpperCase() == char2.toUpperCase());
		}
		
		/**
		 * 文字列から文字列を削除する
		 * @param	input : 文字列
		 * @param	remove : 削除したい文字列
		 * @return	String : 削除した後の文字列
		 */
		public static function remove(input:String, remove:String):String{
			return StringUtil.replace(input, remove, "");
		}
		
		/**
		 * 文字列を置換する
		 * @param	input : 対象の文字列
		 * @param	replace : 置換したい文字列
		 * @param	replaceWith : 置換後の文字列
		 * @return	String : 置換された後の文字列
		 */
		public static function replace(input:String, replace:String, replaceWith:String):String{
			var sb:String = new String();
			var found:Boolean = false;
			var sLen:Number = input.length;
			var rLen:Number = replace.length;
			for (var i:Number = 0; i < sLen; i++){
				if(input.charAt(i) == replace.charAt(0)){   
					found = true;
					for(var j:Number = 0; j < rLen; j++){
						if(!(input.charAt(i + j) == replace.charAt(j))){
							found = false;
							break;
						}
					}
					if(found){
						sb += replaceWith;
						i = i + (rLen - 1);
						continue;
					}
				}
				sb += input.charAt(i);
			}
			return sb;
		}
		
		/**
		 * 文字列に含まれるURIを全てアンカータグ<a href="URI">URI</a>に置換する
		 * @param	char : 文字列
		 * @return	String : アンカータグに置換された文字列
		 */
		public static function replaceAnchor(char:String):String{
			var l_ptrn:RegExp = /(https?|ftp)(:\/\/[\w\+\$\;\?\-\/\.%,!#~*:@&=]+)/g;
			if(l_ptrn.exec(char) == null) return char;
			var l_m:String = l_ptrn.exec(char)[0];
			return char.replace(l_ptrn, '<a href="'+l_m+'">'+l_m+'</a>');
		}
		
		/**
		 * 文字列に含まれるアンカータグを全て TextEvent に置換する
		 * @param	char : 文字列
		 * @return	String : TextEvent に置換された文字列
		 */
		public static function replaceTextEvent(char:String):String{
			//var l_ptrn:RegExp = /<a href=["'](.*?)["']/gi;
			var l_ptrn:RegExp = /(<a href=)["'](.*?)["']/gi;
			var l_arr:Array = l_ptrn.exec(char)
			if(l_arr == null) return char;
			return char.replace(l_ptrn, '<a href="event:$2"');
		}
		
		/**
		 * 文字列から改行文字を取り除く
		 * @param	char : 文字列
		 * @return	String : 改行文字が取り除かれた文字列
		 */
		public static function stripLineFeed(char:String):String{
			var l_ptrn:RegExp = /\x0D\x0A|\x0D|\x0A/;
			return char.replace(l_ptrn, "");
		}
		
		/**
		 * 文字列がすべて数字かどうか判定する
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isNumber(char:String):Boolean{
			// /[0-9]+$/
			if(char == null) return false;
			return ! isNaN(Number(char));
		}
		
		/**
		 * 文字列が何もないか判定する（改行コード含む）
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isWhitespace(char:String):Boolean{
			switch(char){
				case " ":
				case "\t":
				case "\r":
				case "\n":
				case "\f":
				return true;
				default:
				return false;
			}
		}
		
		/**
		 * 文字列が正しいメールアドレスか判定する
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isMailAddress(char:String):Boolean{
			return isMatch(char, /(\w|[_.\-])+@((\w|-)+\.)+\w{2,4}+/);
		}
		
		/**
		 * 文字列がアルファベットだけで構成されているか判定する
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isAlphabet(char:String):Boolean{
			return isMatch(char, /^[A-Za-z]+$/);
		}
		
		/**
		 * 文字列が半角英数記号だけで構成されているか判定する
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isHankakuEisuKigo(char:String):Boolean{
			return isMatch(char, /[!-~]/);
		}
		
		/**
		 * 文字列が正しい郵便番号か判定する（xxx-xxxx）
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isPostCode(char:String):Boolean{
			return isMatch(char, /^\d{3}\-\d{4}$/);
		}
		
		/**
		 * 文字列が正しい電話番号か判定する（{2～4桁}-{2～4桁}-{4桁}）
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isTelePhone(char:String):Boolean{
			return isMatch(char, /^\d{2,4}\-\d{2,4}\-\d{4}$/);
		}
		
		/**
		 * 文字列がひらがなだけで構成されているか判定する
		 * @param	char : 文字列
		 * @return	Boolean : 結果
		 */
		public static function isHiragana(char:String):Boolean{
			return isMatch(char, /^[あ-ん]+$/);
		}
		
		/**
		 * 共通の正規表現マッチメソッド
		 * @param	char : 文字列
		 * @param	pattern : 正規表現パターン
		 * @return	Boolean : 結果
		 */
		private static function isMatch(char:String, pattern:RegExp):Boolean{
			if(char.match(pattern) == null){
				return false;
			}
			return true;
		}
		
		/**
		 * 指定文字数まで先頭ゼロ詰め
		 * @param  char : 文字列
		 * @param  len  : 文字数
		 * @return String : ゼロパディング後文字列
		 */
		public static function zeroPaddingLeft(char:String, len:int):String{
			if(!char || char.length <= 0) return char;
			while(char.length < len){
				char = "0" + char;
			}
			return char;
		}
	}
	
}
