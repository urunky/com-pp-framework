// =================================================================================================
// Jun 4, 2014
// =================================================================================================

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

	public class BinaryLoader
	{
		private var _factory:StarlingFactory;
		private var _loaderMax:LoaderMax ;
		
		public function BinaryLoader()
		{
		}
		
		public function loadAssets( compFunc:Function, fileNames:Array ):void
		{
			var i:int ;
			var len:int = fileNames.length ;
			var assetName:String ;
			var extension:String ;
			var fileName:String ;
			
			var onLoadComp:Function = function():void
			{
				for ( i = 0; i < len; i++) 
				{
					assetName = fileNames[ i ].split(".")[ 0 ] ;
					extension = fileNames[ i ].split(".")[ 1 ] ;
					var skeletonXML:XML = XML( _loaderMax.getContent( assetName + ".skeleton") )  ;
					_factory.addSkeletonData( XMLDataParser.parseSkeletonData( skeletonXML ), assetName ) ;	
					
					var textureXML:XML = XML( _loaderMax.getContent( assetName + ".texture") ) ;
					var texture:Texture
					if ( extension == "atf")
					{
						texture = Texture.fromAtfData( _loaderMax.getContent( assetName ) as ByteArray, 1, false ) ;
					}
					else
					{
						texture = Texture.fromBitmap( _loaderMax.getContent( assetName ).rawContent, false, false, 1 ) ;
					}
					
					var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas( texture, textureXML, true ) ;
					_factory.addTextureAtlas( textureAtlas, assetName ) ;
				}
				skeletonXML = null ;
				textureXML = null ;
				
				_loaderMax.empty( true, true ) ;
				_loaderMax.unload() ;
				_loaderMax.dispose( true ) ;
				compFunc() ;
			}
			var urlVars:Array = [] ;
			var folderName:String ;
			
			for ( i = 0; i < len; i++) 
			{
				fileName = fileNames[ i ] ;
				assetName = fileName.split(".")[ 0 ] ;
				extension = fileName.split(".")[ 1 ] ;
				if ( extension == "atf" )
				{
					folderName = "/atf.d" ;
					if ( isAndroid() ) folderName = "/atf.e" ; 
					if ( isIOS() ) folderName = "/atf.p" ; 
				}
				else
				{
					folderName = "/png" ;
				}
				if ( extension == "atf" )
				{
					if ( assetName.indexOf("s_npc_") >= 0 )
					{
						urlVars.push( {"url":folderName + "/" + fileName, "name":assetName } ) ;
							urlVars.push( {"url": folderName + "/" + assetName + "_skeleton.xml", "name":assetName + ".skeleton" } ) ;
						
						urlVars.push( {"url":folderName + "/" + assetName + "_texture.xml", "name":assetName + ".texture"} ) ;
					}
					else
					{
						urlVars.push( {"url":  folderName + "/" + fileName, "name":assetName } ) ;
						urlVars.push( {"url": folderName + "/" + assetName + "/texture.xml", "name":assetName + ".texture" } ) ;
							urlVars.push( {"url": folderName + "/"+ assetName + "/skeleton.xml", "name":assetName + ".skeleton" } ) ;
						
					}
					
				}
				else
				{
					
					urlVars.push( {"url":  folderName + "/" + fileName, "name":assetName } ) ;
					urlVars.push( {"url": folderName + "/" + assetName + "_skeleton.xml", "name":assetName + ".skeleton" } ) ;
					urlVars.push( {"url": folderName + "/" + assetName + "_texture.xml", "name":assetName + ".texture"} ) ;
				}
			}
			loadBynaries( urlVars, onLoadComp ) ;
		}
		
		
		public function loadBynaries( urlVars:Array, onComp:Function ):void
		{
			var onComplete:Function = function( e:LoaderEvent ):void
			{
				if ( onComp != null ) onComp() ;	
			}
			_loaderMax = new LoaderMax(  { name:"lm", "onComplete":onComplete } ) ;
			var i:int ;
			var len:int = urlVars.length ;
			var urlVar:Object ;
			for ( i = 0; i < len; i++) 
			{
				urlVar = urlVars[ i ] ;
				if ( urlVar.url.indexOf(".png") >= 0 )
				{
					_loaderMax.append( new ImageLoader( urlVar.url, { "noCache":true, "name":urlVar.name, "estimatedBytes":300000 } ) );	
				}
				else
				{
					_loaderMax.append( new BinaryDataLoader( urlVar.url, { "noCache":true, "name":urlVar.name, "estimatedBytes":300000 } ) );	
				}
				
			}
			_loaderMax.load() ;
		}
		
		private function isWindow():Boolean				{	return Capabilities.os.indexOf("Windows") >= 0 ;	}
		private function isIOS():Boolean				{	return Capabilities.os.indexOf("OS") >= 0 ;	}
		private function isAndroid():Boolean			{	return Capabilities.os.indexOf("Linux") >= 0 ;	}
		
		public function dispose():void
		{
			_factory.dispose( true ) ;
		}
		
	}
}