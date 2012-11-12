package com.suinova.pe 
{
	/**
	 * Simple random number generator.
	 * Algorithm referenced from http://www.honeylocust.com/javascript/randomizer.html
	 * 
	 * @author Ted Wen
	 */
	public class RandomNumber
	{
		private var _seed: Number;
		
		public function RandomNumber(seed: Number = 0) 
		{
			if (seed > 0)
				_seed = seed;
			else
				_seed = new Date().getTime();
		}
		
		public function next(): Number
		{
			_seed = (_seed * 9301 + 49297) % 233280;
			return _seed / 233280.0;
		}
		
		/**
		 * Generate next random int from 0 to max (inclusive).
		 * @param	max
		 * @return
		 */
		public function nextInt(max: int): int
		{
			var r: Number = next();
			var ri:int = Math.ceil(r * max);
			//if (ri >= max) trace('!!!!! RandomNumber.nextInt returns max');
			return ri;
		}
	}

}