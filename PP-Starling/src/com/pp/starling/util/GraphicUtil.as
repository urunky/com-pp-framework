// =================================================================================================
// May 31, 2014
// =================================================================================================

package com.pp.starling.util
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	
	import starling.textures.Texture;

	public class GraphicUtil
	{
		public static function makeGradientRectTexture( w:int, h:int):Texture
		{
			var shape:Shape = new Shape ;
			var mat:Matrix = new Matrix;
			mat.createGradientBox( w, w, 0, 0, ( h - w ) * 0.5 ) ;// - w * 0.5, -w * 0.5 );
			shape.graphics.beginGradientFill( GradientType.RADIAL, [0xFFFFFF, 0x999999], [1,1], [0,255], mat ) ;
			shape.graphics.drawRect( 0, 0, w, h ) ;
			shape.graphics.endFill() ;
			var bmd:BitmapData = new BitmapData( w, h, true, 0x000000 ) ;
			bmd.draw( shape ) ;
			var tex:Texture = Texture.fromBitmapData( bmd, false ) ;
			bmd.dispose() ;
			return tex  ;
		}
		
		public static function makeRoundRectTexture( w:int, h:int, col:uint, alpha:Number, rounded:int = 20, lineCol:uint = 0x000000, lineThickness:int = 0 ):Texture
		{
			var shape:Shape = new Shape ;
			if ( lineThickness > 0 ) shape.graphics.lineStyle( lineThickness, lineCol ) ;
			shape.graphics.beginFill( col, alpha ) ;
			var nx:int = 0 ;
			var ny:int = 0 ;
			var nw:int = w ;
			var nh:int = h ;
			if ( lineThickness > 0 ) 
			{
				nx = lineThickness * 0.5 ; 
				ny = lineThickness * 0.5 ;
				nw -= lineThickness ;
				nh -= lineThickness ;
			}
			shape.graphics.drawRoundRect( nx, ny, nw, nh, rounded, rounded ) ;
			shape.graphics.endFill() ;
			var bmd:BitmapData = new BitmapData( w, h, true, 0x000000 ) ;
			bmd.draw( shape ) ;
			var tex:Texture =  Texture.fromBitmapData( bmd, false ) ;
			bmd.dispose() ;
			return tex ;
		}
		
	}
}