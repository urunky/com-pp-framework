package com.pp.starling.helper
{
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;

	public class EventHelper
	{
		private static var _current:EventHelper = null ;
		
		public static function get current():EventHelper					
		{	
			if ( _current == null ) _current = new EventHelper ;
			return _current;	
		}

		private var _targets:Array ;
		public function get targets():Array						{	return _targets;	}

		private var _pointer:Image ;
		public function get pointer():Image						{	return _pointer;	}

		private var _touch:Touch ;
		
		public function EventHelper()
		{
			init() ;
		}
		
		private function init():void
		{
			_targets = [] ;
		}
		
		public function addTarget( eventDispatcher:EventDispatcher ):void
		{
			if ( _targets.indexOf( eventDispatcher ) < 0  ) _targets.push( eventDispatcher ) ;
		}
		
		public function removeTarget( eventDispatcher:EventDispatcher ):void
		{
			var idx:int = _targets.indexOf( eventDispatcher ) ;
			if ( idx >= 0  ) _targets.splice( idx, 1 ) ;
		}
		
		public function removeAllTarget():void
		{
			_targets.length = 0 ;
		}
	
		public function addButtonEvents( btns:Array, triggeredFunc:Function, touchBeganFunc:Function = null, touchEndedFunc:Function = null ):void
		{
			var i:int ;
			var len:int = btns.length ;
			for ( i = 0; i < len; i++) 	addButtonEvent( btns[ i ] as Button, triggeredFunc, touchBeganFunc, touchEndedFunc )	
		}
		
		public function addButtonEvent( btn:Button,  
										triggeredFunc:Function, 
										touchBeganFunc:Function = null, 
										touchEndedFunc:Function = null ):void
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
						if ( _touch.phase == TouchPhase.BEGAN ) 
						{
							e.stopImmediatePropagation() ;
							if ( touchBeganFunc ) touchBeganFunc( e ) ;
							
						}
						else if ( _touch.phase == TouchPhase.ENDED ) 
						{
							e.stopImmediatePropagation() ;
							if ( touchEndedFunc ) touchEndedFunc( e ) ;
						}
					}
				}
			}
			btn.addEventListener( Event.TRIGGERED, onTriggered ) ;
			btn.addEventListener( TouchEvent.TOUCH, onTouch ) ;
		}
		
		public function isEventAva( eventDispatcher:EventDispatcher ):Boolean
		{
			if ( _targets.length == 0 ) return true ;
			return  _targets.indexOf( eventDispatcher ) >= 0 ;
		}
		
		
	}
}