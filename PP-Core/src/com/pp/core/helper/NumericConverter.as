// =================================================================================================
// Jun 5, 2014
// =================================================================================================

package com.pp.core.helper
{
	public class NumericConverter
	{
		public static function getDigitString( val:int, digit:int = 3):String
		{
			var valStr:String = String( val ) ;
			var i:int ;
			var len:int = valStr.length ;
			var cnt:int ;
			var str:String = "" ;
			for ( i = len-1; i >= 0 ; i-- ) 
			{
				str = valStr.charAt(i) + str ;
				cnt++ ;
				if ( cnt % digit == 0 )
				{
					if ( i > 0 ) 
					{
						if ( valStr.charAt(i-1) != "-" ) str = "," + str ;
					}
				}
			}
			return str ;	
		}
		
	}
}