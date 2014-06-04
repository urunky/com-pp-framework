package com.pp.starling.helper
{
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import dragonBones.factorys.StarlingFactory;
	import dragonBones.objects.XMLDataParser;
	import dragonBones.textures.StarlingTextureAtlas;
	
	import starling.textures.Texture;
	import starling.utils.AssetManager;

	public class DragonBonesHelper
	{
		private var _factory:StarlingFactory;
		public function get factory():StarlingFactory			{	return _factory;	}
		
		private var _scaleFactor:Number 

		private var _loaderMax:LoaderMax ;
		
		private var _assetManager:AssetManager ;
		
		public function DragonBonesHelper(  scaleFactor:Number = 1 )
		{
			_scaleFactor = scaleFactor ;
			_factory = new StarlingFactory ;
			_factory.generateMipMaps = false ;
			_factory.optimizeForRenderToTexture = true ;
		}
		
		public function loadFromAssetManager( fileNames:Array, compFunc:Function ):void
		{
			_assetManager = new AssetManager ;
			_assetManager.keepAtlasXmls = true ;
			_assetManager.verbose = true ;
			_assetManager.enqueue( fileNames ) ;
			var onProgress:Function = function( ratio:Number ):void
			{
				if ( ratio >= 1 )
				{
					factory.addSkeletonData( XMLDataParser.parseSkeletonData( _assetManager.getXml("skeleton") ),"nextoryTitle" ) ;
					var sta:StarlingTextureAtlas = new StarlingTextureAtlas( _assetManager.getTexture("texture"), _assetManager.getXml("texture") )  ;
					factory.addTextureAtlas( sta, "nextoryTitle" ) ;
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