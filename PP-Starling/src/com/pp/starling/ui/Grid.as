package com.pp.starling.ui
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.utils.HAlign;
	
	public class Grid extends DisplayObjectContainer
	{
		private function get lineCnt():int							
		{
			if ( numChildren == 0 ) return 1 ;
			return int ( ( numChildren - 1 ) / _symbolNumInDirection ) + 1 ;		
		}
		
		private var _pw:int ;
		public function get pw():int				{	return _pw ;	}
		
		private var _ph:int ;
		public function get ph():int				{	return _ph ;	}
		
		private var _hGap:int ;
		private var _vGap:int ;
		
		private var _direction:String 
		public function get direction():String						{	return _direction;	}

		private var _symbolNumInDirection:int ;
		
		private var _symbolWidth:int ;
		public function get symbolWidth():int						{	return _symbolWidth;	}

		private var _symbolHeight:int ;
		public function get symbolHeight():int						{	return _symbolHeight;	}

		private var _padding:Padding ;
		
		public function Grid( direction:String, symbolWidth:int, symbolHeight:int, symbolNumInDirection:int, hGap:int = 0, vGap:int = 0, padding:Padding = null  )
		{
			super() ;
			_direction = direction ;
			_symbolWidth = symbolWidth ;
			_symbolHeight = symbolHeight ;
			_symbolNumInDirection = symbolNumInDirection ;
			_hGap = hGap ;
			_vGap = vGap ;
			
			_padding = new Padding ;
			if ( padding ) _padding = padding ;
			_pw = 0 ;
			_ph = 0 ;
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ) ;
		}
		
		private function onRemovedFromStage( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ) ;
			clear() ;
		}
		
		public function add( symbol:GridSymbol ):void
		{
			var idx:int = numChildren ;
			var px:int ;
			var py:int ;
			if ( _direction == HAlign.LEFT )
			{
				px = _padding.left + int( idx / _symbolNumInDirection ) * ( _symbolWidth + _hGap )  ;
				py = _padding.top + ( idx % _symbolNumInDirection ) * ( _symbolHeight + _vGap )  ;
			}
			else
			{
				px = _padding.left + ( idx % _symbolNumInDirection ) * ( _symbolWidth + _hGap )  ;
				py = _padding.top + int( idx / _symbolNumInDirection ) * ( _symbolHeight + _vGap ) ;
			}
			symbol.x = px ;
			symbol.y = py ;
			addChild( symbol ) ;
			updateProperties() ;
		}
		
		private function updateProperties():void
		{
			var symbol:GridSymbol = null ;
			
			var maxSymbolNumInLine:int = int( numChildren / _symbolNumInDirection ) + 1 ;//> _symbolNumInDirection ? _symbolNumInDirection : numChildren ;
			_pw = _padding.left + _symbolWidth + _padding.right ;
			if ( maxSymbolNumInLine > 0 ) _pw += ( maxSymbolNumInLine - 1 ) * ( _symbolWidth + _hGap ) ;
			
			_ph = _padding.top + _symbolHeight + _padding.bottom  ;
			if ( lineCnt > 0 )	_ph += ( lineCnt - 1 ) * ( _symbolHeight + _vGap ) ;
		}
		
		public function findSymbolByID( id:int ):GridSymbol
		{
			var i:int ;
			var symbol:GridSymbol ;
			var len:int = numChildren ;
			for ( i = 0; i < len; i++) 
			{
				symbol = getChildAt( i ) as GridSymbol ;
				if ( symbol.id == id ) return symbol ;
			}
			return null ;
		}
		
		public function findSymbolAt( idx:int):DisplayObject
		{
			return getChildAt( idx ) as DisplayObject ;
		}
									  
		public function clear( dispose:Boolean = true ):void
		{
			removeChildren(0, -1, dispose ) ;
		}
	}
}