package com.pp.starling.helper
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class EventManager
	{
		private static var _current:EventManager = null ;
		
		public static function get current():EventManager					
		{	
			if ( _current == null ) _current = new EventManager ;
			return _current;	
		}

		private var _targets:Array ;
		public function get targets():Array						{	return _targets;	}

		private var _pointer:Image ;
		public function get pointer():Image						{	return _pointer;	}

		private var _touch:Touch ;
		
		public function EventManager()
		{
			init() ;
		}
		
		private function init():void
		{
			_targets = [] ;
		}
		
		public function add( eventDispatcher:EventDispatcher ):void
		{
			if ( _targets.indexOf( eventDispatcher ) < 0  ) _targets.push( eventDispatcher ) ;
		}
		
		public function remove( eventDispatcher:EventDispatcher ):void
		{
			var idx:int = _targets.indexOf( eventDispatcher ) ;
			if ( idx >= 0  ) _targets.splice( idx, 1 ) ;
		}
		
		public function removeAllTarget():void
		{
			_targets.length = 0 ;
		}
	
		public function addButtonEvent( dispObj:DisplayObject, triggeredFunc:Function, touchBeganFunc:Function = null, touchEndedFunc:Function = null, touchMovedFunc:Function = null ):void
		{
			var onTriggered:Function = function( e:Event ):void
			{
				if ( isEventAva( e.currentTarget ) ) 
				{
					if ( triggeredFunc ) triggeredFunc( e ) ;
				}
				
			}
			var onTouch:Function = function( e:TouchEvent ):void
			{
				_touch = e.getTouch( Starling.current.stage ) ;
				if ( _touch )
				{
					if ( isEventAva( e.currentTarget ) )
					{
						if ( _touch.phase == TouchPhase.BEGAN ) if ( touchBeganFunc ) touchBeganFunc( e ) ;
						if ( _touch.phase == TouchPhase.ENDED ) if ( touchEndedFunc ) touchEndedFunc( e ) ;
						if ( _touch.phase == TouchPhase.MOVED ) if ( touchMovedFunc ) touchMovedFunc( e ) ;
					}
				}
			}
			if ( touchBeganFunc || touchEndedFunc || touchMovedFunc  ) dispObj.addEventListener( TouchEvent.TOUCH, onTouch ) ;
			if ( dispObj is Button ) dispObj.addEventListener( Event.TRIGGERED, onTriggered ) ;
		}
		
		public function isEventAva( eventDispatcher:EventDispatcher ):Boolean
		{
			if ( _targets.length == 0 ) return true ;
			return  _targets.indexOf( eventDispatcher ) >= 0 ;
		}
		
		
	}
}