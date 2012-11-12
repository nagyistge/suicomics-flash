package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class ScriptEvent extends Event 
	{
		public static const REWARD: String = 'reward';
		public static const CHANGE: String = 'change';
		
		private var _item:String;
		
		public function ScriptEvent(type:String, itm:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_item = itm;
		} 
		
		public function get item():String
		{
			return this._item;
		}
		
		public override function clone():Event 
		{ 
			return new ScriptEvent(type, _item, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("ScriptEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}