package com.suinova.pe 
{
	import flash.display.Sprite;
	
	/**
	 * tooltip with an arrow.
	 * 
	 * @author Ted
	 */
	public class ToolTip extends MsgBox
	{
		private var _arrow: Sprite;
		
		public function ToolTip(msg: String) 
		{
			super(msg, 140);
			_arrow = new Sprite();
			addChild(_arrow);
			_arrow.graphics.beginFill(_bgcolor, 0.8);
			_arrow.graphics.lineStyle(1, 0);
			_arrow.graphics.moveTo(10, _height);
			_arrow.graphics.lineTo(10, _height + 10);
			_arrow.graphics.lineTo(20, _height);
			_arrow.graphics.moveTo(19, _height);
			_arrow.graphics.lineStyle(1, _bgcolor);
			_arrow.graphics.lineTo(11, _height);
			_arrow.graphics.endFill();
		}
		
		public override function show(px: int, py: int, msg: String): void
		{
			//trace('ToolTip.show', msg);
			this.text = msg;
			//px,py = arrow position, x = px - 10, y = py - height - 10
			x = px - 10;
			y = py - _height - 10;
			visible = true;
		}
		
		public function showArrow(showit: Boolean = true): void
		{
			_arrow.visible = showit;
		}
		
	}

}