// =================================================================================================
// Sep 21, 2014
// =================================================================================================

package com.pp.starling.manager
{
	import flash.geom.Point;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class TouchManager
	{
		private const AVAILABLE_MOVEMENT_LENGTH:int = 6 ;
		
		private var _dispatcher:DisplayObject ;
		
		private var _touches:Vector.<Touch> ;
		public function get touches():Vector.<Touch>						{	return _touches;	}

		private var _touch:Touch 
		public function get touch():Touch							{	return _touch;	}
		
		private var _globalTouchPoint:Point ;
		public function get globalTouchPoint():Point						{	return _globalTouchPoint;	}

		private var _globalTouchBeganPoint:Point ;
		public function get globalTouchBeganPoint():Point				{	return _globalTouchBeganPoint;	}

		private var _globalTouchMovement:Point 
		public function get globalTouchMovement():Point						{	return _globalTouchMovement;	}
		
		private var _localTouchPoint:Point ;
		public function get localTouchPoint():Point						{	return _localTouchPoint;	}

		private var _localTouchBeganPoint:Point ;
		public function get localTouchBeganPoint():Point					{	return _localTouchBeganPoint;	}

		private var _localTouchMovement:Point ;
		public function get localTouchMovement():Point						{	return _localTouchMovement;	}

		private var _localTouchMovingPoint:Point ;
		public function get localTouchMovingPoint():Point						{	return _localTouchMovingPoint;	}
		
		private var _touchMoved:Boolean ;
		public function get touchMoved():Boolean						{	return _touchMoved;	}
		
		private var _touchBeganFunc:Function ;
		private var _touchMovedFunc:Function ;
		private var _touchEndedFunc:Function ;
		
		public function TouchManager( dispatcher:DisplayObject, touchBeganFunc:Function, touchMovedFunc:Function, touchEndedFunc:Function )
		{
			_dispatcher = dispatcher ;
			
			_touches = new Vector.<Touch> ;
			
			_touchMoved = false ;
			
			_globalTouchPoint = new Point ;
			_globalTouchBeganPoint = new Point ;
			_globalTouchMovement = new Point ;
			
			_localTouchPoint = new Point ;
			_localTouchBeganPoint = new Point ;
			_localTouchMovement = new Point ;
			_localTouchMovingPoint = new Point ;
			
			_touchBeganFunc = touchBeganFunc ;
			_touchMovedFunc = touchMovedFunc;
			_touchEndedFunc = touchEndedFunc ;
			
			_dispatcher.addEventListener( TouchEvent.TOUCH, onTouch) ;
		}
		
		private function dispose():void
		{
			_dispatcher.removeEventListeners( TouchEvent.TOUCH ) ;
		}
	
		protected function onTouch( e:TouchEvent ):void
		{
			e.getTouches( _dispatcher, null, _touches );
		
			if ( _touches.length == 1 ) 
			{
				_touch = _touches[ 0 ] ;
				
				_touch.getLocation( Starling.current.root, _globalTouchPoint ) ;
				_touch.getLocation( _dispatcher, _localTouchPoint ) ;
				
				if ( _touch.phase == TouchPhase.BEGAN ) 
				{
					_touchMoved = false ;
					_touch.getLocation( Starling.current.root, _globalTouchBeganPoint ) ;
					_touch.getLocation( _dispatcher, _localTouchBeganPoint ) ;
					_touchBeganFunc( e ) ;
				}
				else if ( _touch.phase == TouchPhase.MOVED )
				{
					_touch.getMovement( Starling.current.root, _globalTouchMovement ) ;
					_touch.getMovement( _dispatcher, _localTouchMovement ) ;
					
					_localTouchMovingPoint = _localTouchPoint.subtract( _localTouchBeganPoint ) ;
					
					if ( !_touchMoved && _localTouchMovingPoint.length > AVAILABLE_MOVEMENT_LENGTH ) 
					{
						_touchMoved = true ;
						_touch.getLocation( _dispatcher, _localTouchBeganPoint ) ;
					}
					if ( _touchMoved ) _touchMovedFunc( e ) ;
				}
				else if ( _touch.phase == TouchPhase.ENDED )
				{
					_touchEndedFunc( e ) ;
				}
			}
			_touches.length = 0 ;
		}
	}
}