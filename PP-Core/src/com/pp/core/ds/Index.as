package com.pp.core.ds
{
	import com.pp.core.helper.ListHelper;
	
	public class Index
	{
		private var _all:Array ;
		public function get all():Array							{	return _all ;	}
		
		private var _cls:Class ;
		public function get cls():Class							{	return _cls;	}
		
		private var _hashByID:Object ;
		
		public function Index( cls:Class )
		{
			_cls = cls ;
			_all = [] ;
			_hashByID = {} ;
		}
		
		public function clear():void
		{
			_all.length = 0 ;
			_hashByID = {} ; 
		}
		
		public function reset( results:Array, needClear:Boolean = false ):void
		{
			if ( needClear ) clear() ;
			ListHelper.applyFunc( results, createAndAdd ) ;
			results.length = 0 ;
			results = null ;
		}
		
		public function createAndAdd( r:Object ):void
		{
			add( _cls["create"]( r )  )  ;
		}
		
		public function add( obj:Object ):void
		{
			if ( _all.indexOf( obj ) < 0 ) _all[ _all.length ] = obj ;
			if ( obj.hasOwnProperty("id") ) _hashByID[ String( obj.id ) ] = obj ;
		}
		
		public function remove( obj:Object ):void
		{
			var idx:int = _all.indexOf( obj ) ;
			if ( idx >= 0 ) _all.splice( idx, 1 ) ;
			if ( obj.hasOwnProperty("id") ) delete _hashByID[ String( obj.id ) ] ;
		}
		
		public function find( id:String ):Object
		{
			return _hashByID[ id ] ;
		}
	}
}