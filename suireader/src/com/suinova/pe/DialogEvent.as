package com.suinova.pe 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class DialogEvent extends Event 
	{
		public static final const YES:String = 'Yes';
		public static final const NO:String = 'No';
		public static final const CANCEL:String = 'Cancel';
		public static final const SKIP:String = 'Skip';
		public static final const IGNORE:String = 'Ignore';
		
		public function DialogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new DialogEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DialogEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}