package com.pp.parse
{
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequestMethod;
	import flash.utils.Timer;

	public class OldParseManager
	{
		private static var _current:OldParseManager = null 
		public static function get current():OldParseManager						{	return _current;	}

		public static function make( appID:String, apiKey:String, sessionToken:String = "", onFailFunc:Function = null):void						
		{	
			if ( _current == null ) _current = new OldParseManager( appID, apiKey, sessionToken, onFailFunc ) ;
		}

		public static const PARSE_API:String = "https://api.parse.com/1/classes/";
		public static const PARSE_BATCH_API:String = "https://api.parse.com/1/batch/";
		public static const PARSE_CLOUD_CODE:String = "https://api.parse.com/1/functions/";
		
		public static const PARSE_GET_LIMIT:int = 1000 ;
		
		private var _queue:Array = null ;
		public function get queue():Array								
		{	
			if ( _queue == null ) _queue = [ ParseCall.create( _appID, _apiKey, _sessionToken ) ] ;
			return _queue ;	
		}
		
		private var _appID:String ;
		private var _apiKey:String ;
		
		private var _sessionToken:String ;
		public function get sessionToken():String						{	return _sessionToken;	}
		public function set sessionToken(value:String):void				
		{	
			_sessionToken = value;	
			_queue = null ;
		}

		private var _executingLoggables:Array ;
		private var _pendingLoggables:Array ;
		private var _willExecuteLoggables:Array ;
		
		private var _onHTTPStatus404Func:Function 
		public function get onHTTPStatus404Func():Function						{	return _onHTTPStatus404Func;	}
		public function set onHTTPStatus404Func(value:Function):void						{	_onHTTPStatus404Func = value;	}

		private var _onFailFunc:Function 
		public function get onFailFunc():Function						{	return _onFailFunc;	}
		public function set onFailFunc(value:Function):void				{	_onFailFunc = value;	}

		private var _timer:Timer ;
		private var _loggables:Array ;
		
		private var _currentCall:ParseCall ;
		
		public function OldParseManager( appID:String, apiKey:String, sessionToken:String = "", onFailFunc:Function = null )
		{
			_appID = appID ;
			_apiKey = apiKey ;
			_sessionToken = sessionToken ;
			_executingLoggables = [] ;
			_pendingLoggables = [] ;
			_willExecuteLoggables = [] ;
			_loggables = [] ;
			_onFailFunc = onFailFunc ;
			
			_timer = new Timer( 1000, 1 ) ;
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComp ) ;
		}
	
		
		private function onTimerComp( e:TimerEvent ):void
		{
			_timer.stop() ;
			queueLoggables( null, _loggables ) ;
		}
		
		public function onFail( parseCall:ParseCall ):void
		{
			var onComp:Function = function():void
			{
				parseCall.retry() ;
			}
			onFailFunc( onComp ) ;	
			
			
		}
		
		public function retry():void
		{
			if ( _currentCall ) _currentCall.retry()  ;
		}
		
		public function applyLoggables( compFunc:Function, loggables:Array ):void
		{
			if ( compFunc != null )
			{
				queueLoggables( compFunc, loggables ) ;
			}
			else
			{
				_timer.reset() ;
				_timer.start() ;
				var loggable:IParseLog ;
				while ( loggables.length > 0 )
				{
					loggable = loggables.shift() ;
					if ( _loggables.indexOf( loggable ) < 0 ) _loggables.push( loggable ) ;
				}
			}
		}
		
		public function pickAvaParseCall():ParseCall
		{
			if ( queue.length == 0 ) return ParseCall.create( _appID, _apiKey, _sessionToken ) ;
			return queue.shift() as ParseCall ;
		}
		
		private function onComp():void
		{
			
		}
	
		public function queueLoggables( compFunc:Function, loggables:Array ):void
		{
			while ( loggables.length > 0 ) queueLoggable( loggables.shift() ) ;
			if ( _willExecuteLoggables.length > 0 ) executeLoggable( compFunc ) ;
		}
		
		public function queueLoggable( loggable:IParseLog ):void
		{
			if ( _pendingLoggables.indexOf( loggable ) >= 0  ) return ;
			
			if ( _executingLoggables.indexOf( loggable )  >= 0  ) 
			{
				_pendingLoggables.push( loggable ) ;
			}
			else
			{
				_willExecuteLoggables.push( loggable ) ;
				_executingLoggables.push( loggable ) ;
			}
		}
		
		private function executeLoggable( compFunc:Function ):void
		{
			var requests:Array = [] ;
			var parseBatchObj:Object ;
			var loggable:IParseLog ;
			var currentLoggables:Array = [] ;
		
			while ( _willExecuteLoggables.length > 0 )
			{
				loggable = _willExecuteLoggables.shift() ;
				currentLoggables.push( loggable ) ;
				//parseBatchObj = ParseBatchHelper.loggableToBatchObj( loggable ) ;
				requests.push( parseBatchObj ) ;
			}
			var onComp:Function = function( results:Array  ):void
			{
				//ParseBatchHelper.applyResults( currentLoggables, results ) ;
				proceedApplyLoggables( currentLoggables ) ;
				if ( _pendingLoggables.length > 0 )
				{
					var arr:Array = [] ;
					while ( _pendingLoggables.length > 0 ) arr.push( _pendingLoggables.shift() ) ;
					queueLoggables( compFunc, arr ) ;
				}
				else
				{
					if ( compFunc ) compFunc() ;
				}
			}
			batch( onComp, requests ) ;
		}
		
		private function proceedApplyLoggables( loggables:Array ):void
		{
			var i:int ;
			var len:int = loggables.length ;
			var loggable:IParseLog ;
			var idx:int ;
			while ( loggables.length > 0 )
			{
				loggable = loggables.shift() ;
				idx = _executingLoggables.indexOf( loggable ) ;
				if ( idx >= 0 ) _executingLoggables.splice( idx, 1 ) ;
			}
		}	
		
		public function batch( compFunc:Function, requests:Array ):void
		{
			executeQueue( compFunc, PARSE_BATCH_API, URLRequestMethod.POST, {"requests":requests }, {} );
		}
		
		public function executeCall( compFunc:Function, url:String, method:String, params:Object, where:Object ):void 
		{ 
			var parseCall:ParseCall = ParseCall.create( _appID, _apiKey, _sessionToken ) ;
			var onComp:Function = function( r:Object ):void
			{
				if ( compFunc != null ) compFunc( r ) ;
			}
			parseCall.call( onComp, url, method, where, params ) ;
		}
		
		private function executeQueue( compFunc:Function,  url:String, method:String, params:Object, where:Object ):void 
		{ 
			var parseCall:ParseCall = pickAvaParseCall() ;// new URLLoader();
			var onComp:Function = function( r:Object ):void
			{
				queue.push( parseCall ) ;
				if ( compFunc != null ) compFunc( r ) ;
			}
			parseCall.call( onComp, url, method, where, params ) ;
		}
		
		public function findByID( compFunc:Function, className:String, id:String ):void
		{
			var url:String = PARSE_API + className + "/" +id  ;
			executeCall( compFunc, url, URLRequestMethod.GET, null, null ) ;//, params, where  );
		}
		
		public function findAll( compFunc:Function, className:String, where:Object = null, skip:int = 0, results:Array = null ):void
		{
			if ( results == null ) results = [] ;
			var onComp:Function = function( r:Object ):void
			{
				var newResults:Array = results.concat( r.results ) ;
				if ( r.results.length == PARSE_GET_LIMIT ) 
				{
					skip += PARSE_GET_LIMIT ;
					findAll( compFunc, className, where, skip, newResults ) ;
				}
				else
				{
					compFunc( newResults ) ;
				}
			}
			find( onComp, className, { "limit":PARSE_GET_LIMIT, "skip":skip } , where ) ;
		}
		
		public function find( compFunc:Function, className:String, params:Object = null, where:Object = null ):void
		{
			var url:String = PARSE_API + className ;
			executeCall( compFunc, url, URLRequestMethod.GET, params, where ) ;//, params, where  );
		}
	
		public function callCloudFunc( compFunc:Function, functionName:String, params:Object = null ):void
		{
			var url:String = PARSE_CLOUD_CODE + functionName ;
			executeCall( compFunc, url, URLRequestMethod.POST, params, {} );
		}
		
		public function onHttpResponseStatus( e:HTTPStatusEvent ):void
		{
	//		trace("[e]", e.status, e.type ) ;
			if ( e.status == 404 ) if ( onHTTPStatus404Func ) onHTTPStatus404Func() ;
		}
		
		public function onIOError( e:IOErrorEvent ):void
		{
	//		trace("[e]", e.type, e.errorID, e.text ) ;
		}
		
		
	}
}