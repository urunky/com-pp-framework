package com.pp.starling.ui
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.utils.HAlign;
	
	public class Grid extends DisplayObjectContainer
	{
		private function get lineCnt():int							
		{
			if ( numChildren == 0 ) return 1 ;
			return int ( ( numChildren - 1 ) / _symbolNumInLine ) + 1 ;		
		}
		
		
		private var _pw:int ;
		public function get pw():int				{	return _pw ;	}
		
		private var _ph:int ;
		public function get ph():int
		{
			return getBounds( parent ).height + _paddingBottom ;
		//	return ( _vGap + _symbolHeight ) * lineCnt - _vGap + _paddingTop + _paddingBottom ; 
		}
		
		private var _hGap:int ;
		private var _vGap:int ;
		
		private var _direction:String 
		public function get direction():String						{	return _direction;	}

		private var _symbolNumInLine:int ;
		
		private var _paddingLeft:int 
		public function get paddingLeft():int						{	return _paddingLeft;	}

		private var _paddingRight:int 
		public function get paddingRight():int						{	return _paddingRight;	}

		private var _paddingTop:int 
		public function get paddingTop():int						{	return _paddingTop;	}

		private var _paddingBottom:int 
		public function get paddingBottom():int						{	return _paddingBottom;	}

		public function Grid( direction:String, symbolNumInLine:int, hGap:int = 0, vGap:int = 0, paddingTop:int = 0, paddingBottom:int = 0, paddingLeft:int = 0, paddingRight:int = 0 )
		{
			super() ;
			_direction = direction ;
			_symbolNumInLine = symbolNumInLine ;
			_hGap = hGap ;
			_vGap = vGap ;
			_paddingTop = paddingTop ;
			_paddingBottom = paddingBottom ;
			_paddingLeft = paddingLeft ;
			_paddingRight = paddingRight ;
			_pw = 0 ;
			_ph = 0 ;
		}
		
		public function addSymbol( symbol:GridSymbol ):void
		{
			var idx:int = numChildren ;
			var px:int ;
			var py:int ;
			if ( _direction == HAlign.LEFT )
			{
				px = _paddingLeft + int( idx / _symbolNumInLine ) * ( symbol.pw + _hGap )  ;
				py = _paddingTop + ( idx % _symbolNumInLine ) * ( symbol.ph + _vGap )  ;
			}
			else
			{
				px = _paddingLeft + ( idx % _symbolNumInLine ) * ( symbol.pw + _hGap )  ;
				py = _paddingTop + int( idx / _symbolNumInLine ) * ( symbol.ph + _vGap ) ;
			}
			symbol.x = px ;
			symbol.y = py ;
			addChild( symbol ) ;
			var nw:int = px + symbol.pw + _paddingRight ;
			var nh:int = py + symbol.ph + _paddingBottom ;
			if ( nw > _pw ) _pw = nw ;
			if ( nh > _ph ) _ph = nh ;
		}
		
		public function refreshSymbolContent():void
		{
			var i:int ;
			var len:int = numChildren ;
			var symbol:GridSymbol ;
			var arr:Array = [] ;
			while ( numChildren > 0 ) arr.push( removeChildAt(0) ) ;
			for ( i = 0; i < len; i++)  addSymbol( arr[i] ) ;
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
									  
		public function clear():void
		{
			removeChildren() ;
		}
	}
}