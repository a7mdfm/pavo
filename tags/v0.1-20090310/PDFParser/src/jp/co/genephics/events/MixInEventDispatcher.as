/*
* MixInEventDispatcher
* 
* @author		: gd incorporated.
* @version		: 1.0.0
* @update		: -
*/

package jp.co.genephics.events {
	import flash.events.EventDispatcher;
	
	/**
	 * MixInEventDispatcherは、EventDispatcherを継承したいけれども継承できない場合にMixIn実装するクラスです。<br>
	 * @example 
	 * <listing version="3.0" >
	 * import jp.co.genephics.events.MixInEventDispatcher;
	 * public class Hoge{
	 * 	public function Hoge(){
	 * 		MixInEventDispatcher.initialize(this);
	 * 	}
	 * }
	 * </listing>
	 */
	public class MixInEventDispatcher{
		
		/**
		 * インスタンスにEventDispatcherを実装します
		 * @param	instance : 実装したいインスタンス
		 */
		public static function initialize(instance:*):void{
			var l_eventDispatcher:EventDispatcher = new EventDispatcher();
			instance.dispatchEvent = l_eventDispatcher.dispatchEvent;
			instance.addEventListener = l_eventDispatcher.addEventListener;
			instance.hasEventListener = l_eventDispatcher.hasEventListener;
			instance.removeEventListener = l_eventDispatcher.removeEventListener;
			instance.willTrigger = l_eventDispatcher.willTrigger;
		}
		
	}
}
