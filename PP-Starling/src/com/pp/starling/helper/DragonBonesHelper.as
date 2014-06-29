package com.pp.starling.helper
{
	import com.greensock.loading.LoaderMax;
	
	import flash.system.Capabilities;
	
	import dragonBones.factorys.StarlingFactory;
	import dragonBones.objects.XMLDataParser;
	import dragonBones.textures.StarlingTextureAtlas;
	
	import starling.utils.AssetManager;

	public class DragonBonesHelper
	{
		private var _factory:StarlingFactory;
		public function get factory():StarlingFactory			{	return _factory;	}
		
		private var _scaleFactor:Number 

		private var _loaderMax:LoaderMax ;
		
		private var _assetManager:AssetManager ;
		
		private var _verbose:Boolean ;
		
		public function DragonBonesHelper( verbose:Boolean = false )
		{
			_verbose = verbose ;
			_factory = new StarlingFactory ;
			_factory.generateMipMaps = false ;
			_factory.optimizeForRenderToTexture = true ;
		}
		
		public function load( compFunc:Function, fileNames:Array ):void
		{
			_assetManager = new AssetManager ;
			_assetManager.keepAtlasXmls = true ;
			_assetManager.verbose = _verbose ;
			_assetManager.enqueue( fileNames ) ;
			var onProgress:Function = function( ratio:Number ):void
			{
				if ( ratio >= 1 )
				{
					factory.addSkeletonData( XMLDataParser.parseSkeletonData( _assetManager.getXml("skeleton") ) ) ;
					var sta:StarlingTextureAtlas = new StarlingTextureAtlas( _assetManager.getTexture("texture"), _assetManager.getXml("texture") )  ;
					factory.addTextureAtlas( sta ) ;
					if ( compFunc ) compFunc() ;
				}
			}
			_assetManager.loadQueue( onProgress ) ;
		}
		
		private function isWindow():Boolean				{	return Capabilities.os.indexOf("Windows") >= 0 ;	}
		private function isIOS():Boolean				{	return Capabilities.os.indexOf("OS") >= 0 ;	}
		private function isAndroid():Boolean			{	return Capabilities.os.indexOf("Linux") >= 0 ;	}
		
		public function dispose():void
		{
			if ( _assetManager ) _assetManager.dispose() ;
			_factory.dispose( true ) ;
		}
	}
}