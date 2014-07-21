package com.pp.starling.ui
{
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	public class GridSymbol extends DisplayObjectContainer
	{
		private var _px:int ;
		public function get px():int						{	return _px;	}

		private var _py:int ;
		public function get py():int						{	return _py;	}
		
		public function get idx():int						{	return parent.getChildIndex( this ) ;	}
		
		private var _pw:int 
		public function get pw():int						{	return _pw;	}

		private var _ph:int 
		public function get ph():int						{	return _ph;	}

		private var _id:int ;
		public function get id():int						{	return _id ;	}
		
		override public function set x( value:Number ):void
		{
			super.x = value ;
			_px = value ;
		}
		
		override public function set y( value:Number ):void
		{
			super.y = value ;
			_py = value ;
		}
		
		public function GridSymbol( pw:int, ph:int )
		{
			_pw = pw ;
			_ph = ph ;
			_id = 0 ;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ) ;
		}
		
		private function onAddedToStage( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage ) ;
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedToStage ) ;
			addedToStage() ;
		}
		
		private function onRemovedToStage( e:Event ):void
		{
			removedFromStage() ;
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ) ;
		}
		
		protected function addedToStage():void
		{
		}
		
		protected function removedFromStage():void
		{
		}
	}
}