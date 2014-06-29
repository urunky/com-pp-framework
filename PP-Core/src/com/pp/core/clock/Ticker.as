package com.pp.core.clock
{
	import flash.utils.Dictionary;

	public class Ticker
	{
		private static var _current:Ticker = null;
		public static function get current():Ticker				
		{
			if ( _current == null ) _current = new Ticker ;
			return _current ;	
		}
		private var _initialTime:int ;
		public function get initialTime():int						{	return _initialTime;		}
		public function set initialTime( val:int ):void					
		{	
			_initialTime = val ;	
			_prevTime = val ;
			_elapsedTime = 0 ;
		}
		
		private var _prevTime:int ;
		public function get prevTime():int								{	return _prevTime;	}
		public function set prevTime(value:int):void					{	_prevTime = value;	}

		public function get currentTime():int							{	return _initialTime + _elapsedTime ;	}
		
		private var _elapsedTime:Number ;
		public function get elapsedTime():Number						{	return _elapsedTime;	}
		public function set elapsedTime( value:Number ):void			
		{	
			_elapsedTime = value;
			if ( currentTime > _prevTime ) 
			{
				_prevTime = currentTime ;
				tick() ;
			}
		}

		private var _children:Vector.<ITickable> ;
		private var _childrenDic:Dictionary ;
		
		public function Ticker()
		{
			if ( _current ) throw new Error("ERROR. only One Ticker available") ;
			init() ;
		}
		
		private function init():void
		{
			_elapsedTime = 0 ;
			_prevTime = 0 ;
			_childrenDic = new Dictionary ;
		}
		
		public function add( tickable:ITickable, tickImmediately:Boolean = true ):void
		{
			if ( _childrenDic[ tickable ] ) return ;
			_childrenDic[ tickable ] = tickable ;
			if ( tickImmediately ) tickable.tick() ;
		}
		
		public function remove( tickable:ITickable ):void
		{
			if ( _childrenDic[ tickable ] ) delete _childrenDic[ tickable ] ;
		}
		
		public function tick():void
		{
			for each ( var tickable:ITickable in _childrenDic ) tickable.tick() ;
		}
	}
}