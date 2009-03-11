/**
 * copyright kaw( http://d.hatena.ne.jp/toytools/ )
 */
package jp.co.genephics.pavo.pdf.parser.cmap
{
    import flash.utils.Dictionary;
    
    /**
     * Objectなど何でもキーにして、値を管理します。
     * ある値からある値の間に入っているオブジェクトのリストなどを
     * ちょっぱやで取得できます。
     * @author kaw( toytools ).
     */
    public class KeyValueStore 
    {
        
        //------- CONST ------------------------------------------------------------------------
        //------- MEMBER ------------------------------------------------------------------------
        private var _list:Array;
        private var _objectDict:Dictionary;
        //------- PUBLIC ---------------------------------------------------------------------

		public function get list():Array
		{
			return _list;
		}

        /**
         * 
         */
        public function KeyValueStore() 
        {
            clear();
        }
        
        
        /**
         * 内部データを全て削除.
         */
        public function clear():void {
            _list = new Array();
            _objectDict = new Dictionary();
        }
        
        
        /**
         * データの追加.
         * @param	obj
         * @param	numericValue
         */
        public function add( obj:* , numericValue:Number ):void {
            if ( _objectDict[obj] != undefined ) {
                throw new Error("KeyValueStore.add()  Error::既に存在するキーです.");
            }
            var keyValueStoreItem:KeyValueStoreItem = new KeyValueStoreItem( obj , numericValue );
            _objectDict[obj] = keyValueStoreItem;
            var bsResult:BinarySearchResult = _doCustomBinarySearch( numericValue );
            var insertTarget:int = ( bsResult.isFinded() ) ? bsResult.getMinIndex() : bsResult.getMaxIndex();
            _list.splice( insertTarget , 0 , keyValueStoreItem );
        }
        
        
        /**
         * 値の更新.
         * @param	obj
         * @param	numericValue
         */
        public function update( obj:* , numericValue:Number ):void {
            var keyValueStoreItem:KeyValueStoreItem = _objectDict[obj] as KeyValueStoreItem;
            if ( keyValueStoreItem == null ) {
                throw new Error("KeyValueStore.update()  更新対象のオブジェクトが見つかりません.");
            }
            remove( obj );
            add( obj , numericValue );
        }
        
        
        /**
         * 削除.
         * @param	obj
         */
        public function remove( obj:* ):void {
            var keyValueStoreItem:KeyValueStoreItem = _objectDict[obj] as KeyValueStoreItem;
            delete _objectDict[obj];
            if ( keyValueStoreItem == null ) {
                return;
            }
            var bsResult:BinarySearchResult = _doCustomBinarySearch( keyValueStoreItem.numericValue );
            if ( !bsResult.isFinded() ) {
                return;
            }
            for ( var i:int = bsResult.getMinIndex() ; i <= bsResult.getMaxIndex() ; i++ ) {
                if ( KeyValueStoreItem( _list[i] ).obj == obj ) {
                    _list.splice( i , 1 );
                    return;
                }
            }
        }
        
        
        
        
        /**
         * NumericValueが特定の値の間のObjectのリストを取得する.
         * @param	minNumericValue
         * @param	maxNumericValue
         * @return
         */
        public function between( minNumericValue:Number , maxNumericValue:Number ):Array {
            var minBSResult:BinarySearchResult = _doCustomBinarySearch( minNumericValue );
            var maxBSResult:BinarySearchResult = _doCustomBinarySearch( maxNumericValue );
            
            var startIndex:int = minBSResult.isFinded() ? minBSResult.getMinIndex() : minBSResult.getMaxIndex();
            var endIndex:int   = maxBSResult.isFinded() ? maxBSResult.getMaxIndex() : maxBSResult.getMinIndex();
            
            var result:Array = new Array();
            for ( var i:int = startIndex ; i <= endIndex ; i++ ) {
                result.push( KeyValueStoreItem( _list[i] ).obj );
            }
            return result;
        }
        
        
        /**
         * ある特定のNumericValueのオブジェクトのリストを取得する.
         * @param	numericValue
         * @return
         */
        public function getObjectList( numericValue:Number ):Array {
            var result:Array = new Array();
            var bsResult:BinarySearchResult = _doCustomBinarySearch( numericValue );
            if ( !bsResult.isFinded() ) {
                return result;
            }
            for ( var i:int = bsResult.getMinIndex() ; i <= bsResult.getMaxIndex() ; i++ ) {
                result.push( KeyValueStoreItem( _list[i] ).obj );
            }
            return result;
        }
        
        
        /**
         * オブジェクトのNumericValueを取得する.
         * @param	obj
         */
        public function getNumericValue( obj:* ):Number {
            var keyValueStoreItem:KeyValueStoreItem = _objectDict[obj] as KeyValueStoreItem;
            if ( keyValueStoreItem == null ) {
                throw new Error("KeyValueStore.getNumericValue()  取得対象のオブジェクトが見つかりません.");
            }
            return keyValueStoreItem.numericValue;
        }
        
        
        //------- PRIVATE ---------------------------------------------------------------------
        /**
         * 
         * @param	numericValue
         * @return
         */
        private function _doCustomBinarySearch( numericValue:Number ):BinarySearchResult {
            var len:int = _list.length - 1;
            var min:int  = 0;
            var max:int  = len;
            var mid:int = Math.floor( (min + max) / 2 );
            //探索
            while(min <= max && KeyValueStoreItem( _list[mid] ).numericValue != numericValue){
                if( KeyValueStoreItem( _list[mid] ).numericValue > numericValue){
                    max = mid - 1;
                }else{
                    min = mid + 1;
                }
                mid = Math.floor( (min + max) / 2 );
            }
            //結果返却
            if ( min <= max ) {
                min = mid;
                max = mid;
                //最小INDEXを探す.
                while ( 0 < min && KeyValueStoreItem( _list[ min - 1 ] ).numericValue == numericValue ) {
                    min--;
                }
                //最大INDEXを探す.
                while ( max < len && KeyValueStoreItem( _list[ max + 1 ] ).numericValue == numericValue ) {
                    max++;
                }
                return new BinarySearchResult( min , max , true );
            }else {
                return new BinarySearchResult( Math.min( min , max ) , Math.max( min , max ) , false );
                
            }
        }
        
        //------- INTERNAL ---------------------------------------------------------------------
        
    }
    
}

/**
 * 内部バイナリーサーチの結果.
 */
class BinarySearchResult {
    private var _minIndex:int;
    private var _maxIndex:int;
    private var _isFinded:Boolean;
    public function BinarySearchResult( minIndex:int , maxIndex:int , isFinded:Boolean ):void {
        _minIndex = minIndex;
        _maxIndex = maxIndex;
        _isFinded = isFinded;
    }
    
    public function isFinded():Boolean {
        return _isFinded;
    }
    
    public function getMinIndex():int {
        return _minIndex;
    }
    public function getMaxIndex():int {
        return _maxIndex;
    }
    public function toString():String {
        return "min : " + _minIndex + "  max : " + _maxIndex;
    }
}



/**
 * KeyValueStore用に作成された内部保持クラス.
 */
class KeyValueStoreItem{
    private var _obj:*;
    private var _numericValue:Number;
    
    public function KeyValueStoreItem( obj:* , numericValue:Number ):void {
        _obj          = obj;
        _numericValue = numericValue;
    }
    
    public function get numericValue():Number {
        return _numericValue;
    }
    
    public function get obj():*{
        return _obj;
    }
    
    public function toString():String {
        return "NumericValue :: " + _numericValue + "    " + _obj;
    }
    
}
