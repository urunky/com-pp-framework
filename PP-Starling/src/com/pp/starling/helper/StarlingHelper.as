package com.pp.starling.helper
{
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class StarlingHelper
	{
		private var _scaleFactor:Number ;
		
		private var _assetManager:AssetManager = null ;
		public function get assetManager():AssetManager					{	return _assetManager;	}
		
		private var _names:Array ;
		
		public function StarlingHelper( verbose:Boolean = false )
		{
			_assetManager = new AssetManager ;
			_assetManager.verbose = verbose ;
			_names = [] ;
		}
		
		
		public function load( progressFunc:Function, fileNames:Array  ):void
		{
			_assetManager.enqueue( fileNames ) ;
			/*var onLoadComp:Function = function( ratio:Number ):void
			{
				if ( ratio == 1 ) compFunc() ;
			}*/
			_assetManager.loadQueue( progressFunc ) ;
		}
		
		public function getTexture( name:String ):Texture
		{ 
			var tex:Texture = assetManager.getTexture( name ) ;
			if ( tex ) return tex ;
			tex = assetManager.getTexture( name + "0000" ) ;
			if ( tex ) return tex ;
			tex = assetManager.getTexture( name + " instance 1" ) ;
			if ( tex ) return tex ;
			tex = assetManager.getTexture( name + " instance 10000" ) ;
			if ( tex ) return tex ;
			tex = assetManager.getTexture( name + ".png instance 1" ) ;
			if ( tex ) return tex ;
			tex = assetManager.getTexture( name + ".png instance 10000" ) ;
			if ( tex ) return tex ;
			var textures:Vector.<Texture> = getTextures( name ) ;
			if ( textures ) 
			{
				if ( textures.length > 0 ) return textures[ 0 ] ;
			}
			return assetManager.getTexture( name + ".png" ) ;
		}
		
		public function getTextures( name:String, result:Vector.<Texture> = null ):Vector.<Texture> 
		{
			return assetManager.getTextures( name, result ) ;
		}
		
		private function isWindow():Boolean				{	return Capabilities.os.indexOf("Windows") >= 0 ;	}
		private function isIOS():Boolean				{	return Capabilities.os.indexOf("OS") >= 0 ;	}
		private function isAndroid():Boolean			{	return Capabilities.os.indexOf("Linux") >= 0 ;	}
		
		public function dispose():void
		{
			assetManager.purge() ;
			assetManager.dispose() ;
		}
	}
}