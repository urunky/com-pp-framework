package com.pp.starling.helper
{
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

		private var _assetManager:AssetManager 
		public function get assetManager():AssetManager						{	return _assetManager;	}

;
		
		private var _loadComplete:Boolean 
		public function get loadComplete():Boolean						{	return _loadComplete;	}
		
		public function DragonBonesHelper()
		{
			_factory = new StarlingFactory ;
			_factory.generateMipMaps = false ;
			_factory.optimizeForRenderToTexture = true ;
			
			_assetManager = new AssetManager ;
			_assetManager.keepAtlasXmls = true ;
			
			_loadComplete = false ;
		}
		
		public function enqueue( fileNames:Array ):void
		{
			_loadComplete = false ;
			_assetManager.enqueue( fileNames ) ;
		}
		
		public function load( progressFunc:Function, compFunc:Function ):void
		{
			var onProgress:Function = function( ratio:Number ):void
			{
				if ( progressFunc ) progressFunc( ratio ) ;
				if ( ratio >= 1 )
				{
					_loadComplete = true ;
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