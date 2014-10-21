package com.pp.core.helper
{
	import flash.utils.getQualifiedClassName;

	public class ObjectHelper
	{
		public static function traceObject( obj:Object ):void
		{
			for ( var key:* in obj ) trace("obj[", key, "] = ", obj[key] + "\n") ;
		}
		
		public static function getShortClassName( obj:Object ):String
		{
			var splits:Array = getQualifiedClassName( obj ).split("::") ;
			return splits[ splits.length - 1 ] ;
		}
		
		public static function mergeObjects( originObj:Object, mergedObj:Object, ignoreOrigin:Boolean = true ):Object
		{
			for ( var key:* in mergedObj ) 	
			{
				if ( "key" in originObj )
				{
					if ( ignoreOrigin ) continue ;
				}
				originObj[ key ] = mergedObj[ key ] ;
			}
			return originObj ;
		}
	}
}