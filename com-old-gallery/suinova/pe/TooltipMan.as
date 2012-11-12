package com.suinova.pe 
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * A generic tooltip manager class.
	 * Tooltips are message boxes attached to display objects and added to the stage.
	 * Call TooltipMan.add(obj,tips) to attach a tip to object, and remove(obj) to remove it.
	 * Or call update to change the tip.
	 * All objects should have a proper unique name as index. If no name is given, a random name is assigned to the object.
	 * 
	 * @author Ted Wen
	 */
	public class TooltipMan
	{
		private static const _instance: TooltipMan = new TooltipMan();
		private static const _ypadding: int = 12;
		private static const _timems: int = 500;
		private var _stage: Stage;
		private var _tips: Object;
		private var _tip: ToolTip;
		private var _mousein: Boolean;
		private var _show: Boolean;
		private var _timer: Timer;
		
		public function TooltipMan() 
		{
			if (_instance != null)
				throw new Error('Call instance() to get a singleton');
			_tips = new Object();
			_tip = null;
			_mousein = _show = false;
			_timer = new Timer(_timems);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		public static function get instance(): TooltipMan
		{
			return _instance;
		}
		
		public function set stage(stage: Stage): void
		{
			_stage = stage;
		}
		
		public function count():int
		{
			var c:int = 0;
			for (var s:String in _tips)
				c ++;
			return c;
		}
		
		public function add(obj: DisplayObject, tips: String): void
		{
	//trace('TooltipMan.add(', obj.name, ',', tips, '_tips[', obj.name, '] is', _tips[obj.name]);
			//if (_tips[obj.name] != null) {
				//_tips[obj.name].text = tips;
				//_stage.addChild(_tips[obj.name]);	//move it to top of stage
				//_stage.setChildIndex(_tips[obj.name], _stage.numChildren-1);
		//trace('setChildIndex to ', _stage.numChildren-1);
				//return;
			//}
			obj.addEventListener(MouseEvent.MOUSE_OVER, showTip);
			obj.addEventListener(MouseEvent.MOUSE_MOVE, moveTip);
			obj.addEventListener(MouseEvent.MOUSE_OUT, hideTip);
			var tip: ToolTip = _tips[obj.name];
			if (tip)
				tip.text = tips;
			else
				tip = new ToolTip(tips);
			tip.visible = false;
			//if (obj.name == null || obj.name == '')
				//obj.name = genUniqueName();
			_tips[obj.name] = tip;
			if (_stage)
				_stage.addChild(tip);
			else if (obj.stage)
				obj.stage.addChild(tip);
			else
				throw new Error('Stage not available');
		}
		
		public function update(obj: DisplayObject, tips: String): void
		{
			if (_tips[obj.name] != null) {
				_tips[obj.name].text = tips;
			}
		}
		
		public function remove(obj: DisplayObject): void
		{
			if (_tips[obj.name]) {
				obj.removeEventListener(MouseEvent.MOUSE_OVER, showTip);
				obj.removeEventListener(MouseEvent.MOUSE_MOVE, moveTip);
				obj.removeEventListener(MouseEvent.MOUSE_OUT, hideTip);
				//_tips.splice(_tips.indexOf(obj), 1);
				_stage.removeChild(_tips[obj.name]);
				delete _tips[obj.name];
				//if (obj.parent && obj.parent.getChildByName(obj.name)!=null)
					//obj.parent.removeChild(obj.parent.getChildByName(obj.name));
			}
		}
		
		public function genUniqueName():String
		{
			var ds:Date = new Date();
			return 'TS' + ds.time.toString() + (100 * Math.random()).toString();
		}
		
		private function showTip(e: MouseEvent): void
		{
			//trace('onMouseOver, showTip at ', e.stageX, e.stageY, e.target);
			_tip = _tips[e.currentTarget.name];
			//trace('onMouseOver, e.currenTarget=', e.currentTarget.name );
			if (_tip == null)
				throw new Error('Tip not found');
			//_tip.x = e.stageX;
			//_tip.y = e.stageY;
			_mousein = true;
			_show = false;
			_timer.start();
		}
		
		private function moveTip(e: MouseEvent): void
		{
			//trace('onMouseMove, moveTip to ', e.stageX, e.stageY);
			if (_tip == null) {
				_tip = _tips[e.currentTarget.name];
				if (_tip == null)
					throw new Error('Tip not found');
			}
			//_tip.x = e.stageX;
			//_tip.y = e.stageY - _tip.getHeight() - 10;
			placeTip(e);
			if (_show)
				_tip.visible = true;
		}
		
		protected function placeTip(e: MouseEvent): void
		{
			var nx: int = e.stageX;
			var ny: int = e.stageY - _tip.getHeight() - 10;
			var shifted: Boolean = false;
			var stagewidth:int = Math.min(760, _stage.width);
			if (nx + _tip.width > stagewidth) {
				nx = stagewidth - _tip.width;
				shifted = true;
			}
			if (ny < 0) {
				ny = e.stageY + 12;
				shifted = true;
			}
			_tip.showArrow(!shifted);
			_tip.x = nx;
			_tip.y = ny;
		}
		
		public function hideTip(e: MouseEvent = null): void
		{
			//trace('onMouseOut, hideTip');
			if (_tip == null) return;
			_tip.visible = false;
			_mousein = _show = false;
		}
		
		private function onTimer(e: TimerEvent): void
		{
			//trace('onTimer, mousein=', _mousein);
			_timer.stop();
			if (_mousein) {
				_show = true;
				_tip.visible = true;
			} else {
				_tip.visible = false;
			}
		}
	}

}