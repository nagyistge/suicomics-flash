package  
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class ProgressBar extends Sprite
	{
		private var _text: TextField;
		private var _bgcolor: uint = 0xffff00;
		private var _opacity: Number = 1;
		private var _fgcolor: uint = 0xF87417;
		private var _tcolor: uint = 0x975005;
		private var _w: int;
		private var _h: int;
		
		public function ProgressBar(w:int, h:int)
		{
			_w = w;
			_h = h;
			_text = new TextField();
			var fmt:TextFormat = new TextFormat();
			fmt.align = 'center';
			fmt.bold = true;
			fmt.size = 12;
			_text.textColor = _tcolor;
			//_text.autoSize = 'center';
			_text.defaultTextFormat = fmt;
			_text.filters = [new DropShadowFilter(1,45,0xffffff)];
			_text.width = w;
			_text.height = h;
			addChild(_text);
			
			var g:Graphics = graphics;
			g.beginFill(_bgcolor, _opacity);
			g.lineStyle(2,_tcolor);
			//g.drawRoundRect(0, 0, w, h, 20);
			g.drawRect(0, 0, w, h);
			filters = [new DropShadowFilter(2)];
		}
		
		public function update(p: Number):void
		{
			var s:String = (100 * p).toFixed(0);
			_text.text = s + '%';
			//redraw
			var w:int = int(p * _w);
			trace(w);
			var g:Graphics = graphics;
			g.beginFill(_fgcolor);
			g.lineStyle(0,0,0);
			g.drawRect(1, 1, w-2, _h - 2);
			//g.drawRoundRect(4, 4, w-4, _h-8, 20);
			//filters = [new DropShadowFilter()];
		}
		
	}

}