package  
{
	import flash.utils.Timer;
	
	/**
	 * Wrap Timer for additional variable.
	 * 
	 * @author Ted Wen
	 */
	public class TriggerTimer extends Timer
	{
		private var _index: int;
		
		public function TriggerTimer(index:int, delay:Number, repeatCount:int = 0) 
		{
			super(delay, repeatCount);
			_index = index;
		}
		
		public function get index():int
		{
			return _index;
		}
		
	}

}