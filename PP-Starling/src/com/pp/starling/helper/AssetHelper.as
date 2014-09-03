package com.pp.starling.helper
{
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class AssetHelper
	{
		private var _assetManager:AssetManager = null ;
		public function get assetManager():AssetManager					{	return _assetManager;	}
		
		private var _loadComplete:Boolean 
		public function get loadComplete():Boolean						{	return _loadComplete;	}

		public function AssetHelper( verbose:Boolean = false )
		{
			_assetManager = new AssetManager ;
			_assetManager.verbose = verbose ;
			_assetManager.keepAtlasXmls = true ;
			_loadComplete = false ;
		}
		
		public function enqueue( fileNames:Array ):void
		{
			_loadComplete = false ;
			_assetManager.enqueue( fileNames ) ;
		}
		
		public function load( progressFunc:Function, compFunc:Function  ):void
		{
			var onProgress:Function = function( ratio:Number ):void
			{
				if ( progressFunc ) progressFunc( ratio ) ;
				if ( ratio >= 1 ) 
				{
					_loadComplete = true ;
					if ( compFunc ) compFunc() ;
				}
			}
			_assetManager.loadQueue( onProgress ) ;
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
		
		public function dispose():void
		{
			assetManager.purge() ;
		}
	}
}