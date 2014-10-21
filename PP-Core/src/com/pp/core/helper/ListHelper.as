package com.pp.core.helper
{
	public class ListHelper
	{
		public static function applyFunc( list:Object, func:Function ):void
		{
			if ( list is Array || list is Vector.<*> )
			{
				var len:int = list["length"] ;
				for ( var i:int = 0; i < len; i++) func( list[ i ] ) ;
			}
			else
			{
				throw new Error("obj is Array or Vector ") ;
			}
		}
		
		public static function removeIn( list:Object, obj:Object ):void
		{
			if ( list is Array || list is Vector.<*> )
			{
				var idx:int = list["indexOf"]( obj ) ;
				if ( idx >= 0 ) list.splice( idx, 1 ) ;
			}
			else
			{
				throw new Error("obj is Array or Vector ") ;
			}
		}
	}
}