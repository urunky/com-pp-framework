package com.pp.parse
{
	public interface IParseLog 
	{
		function get id():String ;
		function set id( value:String ):void ;
		function get className():String ;
		function toObj():Object ;
	}
}