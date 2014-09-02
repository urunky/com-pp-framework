// =================================================================================================
// Jun 4, 2014
// =================================================================================================

package com.pp.starling.ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import starling.display.DisplayObjectContainer;
	
	public class Gage extends DisplayObjectContainer
	{
		private var _pw:int ;
		public function get pw():int						{	return _pw;	}

		private var _ph:int ;
		public function get ph():int						{	return _ph;	}

		public var showingValue:Number ;
		
		private var _currentValue:Number
		public function get currentValue():Number					{	return _currentValue;	}
		
		private var _tweenDuration:Number 
		public function get tweenDuration():Number						{	return _tweenDuration;	}
		public function set tweenDuration(value:Number):void						{	_tweenDuration = value;	}

		public function Gage( pw:int, ph:int, tweenDuration:Number = 0.2 )
		{
			super();
			_pw = pw ;
			_ph = ph ;
			_tweenDuration = tweenDuration ;
			_currentValue = 0 ;
			showingValue = 0 ;
		}
		
		public function reset( currentValue:Number = 0, useTween:Boolean = true ):void
		{
			_currentValue = currentValue ;
			tween( useTween ) ;
		}
		
		private function tween( useTween:Boolean = true ):void
		{
			if ( useTween ) 
			{
				TweenLite.to( this, _tweenDuration, { "showingValue":_currentValue, "onUpdate":update, "ease":Linear.easeNone } ) ;
			}
			else
			{
				showingValue = _currentValue ;
				update() ;
			}
		}
		
		protected function update():void
		{
			
		}
	}
}