// =================================================================================================
// Jun 6, 2014
// =================================================================================================

package com.pp.parse
{
	import flash.events.TimerEvent;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;

	public class ParseManager
	{
		public static const PARSE_GET_LIMIT:int = 1000 ;
		
		private static var _current:ParseManager 
		public static function get current():ParseManager			{	return _current ;	}

		public static function make( appID:String, apiKey:String, sessionToken:String = "", onFailFunc:Function = null, onHttpResponseStatusFunc:Function = null, onIOErrorFunc:Function = null ):void
		{
			if ( _current == null ) 
			{
				_current = new ParseManager( appID, apiKey, sessionToken ) ;
				_current.onFailFunc = onFailFunc ;
				_current.onHttpResponseStatusFunc = onHttpResponseStatusFunc ;
				_current.onIOErrorFunc = onIOErrorFunc ;
			}
		}
		public static const PATH_PREFIX:String = "/1/classes/" ;
		public static const PARSE_API:String = "https://api.parse.com" + PATH_PREFIX ; ///1/classes/";
		public static const PARSE_BATCH_API:String = "https://api.parse.com/1/batch/";
		public static const PARSE_CLOUD_CODE:String = "https://api.parse.com/1/functions/";
		
		private var _appID:String ;
		private var _apiKey:String ;
		
		private var _sessionToken:String ;
		public function get sessionToken():String						{	return _sessionToken;	}
		public function set sessionToken(value:String):void				
		{	
			_sessionToken = value;	
			_parseCallPool = null ;
		}
		
		private var _parseCallPool:Array = null ;
		public function get parseCallPool():Array								
		{	
			if ( _parseCallPool == null ) _parseCallPool = [ makeParseCall() ] ;
			return _parseCallPool ;	
		}
		
		private var _onIOErrorFunc:Function 
		public function get onIOErrorFunc():Function						{	return _onIOErrorFunc;	}
		public function set onIOErrorFunc(value:Function):void				{	_onIOErrorFunc = value;	}

		private var _onHttpResponseStatusFunc:Function 
		public function get onHttpResponseStatusFunc():Function						{	return _onHttpResponseStatusFunc;	}
		public function set onHttpResponseStatusFunc(value:Function):void			{	_onHttpResponseStatusFunc = value;	}
		
		private var _onFailFunc:Function ; 
		public function get onFailFunc():Function							{	return _onFailFunc;	}
		public function set onFailFunc(value:Function):void					{	_onFailFunc = value;	}

		private var _delayedLogs:Array ;
		
		public function ParseManager( appID:String, apiKey:String, sessionToken:String = "")
		{
			_appID = appID ;
			_apiKey = apiKey ;
			_sessionToken = sessionToken ;
			_delayedLogs =[] ;
		}	
		
	
		private function makeParseCall():ParseCall
		{
			var parseCall:ParseCall = ParseCall.create( _appID, _apiKey, _sessionToken ) ;
			parseCall.onFailFunc = _onFailFunc ;
			parseCall.onHttpResponseStatusFunc = _onHttpResponseStatusFunc ;
			parseCall.onIOErrorFunc = _onIOErrorFunc ;
			return parseCall ;
		}
		
		public function callCloudFunc( compFunc:Function, functionName:String, params:Object = null ):void
		{
			var url:String = PARSE_CLOUD_CODE + functionName ;
			executeCall( compFunc, url, URLRequestMethod.POST, params, {} );
		}
		
		public function update( compFunc:Function, className:String, id:String, params:Object = null ):void
		{
			var url:String = PARSE_API +  className + "/" +id ;
			executeCall( compFunc, url, URLRequestMethod.PUT, params, null );
		}
		
		public function executeCall( compFunc:Function, url:String, method:String, params:Object = null, where:Object = null ):void 
		{ 
			var parseCall:ParseCall = pickAvaParseCall() ;// ParseCall.create( this, _appID, _apiKey, _sessionToken ) ;
			var onComp:Function = function( r:Object ):void
			{
				parseCallPool.push( parseCall );
				if ( compFunc != null ) compFunc( r ) ;
			}
			parseCall.call( onComp, url, method, params, where ) ;
		}
		
		public function batchLogs( compFunc:Function, logs:Array ):void
		{
			var requests:Array = [] ;
			while ( logs.length > 0 ) requests.push( logToBatchObj( logs.shift() )) ;
		
			var onComp:Function = function( results:Array  ):void
			{
				var i:int ;
				var len:int = requests.length ;
				var b:ParseBatchObject ;
				var r:Object ;
				for ( i = 0; i < len; i++) 
				{
					b = requests[ i ] ;
					r = results[ i ] ;
					if ( b.method == ParseBatchObject.POST )
					{
						if ( r.hasOwnProperty("success" ) )
						{
							( b as ParseBatchObject ).log.id = r.success.objectId ;
						}
					}
					b.log = null ;
					ParseBatchObject.queue.push( b ) ;
				}
				if ( compFunc ) compFunc() ;
			}
			batch( onComp, requests ) ;
		}
		
		public function find( compFunc:Function, className:String, id:String = "", params:Object = null, where:Object = null ):void
		{
			var url:String = url = PARSE_API + className ;
			if ( id != "" ) url += "/" + id ;
			executeCall( compFunc, url, URLRequestMethod.GET, params, where ) ;//, params, where  );
		}
		
		public function findAll( compFunc:Function, className:String, where:Object = null, skip:int = 0, results:Array = null ):void
		{
			if ( results == null ) results = [] ;
			
			var url:String = url = PARSE_API + className ;
			
			var onComp:Function = function( r:Object ):void
			{
				var newResults:Array = results.concat( r.results ) ;
				if ( r.results.length == PARSE_GET_LIMIT ) 
				{
					skip += PARSE_GET_LIMIT ;
					findAll( compFunc, className, { "limit":PARSE_GET_LIMIT, "skip":skip }, skip, newResults ) ;
				}
				else
				{
					compFunc( newResults ) ;
				}
			}
			executeCall( onComp, url, URLRequestMethod.GET, { "limit":PARSE_GET_LIMIT, "skip":skip }, where ) ;//, params, where  );
		}
		
		
		public function batch( compFunc:Function, requests:Array ):void
		{
			executeCall( compFunc, PARSE_BATCH_API, URLRequestMethod.POST, {"requests":requests } );
		}
		
		private function pickAvaParseCall():ParseCall
		{
			if ( parseCallPool.length == 0 ) return makeParseCall() ; //ParseCall.create( this, _appID, _apiKey, _sessionToken ) ;
			return parseCallPool.shift() as ParseCall ;
		}
		
		private function logToBatchObj( log:IParseLog ):ParseBatchObject 
		{
			var method:String = ParseBatchObject.POST ;
			var path:String = PATH_PREFIX + log.className ;
			
			if ( log.id != "" ) 
			{
				method = ParseBatchObject.PUT ; 
				path = path + "/" + log.id ;
			}
		//	if ( body.hasOwnProperty("pID") ) body.player = { "__type":"Pointer","className":"Player", "objectId":body.pID }  ;
		//	delete body.id ;
			trace("method, path", method, path ) ;
			return ParseBatchObject.make( log, method, path ) ;
		}
		
	
		public function applyResults( loggables:Array, results:Array ):void
		{
			var i:int ;
			var len:int = loggables.length ;
			var loggable:IParseLog ;
			var result:Object ;
			for ( i = 0; i < len; i++) 
			{
				loggable = loggables[ i ] ;
				result = results[ i ] ;
				if ( result.hasOwnProperty("success") )
				{
					if ( result.success.hasOwnProperty("objectId") )  loggable.id = result.success.objectId ;
				}
				else if ( result.hasOwnProperty("error") )
				{
					
				}
			}
		}
	}
}