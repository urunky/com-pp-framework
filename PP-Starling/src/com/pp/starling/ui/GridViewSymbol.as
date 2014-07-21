package com.pp.starling.ui
{
	
	import starling.display.DisplayObjectContainer;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class GridViewSymbol extends DisplayObjectContainer
	{
		private var _px:int ;
		public function get px():int							{	return _px;	}
		public function set px(value:int):void					{	_px = value;	}

		private var _py:int ;
		public function get py():int							{	return _py;	}
		public function set py(value:int):void					{	_py = value;	}
		
		public function get idx():int							{	return parent.getChildIndex( this ) ;	}
		
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
		
		public function GridViewSymbol( newWidth:int, newHeight:int )
		{
			_pw = newWidth ;
			_ph = newHeight ;
			_id = 0 ;
		}
		
		public function activate():void
		{
			addEventListener( TouchEvent.TOUCH, onTouch ) ;
		}
		
		public function deactivate():void
		{
			removeEventListeners( TouchEvent.TOUCH ) ;
		}
		
		private function onTouch( e:TouchEvent ):void
		{
			if ( e.getTouch( this, TouchPhase.BEGAN ) ) showTouchBegan() ;
			if ( e.getTouch( this, TouchPhase.ENDED ) ) showTouchEnded() ;
		}
	
		protected function showTouchBegan():void
		{
			
		}
		
		protected function showTouchEnded():void
		{
		}
		
		
	}
}