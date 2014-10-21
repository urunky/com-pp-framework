package com.pp.core.net
{	
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	import flash.net.Responder;
	import flash.utils.Timer;

	public class NetCon
	{
		public static const GATEWAY_URL:String = "http://crayona1.cafe24.com/0.1/Amfphp/" ;
		public static var closedConFunc:Function = null ;
		public static var errorFunc:Function = null ;
		public static var checkFunc:Function = null ;
		
		private static var _queue:Array = null ;
		public static function get queue():Array								
		{	
			if ( _queue == null )  _queue = [ NetCon.create()  ] ;
			return _queue ;	
		}

		public static function create():NetCon						{	return new NetCon ;	}
		
		public static function pick():NetCon
		{
			if ( queue.length == 0 ) return NetCon.create() ;
			return queue.shift() as NetCon ;
		}
		
		public static function make( gatewayURL:String, command:String, compFunc:Function, ... args ):NetCon
		{
			var con:NetCon = NetCon.pick() ; // new NetCon ; //
			con.gatewayURL = gatewayURL ;
			con.command = command ;
			con.compFunc = compFunc ;
			con.args = args ;
			return con ;
		}
		
		public static function call( gatewayURL:String, command:String, compFunc:Function, ... args ):void
		{
			var con:NetCon = NetCon.pick() ; // new NetCon ; //
			trace("NetCon.call", con, gatewayURL, command ) ;
			con.gatewayURL = gatewayURL ;
			con.command = command ;
			con.compFunc = compFunc ;
			con.args = args ;
			con.start() ;
		}
		
		public static function callAmf( compFunc:Function, command:String, ...rest ):void
		{
			call.apply( null, [ NetCon.GATEWAY_URL, command, compFunc ].concat( rest ) ) ;
		}
		
		
		private var _gatewayURL:String ;
		public function get gatewayURL():String						{	return _gatewayURL;	}
		public function set gatewayURL(value:String):void			{	_gatewayURL = value;	}

		private var _command:String ;
		public function get command():String						{	return _command ;	}
		public function set command( val:String ):void				{	_command = val ;	}
		
		private var _args:Array ;
		public function get args():Array							{	return _args;	}
		public function set args(value:Array):void					{	_args = value;	}

		private var _compFunc:Function ;
		public function get compFunc():Function						{	return _compFunc;	}
		public function set compFunc(value:Function):void			{	_compFunc = value;	}

		private var _con:NetConnection = null ;
		public function get con():NetConnection								
		{	
			
			if ( _con == null ) 
			{
				_con = new NetConnection ;
				_con.objectEncoding = ObjectEncoding.AMF3 ;
				var handleNetStatus:Function = function( e:NetStatusEvent ):void
				{
					
				}
				_con.addEventListener( NetStatusEvent.NET_STATUS, handleNetStatus) ;
			}
			return _con ;	
		}

	
		private var _timer:Timer = null ;
		
		public function NetCon()
		{
			init() ;
		}
		
		private function init():void
		{
			_timer = new Timer( 1000, 20 ) ;
			_timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComp ) ;
		}
		
		public function start():void
		{
			_timer.reset() ;
			_timer.start() ;
			
			var nc:NetCon = this ;
			var handleFault:Function = function( r:* = null ):void
			{
				if ( NetCon.errorFunc != null ) NetCon.errorFunc() ;
			}
			var handleComp:Function = function( r:Object ):void
			{
				var comp:Function = nc.compFunc ;
				nc.unset() ;
				NetCon.queue.push( nc ) ; 
				if ( r )
				{
					if ( "ok" in r )
					{
						if ( r.ok )
						{
							if ( comp != null ) comp( r ) ;
						}
						else
						{
							if ( r.reason == "error" )
							{
								if ( NetCon.errorFunc != null ) NetCon.errorFunc() ;		
							}
							else if ( r.reason == "check" )
							{
								if ( NetCon.checkFunc != null ) NetCon.checkFunc() ;	
							}
												
						}
					}
					else
					{
						if ( comp != null ) comp( r ) ;
					}
				}
				else
				{
					trace("r", command, r ) ;
					comp( r ) ;//
				}
			}
			var resp:Responder = new Responder( handleComp, handleFault) ;
			con.objectEncoding = ObjectEncoding.AMF3 ; 
			con.connect( gatewayURL ) ;
			con.call.apply( null, [ command, resp ].concat( args ) ) ;
		}
		
		private function onTimerComp( e:TimerEvent ):void
		{
			if ( NetCon.closedConFunc != null ) NetCon.closedConFunc() ;
			unset() ;
			_timer.reset() ;
		}
		
		public function unset():void
		{
			_timer.reset() ;
			_timer.stop() ;
			_command = "" ; 
			_compFunc = null ;
			_args = null ;	
			_con.close() ;
		}
	}
}