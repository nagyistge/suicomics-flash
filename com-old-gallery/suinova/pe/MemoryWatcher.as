package com.suinova.pe 
{
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.utils.Timer;
	
	/**
	 * Singletone memory tracer.
	 * MemoryWatcher.instance.start(1000);	//milliseconds
	 * @author Ted Wen
	 */
	public class MemoryWatcher
	{
		private static const _instance: MemoryWatcher = new MemoryWatcher();
		private var _timer: Timer;
		private var _delay: int = 500;
		private var _memory: uint = 0;
		
		public function MemoryWatcher() 
		{
			if (_instance != null)
				throw new Error('Cannot construct singleton');
			_timer =  new Timer(_delay);
			_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		}
		
		public function onTimer(e: TimerEvent): void
		{
			trace('Total Memory: ', System.totalMemory);
			//var memory: uint = System.totalMemory();
			//if (memory != _memory) {
				//trace('Total Memory: ', memory);
				//_memory = memory;
			//}
		}
		
		public static function get instance(): MemoryWatcher
		{
			return _instance;
		}
		
		public function start(delay: int = 500): void
		{
			if (delay != _delay) {
				if (_timer != null) {
					_timer.removeEventListener(TimerEvent.TIMER, onTimer);
					_timer = new Timer(_delay);
					_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
				}
				_delay = delay;
			}
			_timer.start();
		}
		
		public function stop(): void
		{
			_timer.stop();
		}
	}

}