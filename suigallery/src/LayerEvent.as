package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class LayerEvent extends Event 
	{
		public static const BRING_TO_FRONT:String = 'Bring2Front';
		public static const SEND_TO_BACK:String = 'Send2Back';
		
		public function LayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new LayerEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("LayerEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}