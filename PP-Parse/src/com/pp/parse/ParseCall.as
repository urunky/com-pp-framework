package com.pp.parse
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Capabilities;
	import flash.utils.Timer;

	public class ParseCall
	{
		public static function create( appID:String, appKey:String, sessionToken:String = "" ):ParseCall
		{
			return new ParseCall( appID, appKey, sessionToken ) ;
		}

		private var _appID:String ;
		private var _apiKey:String ;
		private var _sessionToken:String ;
		
		private var _loader:URLLoader = null ;
		private var _req:URLRequest ;
		private var _compFunc:Function ;
		private var _timer:Timer ;

		private var _onFailFunc:Function 
		public function set onFailFunc(value:Function):void						{	_onFailFunc = value;	}

		private var _onHttpResponseStatusFunc:Function 
		public function set onHttpResponseStatusFunc(value:Function):void						{	_onHttpResponseStatusFunc = value;	}

		private var _onIOErrorFunc:Function 
		public function set onIOErrorFunc(value:Function):void						{	_onIOErrorFunc = value;	}

		public function ParseCall( appID:String, apiKey:String, sessionToken:String = "" )
		{
			_req = new URLRequest ;
			_req.requestHeaders.push( new URLRequestHeader('X-Parse-Application-Id', appID ) );
			_req.requestHeaders.push( new URLRequestHeader('X-Parse-REST-API-Key', apiKey ) );
			if ( _sessionToken != "" ) _req.requestHeaders.push( new URLRequestHeader('X-Parse-Session-Token', sessionToken ) );
			_req.contentType = "application/json" ;
			_req.cacheResponse = false;
			_req.useCache = false;
			
			_loader = new URLLoader ;
			_loader.addEventListener( Event.COMPLETE, onComplete ) ;
			_loader.addEventListener( IOErrorEvent.IO_ERROR, onIOError) ;
			_loader.addEventListener( HTTPStatusEvent.HTTP_RESPONSE_STATUS, onHttpResponseStatus); 
			
			_timer = new Timer( 1000, 15 ) ;
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComp ) ;
		}
		
		private function onIOError( e:IOErrorEvent ):void
		{
			if ( _onIOErrorFunc ) _onIOErrorFunc( e ) ;
		}
		
		
		private function onHttpResponseStatus( e:HTTPStatusEvent ):void
		{
			if ( _onHttpResponseStatusFunc ) _onHttpResponseStatusFunc( e ) ;
		}
		
		
		private function onTimerComp( e:TimerEvent ):void
		{
			_timer.reset() ;
		//	_onFailFunc( this ) ;
		}
		
		private function replacer( key:String, value:Object ):Object
		{
			if ( key == "log" ) return undefined ;
			return value ;
		}
		
		public function call( compFunc:Function, url:String, method:String, params:Object = null, where:Object = null ):void
		{
			_timer.start() ;
			
			_compFunc = compFunc ;
			_req.url = url ;
			_req.method = method ;
			_req.data = {}
			if ( where  ) 
			{
				if ( params == null )  params = {}; 
				params.where = JSON.stringify( where, replacer ); 
			}
			if ( params ) 
			{ 
				if ( method == URLRequestMethod.GET ) 
				{
					var vars:URLVariables = new URLVariables();
					for (var p:* in params) vars[p] = params[p];
					_req.data = vars;
				} 
				else 
				{ 
					_req.data = JSON.stringify( params, replacer ); 
				}
			}
			_loader.load( _req );
		}
		
		public function retry():void
		{
			_loader.load( _req );
		}
		
		public function cancel():void
		{
			_loader.close() ;
		}
		
		private function onComplete( e:Event ):void
		{
			_timer.stop() ;
			_timer.reset() ;
			if ( Capabilities.os.indexOf("Window") >= 0 )  trace("e.target.data",  e.target.data ) ;
			var obj:Object = JSON.parse( e.target.data ) ;
			if ( "error" in obj )
			{
				var code:int =  obj["code"] ;
				if ( code == 155 )
				{
					retry() ;
				}
				else if ( code == 1 )
				{
					retry() ;
				}
				else if ( code == 101 ) //object not found for get
				{
					if ( _compFunc != null ) 
					{
						_loader.close() ;
						_compFunc( obj );
					}
				}
			}
			else
			{
				if ( _compFunc != null ) 
				{
					_loader.close() ;
					_compFunc( obj );
				}
			}
		}
	}
}