package com.pp.starling.ui
{
	import starling.display.DisplayObject;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	public class Grid extends Container
	{
		public static const H_ALIGN:String = HAlign.LEFT ;
		public static const V_ALIGN:String = VAlign.BOTTOM ;
		
		private var _pw:int ;
		public function get pw():int				{	return _pw ;	}
		
		private var _ph:int ;
		public function get ph():int				{	return _ph ;	}
		
		private var _colGap:int 
		public function get colGap():int						{	return _colGap;	}

		private var _rowGap:int 
		public function get rowGap():int						{	return _rowGap;	}

		private var _direction:String 
		public function get direction():String						{	return _direction;	}

		private var _numDirection:int ;
		
		private var _symbolWidth:int ;
		public function get symbolWidth():int						{	return _symbolWidth;	}

		private var _symbolHeight:int ;
		public function get symbolHeight():int						{	return _symbolHeight;	}

		private var _padding:Padding ;
		public function get padding():Padding						{	return _padding;	}

		private var _symbolByKey:Object ;
		
		public function Grid( direction:String, symbolWidth:int, symbolHeight:int, numDirection:int, colGap:int = 0, rowGap:int = 0, 
							  newPadding:Padding = null  )
		{
			super() ;
			_direction = direction ;
			_symbolWidth = symbolWidth ;
			_symbolHeight = symbolHeight ;
			_numDirection = numDirection ;
			
			_colGap = colGap ;
			_rowGap = rowGap ;
			
			_symbolByKey = {} ;
			
			newPadding ? _padding = newPadding : _padding = new Padding 
			
			_pw = _padding.left + _symbolWidth + _padding.right ; 
			_ph = _padding.top + _symbolHeight + _padding.bottom; 
		}
		
		override protected function removedFromStage():void
		{
			clear() ;
			super.removedFromStage() ;
		}
	
		
		public function add( symbol:GridSymbol ):void
		{
			_symbolByKey[ symbol.id ] = symbol ;
			
			var row:int ;
			var col:int ;
		
			if ( _direction == HAlign.LEFT )
			{
				row = numChildren % _numDirection ;
				col = int( numChildren / _numDirection ) ;
			}
			else
			{
				row = int( numChildren / _numDirection ) ;
				col = ( numChildren % _numDirection ) ;
			}
			symbol.x = _padding.left + col  * ( _symbolWidth + _colGap ) ;
			symbol.y = _padding.top + row * ( _symbolHeight + _rowGap )  ;
			addChild( symbol ) ;
			
			var right:int = symbol.x + _symbolWidth + _padding.right ;
			if ( _pw < right )  _pw = right ;
			
			var bottom:int = symbol.y + _symbolHeight + _padding.bottom ;
			if ( _ph < bottom )  _ph = bottom ;
			
		//	updateProperties() ;
		}
		/*
		private function updateProperties():void
		{
			var maxSymbolNumInLine:int = int( numChildren / _numDirection ) + 1 ;//> _symbolNumInDirection ? _symbolNumInDirection : numChildren ;
			_pw = _padding.left + _symbolWidth + _padding.right ;
			if ( maxSymbolNumInLine > 0 ) _pw += ( maxSymbolNumInLine - 1 ) * ( _symbolWidth + _colGap ) ;
			
			var lineCnt:int ;
			if ( numChildren == 0 ) lineCnt = 1 ;
			lineCnt = int ( ( numChildren - 1 ) / _numDirection ) + 1 ;		
			
			_ph = _padding.top + _symbolHeight + _padding.bottom  ;
			if ( lineCnt > 0 )	_ph += ( lineCnt - 1 ) * ( _symbolHeight + _rowGap ) ;
		}
		*/
		
		public function findSymbolByKey( key:String ):GridSymbol
		{
			return _symbolByKey[ key ];
			/*var i:int ;
			var symbol:GridSymbol ;
			var len:int = numChildren ;
			for ( i = 0; i < len; i++) 
			{
				symbol = getChildAt( i ) as GridSymbol ;
				if ( symbol.id == id ) return symbol ;
			}
			return null ;*/
		}
		
		public function getFirstChild():GridSymbol 
		{
			if ( numChildren > 0 ) return getChildAt(0) as GridSymbol ;
			return null ;
		}
		
		public function removeFirstChild( dispose:Boolean = false ):void
		{
			removeChildAt( 0, dispose );
		}
		
		public function findSymbolAt( idx:int):GridSymbol
		{
			return getChildAt( idx ) as GridSymbol ;
		}
									  
		public function clear( dispose:Boolean = true ):void
		{
			for ( var k:String in _symbolByKey ) delete _symbolByKey[ k ] ;
			removeChildren(0, -1, dispose ) ;
		}
	}
}