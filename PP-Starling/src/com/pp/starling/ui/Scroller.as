package com.pp.starling.ui
{
	import com.greensock.TweenLite;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.HAlign;
	
	public class Scroller extends Sprite
	{
		private var _scrolled:Boolean ;
		public function get scrolled():Boolean			{	return _scrolled ;	}
		
		private var _initialContentPoint:Point ;
		private var _localTouchBeganPoint:Point ;
		
		private var _grid:Grid ;
		public function get grid():Grid			{	return _grid;	}
		
		private function get contentWidth():int 				
		{	
			var w:int = _grid.pw  ;
			return w > _viewport.width ? w : _viewport.width  ;	
		}
		private function get contentHeight():int 			
		{	
			var h:int = _grid.ph ;
			return h > _viewport.height ? h : _viewport.height ;	
		}
		
		private var _transBack:Quad = null ;
		
		private var _goToSymbol:DisplayObject ;
		
		private var _touches:Vector.<Touch> ;
		private var _touch:Touch ;
		private var _globalTouchPoint:Point ;
		private var _localTouchPoint:Point ;
		private var _globalMovement:Point ;
		
		private var _enableScroll:Boolean ;
		public function get enableScroll():Boolean						{	return _enableScroll;	}
		public function set enableScroll(value:Boolean):void			{	_enableScroll = value;	}

		private var _viewport:Rectangle ;
		
		public function get symbolNum():int					{	return _grid.numChildren ;	}
		
		public function Scroller( viewport:Rectangle, direction:String, symbolWidth:int, symbolHeight:int, symbolNumInDirection:int, hGap:int = 0 , vGap:int = 0, padding:Rectangle = null )
		{
			_viewport = viewport ;
			trace("_viewport", _viewport) ;
			_grid = new Grid( direction, symbolWidth, symbolHeight, symbolNumInDirection, hGap, vGap, padding )  ;
			
			_globalMovement = new Point ;
			_globalTouchPoint = new Point ;
			_localTouchPoint = new Point ;
			_localTouchBeganPoint = new Point ;
			_initialContentPoint = new Point ; 
			_enableScroll = true ;
			
			_initialContentPoint.x = _initialContentPoint.y = 0 ;
			
			_transBack = new Quad( _viewport.width, _viewport.height ) ;
			addChildAt( _transBack, 0 ) ;
			_transBack.alpha = 0 ;
			addChild( _grid ) ;
			
			addEventListener( TouchEvent.TOUCH, onTouch) ;
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ) ;
			
			clipRect = _viewport ;
		}
		
		public function getFirstChild():GridSymbol 
		{
			if ( _grid.numChildren > 0 ) return _grid.getChildAt(0) as GridSymbol ;
			return null ;
		}
		
		public function removeFirstChild( dispose:Boolean = false ):void
		{
			_grid.removeChildAt( 0, dispose );
		}
		
		private function onRemovedFromStage( e:Event ):void
		{
			removeEventListener( TouchEvent.TOUCH, onTouch ) ;
			removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ) ;
			clear( true ) ;
		}
		
		private function onTouch( e:TouchEvent ):void
		{
			_touches = e.getTouches( this );
			if ( _touches.length == 1 ) 
			{
				_touch = _touches[ 0 ] ;
				_globalTouchPoint.x = _touch.globalX ;
				_globalTouchPoint.y = _touch.globalY ;
				_touch.getLocation( this, _localTouchPoint ) ;
				
				if( _touch.phase == TouchPhase.BEGAN )
				{
					_scrolled = false ;
					_initialContentPoint.x = _grid.x ;
					_initialContentPoint.y = _grid.y ;
					_localTouchBeganPoint.x = _localTouchPoint.x ;
					_localTouchBeganPoint.y = _localTouchPoint.y ;
					
				//	onTouchBegan() ;
				}
				else if( _touch.phase == TouchPhase.MOVED )
				{
					if ( _enableScroll ) 
					{
						_touch.getMovement( this, _globalMovement ) ;
						if ( _scrolled )
						{
							scrollHolder();
						}
						else
						{
							if ( _localTouchPoint.subtract( _localTouchBeganPoint ).length > 4 ) _scrolled = true ;
						}
					}
				}
				else if( _touch.phase == TouchPhase.ENDED )
				{
					if ( _scrolled ) stop( _globalMovement.x, _globalMovement.y );
				}
			}
		}
		
		public function addSymbol( symbol:GridSymbol ):void
		{
			_grid.add( symbol ) ;
			symbol.visible = isSymbolInViewPort( symbol ) ;
		}
		
		public function clear( dispose:Boolean = true ):void
		{
			_goToSymbol = null ;
			_grid.clear( dispose ) ;
			_grid.x = 0 ;
			_grid.y = 0 ;
		}
		
		public function goTo( symbol:DisplayObject, withTween:Boolean = true ):void
		{
			_goToSymbol = symbol  ;
			
			var toX:int = _grid.x ;
			var toY:int = _grid.y ;
			
			if ( _grid.direction == HAlign.LEFT )
			{
				//		if ( _viewport.width > holderWidth ) return ;
				toX = symbol.x * (-1) + _viewport.width * 0.5 - symbol.width * 0.5 ;
				if ( toX > 0 ) toX = 0 ;
				if ( toX < _viewport.width - _grid.width ) toX = _viewport.width - _grid.width ;
				//	if ( _holder.x > 0 ) toX = 0 ; 
				//	if ( _holder.x < holderWidth * (-1) + _viewport.width ) toX = holderWidth * (-1) + _viewport.width ;
			}
			else
			{
				//	if ( _viewport.height > holderHeight ) return ;
				toY = symbol.y * (-1) + _viewport.height * 0.5 - symbol.height * 0.5  ;
				if ( toY > 0 ) toY = 0 ;
				//	if ( _holder.y > 0 ) toY = 0 ;
				//	if ( _holder.y < holderHeight * (-1) + _viewport.height ) toY = holderHeight * (-1) + _viewport.height ;
			}
			
			if ( toX != _grid.x || toY != _grid.y ) 
			{
				if ( withTween )
				{
					TweenLite.to( _grid, 0.5, {"x":toX, "y":toY, "onUpdate":hideOutSymbols } ) ;// * (-1) + _viewport.width } ) ;
				}
				else
				{
					_grid.x = toX ;
					_grid.y = toY ;
					hideOutSymbols() ;
				}
			}
		}
		
		public function stop( dX:int, dY:int ):void
		{
			if ( _goToSymbol ) return ;
			
			var aFactor:Number = 0.25 ;
			var v_0:int ; //= dX * 36 * aFactor ;
			if ( _grid.direction == HAlign.LEFT ) 
			{
				v_0 = dY * 36 * aFactor ;
			}
			else
			{
				v_0 = dX * 36 * aFactor ;
			}
			var t:Number = 0.5 ;
			var a:Number = v_0 * 2 ;
			var needTween:Boolean = false ;
			
			if (  _grid.direction == HAlign.LEFT )
			{
				var toX:int = _grid.x + v_0 + 0.5 * a * t * t ; 
				needTween = false ;
				if ( contentWidth > _viewport.width )
				{
					if ( toX > 0 ) 
					{
						toX = 0 ;
						needTween = true ;
					}
					if ( toX < contentWidth * (-1) + _viewport.width ) 
					{
						toX = contentWidth * (-1) + _viewport.width ;
						needTween = true ;
					}
				}
				else
				{
					toX = 0 ;
					needTween = true ;
				}
				if ( Math.abs( dX ) >= 5 || needTween) TweenLite.to( _grid, 0.5, {"x":toX, "onUpdate":hideOutSymbols } ) ;
			}
			else
			{
				var toY:int = _grid.y + v_0 + 0.5 * a * t * t ;
				if ( contentHeight > _viewport.height )
				{
					if ( toY > 0 ) 
					{
						toY = 0 ;
						needTween = true ;
					}
					if ( toY < contentHeight * (-1) + _viewport.height ) 
					{
						
						toY = contentHeight * (-1) + _viewport.height ;
						needTween = true ;
					}
				}
				else
				{
					toY = 0 ;
					needTween = true ;
				}
				if ( Math.abs( dY) >= 5 || needTween ) TweenLite.to( _grid, 0.5, {"y":toY, "onUpdate":hideOutSymbols } ) ;  
			}
			
		}
		
		public function scrollHolder():void
		{
			var ratio:Number = 0.25 ;
			if ( _grid.direction == HAlign.LEFT )
			{
				_grid.x = _initialContentPoint.x + ( _localTouchPoint.x - _localTouchBeganPoint.x ) ;
				if ( _grid.x > _viewport.width * ratio ) 
				{
					_grid.x = _viewport.width * ratio ;
				}
				else if ( _grid.x < contentWidth * (-1) + _viewport.width - ratio * _viewport.width ) 
				{
					_grid.x = contentWidth * (-1) + _viewport.width - ratio * _viewport.width ;
				}
			}
			else
			{
				_grid.y = _initialContentPoint.y + ( _localTouchPoint.y - _localTouchBeganPoint.y ) ;
				if ( _grid.y > _viewport.height * ratio ) 
				{
					_grid.y = _viewport.height * ratio ;
				}
				else if ( _grid.y < contentHeight * (-1) + _viewport.height - ratio * _viewport.height ) 
				{
					_grid.y = contentHeight * (-1) + _viewport.height - ratio * _viewport.height ;
				}
			}
			hideOutSymbols() ;
		}
		
		public function refresh():void
		{
			refreshSymbolContent() ;
			hideOutSymbols() ;
		}
		
		public function refreshSymbolContent():void
		{
			var i:int ;
			var len:int = _grid.numChildren ;
			var dispObj:DisplayObject ;
			for ( i = 0; i < len; i++) 
			{
				if ( _grid.getChildAt(i).hasOwnProperty("refresh") ) _grid.getChildAt(i)["refresh"]() ;
			}
		}
		
		public function hideOutSymbols():void
		{
			var i:int ;
			var len:int = _grid.numChildren ;
			var view:DisplayObject ;
			var bool:Boolean ;
			for ( i = 0; i < len ; i++ ) 
			{
				view = _grid.getChildAt(i) as DisplayObject ;
				bool = isSymbolInViewPort( view ) ;
				view.visible = bool ;// _visibleRect.intersects( view.getBounds( this )  ) ;
				if ( bool )
				{
					if ( view.hasOwnProperty("load") ) view["load"]() ;
				}
			}
		}
		
		public function isSymbolInViewPort( dispObj:DisplayObject ):Boolean
		{
			var rect:Rectangle = dispObj.getBounds( this ) ;
			return _viewport.intersects( rect ) ;
		}
	
		public function findSymbol( id:int ):DisplayObject
		{
			return _grid.findSymbolByID( id ) ;
		}
		
		public function findSymbolAt( idx:int ):DisplayObject
		{
			return _grid.findSymbolAt( idx )  ;; //
		}
	}
}

