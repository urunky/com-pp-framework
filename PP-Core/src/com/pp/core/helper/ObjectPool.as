package com.pp.core.helper
{
	public class ObjectPool
	{
		private var _poolables:Array ;
		public function get poolables():Array						{	return _poolables;	}
		public function get size():int								{	return _poolables.length ;}
		
		private var _newSize:int ;
		protected var _createFunc:Function 
		
		public function ObjectPool( newSize:int, createFunc:Function )
		{
			_createFunc = createFunc ;
			_poolables = [] ;
			var i:int ;
			for ( i = 0 ; i < newSize ; i++ )	_poolables[ _poolables.length ] = _createFunc()  ;
		}
		
		public function getOut():IPoolable
		{
			if ( _poolables.length > 0 )	
			{
				var poolable:IPoolable = _poolables.pop() ;
				poolable.activate() ;
				return poolable ;
			}
			return _createFunc() ;
		}
		
		public function putIn( poolable:IPoolable ):void
		{
			poolable.deactivate() ;
			_poolables.push( poolable ) ;
		}
	}
}