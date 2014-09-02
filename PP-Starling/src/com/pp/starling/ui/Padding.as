// =================================================================================================
// Jul 27, 2014
// =================================================================================================

package com.pp.starling.ui
{
	public class Padding
	{
		private var _top:int 
		public function get top():int						{	return _top;	}

		private var _right:int 
		public function get right():int						{	return _right;	}

		private var _bottom:int 
		public function get bottom():int						{	return _bottom;	}

		private var _left:int 
		public function get left():int						{	return _left;	}

		public function Padding( top:int = 0, right:int= 0, bottom:int= 0, left:int= 0 )
		{
			_top = top ;
			_right = right ;
			_bottom = bottom ;
			_left = left ;
		}
	}
}