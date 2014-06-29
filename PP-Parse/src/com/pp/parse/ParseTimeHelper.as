package com.pp.parse
{
	public class ParseTimeHelper
	{
		private static const START_GMT:Number = convertGMTtoTime( "1970-01-01T00:00:00.000Z" ) ; ;
		public static function convertGMTtoTime( timeStr:String ):int
		{
			var arr:Array = timeStr.split("T") ;
			var yyyymmdd:String = arr[ 0 ] ;
			var hhmmss:String = arr[ 1 ] ;
			
			var yyyymmddArray:Array = yyyymmdd.split("-") ;
			var year:int = yyyymmddArray[ 0 ] ;
			var month:int = yyyymmddArray[ 1 ] - 1 ;
			var date:int = yyyymmddArray [ 2 ] ;
			
			var hhmmssArray:Array = hhmmss.split(":") ;
			var hours:int = hhmmssArray[ 0 ] ;
			var minutes:int = hhmmssArray[ 1 ] ;
			var ssms:Array = hhmmssArray[ 2 ].split(".") ;
			var seconds:int = ssms[ 0 ] ;
			var ms:int = ssms[ 1 ].split("Z")[ 0 ] ;
			
			var d:Date = new Date( year, month, date, hours, minutes, seconds, ms ) ;
			
			return Date.UTC( year, month, date, hours, minutes, seconds, ms ) / 1000 ;
		}
		
		public static function convertTimetoGMT( value:int ):String
		{
			var d:Date = new Date( START_GMT + value ) ;
			var mm:String = "0" + String( d.getUTCMonth() + 1 ) ;
			var dd:String = "0" +String( d.getUTCDate() ) ;
			var hh:String = "0" +String( d.getUTCHours() ) ;
			var min:String = "0" +String(d.getUTCMinutes() ) ;
			var ss:String = "0" + String(d.getUTCSeconds()  ) ;
			return d.getUTCFullYear() + "-" + mm.substr(-2, 2 ) + "-" + dd.substr(-2, 2 ) + "T" + hh.substr(-2, 2 ) + ":" + min.substr(-2, 2 )  + ":" + ss.substr(-2, 2 ) +"." + "000Z" ;
		}
	}
}