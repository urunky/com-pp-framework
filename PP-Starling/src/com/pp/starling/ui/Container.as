// =================================================================================================
// Jul 6, 2014
// =================================================================================================

package com.pp.starling.ui
{
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	
	public class Container extends DisplayObjectContainer
	{
		public function Container()
		{
			super();
			addEventListener( Event.ADDED_TO_STAGE, onAddedToStage ) ;
		}
		
		private function onAddedToStage( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onAddedToStage ) ;
			addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromoStage ) ;
			addedToStage() ;
		}
		
		private function onRemovedFromoStage( e:Event ):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromoStage ) ;
			removedFromStage() ;
		}
		
		protected function addedToStage():void
		{
			
		}
		
		protected function removedFromStage():void
		{
			
		}
	}
}