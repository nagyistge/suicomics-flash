package  
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class PurchaseEvent extends Event 
	{
		public static const PURCHASE: String = 'purchase';
		private var _items: String;
		
		public function PurchaseEvent(type:String, itms:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			_items = itms;
		} 
		
        public function get items(): String
        {
            return _items;
        }
		
		public override function clone():Event 
		{ 
			return new PurchaseEvent(type, _items, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PurchaseEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}