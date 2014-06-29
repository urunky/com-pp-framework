package com.pp.parse
{
	public class ParseBatchObject
	{
		public static function make( log:IParseLog, method:String, path:String ):ParseBatchObject
		{
			var obj:ParseBatchObject = ParseBatchObject.pick() ;
			obj.log = log ;
			obj.method = method ;
			obj.path = path ;
			return obj ;
		}
		
		private static var _queue:Array = null ;
		public static function get queue():Array								
		{	
			if ( _queue == null )  _queue = [ new ParseBatchObject  ] ;
			return _queue ;	
		}
		
		public static function pick():ParseBatchObject
		{
			if ( queue.length == 0 ) return new ParseBatchObject ;
			return queue.shift() as ParseBatchObject ;
		}
		
		public static const POST:String = "POST" ;
		public static const PUT:String = "PUT" ;
		public static const DELETE:String = "DELETE" ;
		
		private var _method:String ;
		public function get method():String						{	return _method;	}
		public function set method(value:String):void			{	_method = value;	}

		private var _path:String ;
		public function get path():String						{	return _path;	}
		public function set path(value:String):void				{	_path = value;	}

		public function get body():Object						{	return _log.toObj() ;	}
		
		private var _log:IParseLog 
		public function get log():IParseLog						{	return _log;	}
		public function set log(value:IParseLog):void			{	_log = value;	}

		public function ParseBatchObject( log:IParseLog = null, method:String = "", path:String = "" )
		{
			_log = log ;
			_method = method ;
			_path = path ;
		}
	}
}