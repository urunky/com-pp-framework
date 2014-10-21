package com.pp.starling.ui
{
	import com.greensock.TweenLite;
	import com.pp.starling.manager.TouchManager;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class Scroller extends Sprite
	{
		private var _gridBeganPoint:Point ;
		
		private var _grid:Grid ;
		public function get grid():Grid			{	return _grid;	}
		
		private function get gridWidth():int 				
		{	
			var w:int = _grid.pw  ;
			return w > _viewPort.width ? w : _viewPort.width  ;	
		}
		private function get gridHeight():int 			
		{	
			var h:int = _grid.ph ;
			return h > _viewPort.height ? h : _viewPort.height ;	
		}
		
		private var _transBack:Quad = null ;
		
		private var _goToSymbol:DisplayObject ;
		
		private var _viewPort:Rectangle ;
		
		public function get symbolNum():int					{	return _grid.numChildren ;	}
		
		public function get symbolWidth():int				{	return _grid.symbolWidth ;	}
		public function get symbolHeight():int				{	return _grid.symbolHeight ;	}
		
		private var _touchManager:TouchManager ;
		
		public function Scroller( viewPort:Rectangle, direction:String, symbolWidth:int, symbolHeight:int, numDirection:int, colGap:int = 0 , rowGap:int = 0, padding:Padding = null )
		{
			
			
			_viewPort = viewPort ;
			
			_grid = new Grid( direction, symbolWidth, symbolHeight, numDirection, colGap, rowGap, padding )  ;
			
			_transBack = new Quad( _viewPort.width, _viewPort.height ) ;
			_transBack.alpha = 0 ;
			addChildAt( _transBack, 0 ) ;
			
			addChild( _grid ) ;
			
			clipRect = _viewPort ;
			
			_gridBeganPoint = new Point ; 
			
			_touchManager = new TouchManager( this, onTouchBegan, onTouchMoved, onTouchEnded ) ;
			
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ) ;
		}
		
		private function onRemovedFromStage( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage ) ;
			clear( true ) ;
		}
		
		private function onTouchBegan( e:TouchEvent ):void
		{
			_gridBeganPoint.x = _grid.x ;
			_gridBeganPoint.y = _grid.y ;
		}
		
		private function onTouchMoved( e:TouchEvent ):void
		{
			if ( _touchManager.touchMoved ) 
			{
				scrollHolder();
				e.stopImmediatePropagation() ;
			}
		}
		
		private function onTouchEnded( e:TouchEvent):void
		{
			if ( _touchManager.touchMoved ) stop( _touchManager.localTouchMovement.x, _touchManager.localTouchMovement.y );
			e.stopImmediatePropagation() ;
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
			
			if ( _grid.direction == Grid.H_ALIGN )
			{
				//		if ( _viewport.width > holderWidth ) return ;
				toX = symbol.x * (-1) + _viewPort.width * 0.5 - symbol.width * 0.5 ;
				if ( toX > 0 ) toX = 0 ;
				if ( toX < _viewPort.width - _grid.width ) toX = _viewPort.width - _grid.width ;
				//	if ( _holder.x > 0 ) toX = 0 ; 
				//	if ( _holder.x < holderWidth * (-1) + _viewport.width ) toX = holderWidth * (-1) + _viewport.width ;
			}
			else
			{
				//	if ( _viewport.height > holderHeight ) return ;
				toY = symbol.y * (-1) + _viewPort.height * 0.5 - symbol.height * 0.5  ;
				if ( toY > 0 ) toY = 0 ;
				//	if ( _holder.y > 0 ) toY = 0 ;
				//	if ( _holder.y < holderHeight * (-1) + _viewport.height ) toY = holderHeight * (-1) + _viewport.height ;
			}
			
			if ( toX != _grid.x || toY != _grid.y ) 
			{
				if ( withTween )
				{
					TweenLite.to( _grid, 0.5, {"x":toX, "y":toY, "onUpdate":showSymbolsInViewPort } ) ;// * (-1) + _viewport.width } ) ;
				}
				else
				{
					_grid.x = toX ;
					_grid.y = toY ;
					showSymbolsInViewPort() ;
				}
			}
		}
		
		public function stop( dX:int, dY:int ):void
		{
			if ( _goToSymbol ) return ;
			
			var aFactor:Number = 0.25 ;
			var v_0:int ; //= dX * 36 * aFactor ;
			if ( _grid.direction == Grid.H_ALIGN ) 
			{
				v_0 = dX * 36 * aFactor ;
			}
			else
			{
				
				v_0 = dY * 36 * aFactor ;
			}
			var t:Number = 0.5 ;
			var a:Number = v_0 * 2 ;
			var needTween:Boolean = false ;
			
			if (  _grid.direction == Grid.H_ALIGN )
			{
				var toX:int = _grid.x + v_0 + 0.5 * a * t * t ; 
				needTween = false ;
				if ( gridWidth > _viewPort.width )
				{
					if ( toX > 0 ) 
					{
						toX = 0 ;
						needTween = true ;
					}
					if ( toX < gridWidth * (-1) + _viewPort.width ) 
					{
						toX = gridWidth * (-1) + _viewPort.width ;
						needTween = true ;
					}
				}
				else
				{
					toX = 0 ;
					needTween = true ;
				}
				if ( Math.abs( dX ) >= 5 || needTween) TweenLite.to( _grid, 0.5, {"x":toX, "onUpdate":showSymbolsInViewPort } ) ;
			}
			else
			{
				var toY:int = _grid.y + v_0 + 0.5 * a * t * t ;
				if ( gridHeight > _viewPort.height )
				{
					if ( toY > 0 ) 
					{
						toY = 0 ;
						needTween = true ;
					}
					if ( toY < gridHeight * (-1) + _viewPort.height ) 
					{
						
						toY = gridHeight * (-1) + _viewPort.height ;
						needTween = true ;
					}
				}
				else
				{
					toY = 0 ;
					needTween = true ;
				}
				if ( Math.abs( dY) >= 5 || needTween ) TweenLite.to( _grid, 0.5, {"y":toY, "onUpdate":showSymbolsInViewPort } ) ;  
			}
			
		}
		
		public function scrollHolder():void
		{
			var ratio:Number = 0.25 ;
			var toValue:int ;
			
			if ( _grid.direction == Grid.H_ALIGN )
			{
				toValue = _gridBeganPoint.x + _touchManager.localTouchMovingPoint.x ;
				var maxX:int = _viewPort.width * ratio ;
				var minX:int = gridWidth * (-1) + _viewPort.width - ratio * _viewPort.width ;
				if ( _grid.x >= maxX ) 
				{
					toValue = maxX ;
				}
				else if ( _grid.x <= minX ) 
				{
					toValue = minX  ;
				}
				_grid.x = toValue ;
			}
			else
			{
				toValue = _gridBeganPoint.y + _touchManager.localTouchMovingPoint.y ;
				var maxY:int = _viewPort.height * ratio ;
				var minY:int = gridHeight * (-1) + _viewPort.height - ratio * _viewPort.height ;
				if ( _grid.y >= maxY) 
				{
					toValue = maxY ;
				}
				else if ( _grid.y <= minY ) 
				{
					toValue = minY ;
				}
				_grid.y = toValue ;
			}
			showSymbolsInViewPort() ;
		}
		
		public function refresh():void
		{
			refreshSymbolContent() ;
			showSymbolsInViewPort() ;
		}
		
		public function refreshSymbolContent():void
		{
			var i:int ;
			var len:int = _grid.numChildren ;
			var dispObj:DisplayObject ;
			for ( i = 0; i < len; i++) 
			{
				dispObj = _grid.getChildAt(i) ;
				if ( "refresh" in dispObj ) dispObj["refresh"]() ;
			}
		}
		
		public function showSymbolsInViewPort():void
		{
			var i:int ;
			var len:int = _grid.numChildren ;
			var view:DisplayObject ;
			var bool:Boolean ;
			for ( i = 0; i < len ; i++ ) 
			{
				view = _grid.getChildAt(i) ;
				bool = isSymbolInViewPort( view ) ;
				view.visible = bool ;
				if ( bool )
				{
					if ( "load" in  view ) view["load"]() ;
				}
			}
		}
		
		public function isSymbolInViewPort( dispObj:DisplayObject ):Boolean
		{
			var rect:Rectangle = dispObj.getBounds( this ) ;
			return _viewPort.intersects( rect ) ;
		}
	
		public function findSymbolByKey( key:String ):GridSymbol
		{
			return _grid.findSymbolByKey( key ) ;
		}
		
		public function findSymbolAt( idx:int ):GridSymbol
		{
			return _grid.findSymbolAt( idx )  ;; //
		}
	}
}

