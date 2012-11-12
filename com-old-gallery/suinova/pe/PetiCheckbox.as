package com.suinova.pe 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class PetiCheckbox extends Sprite
	{
		[Embed(source = '../../../../lib/checkbox.png')]
		private var CheckboxIcons: Class;
		
		private var _icons: Bitmap;
		private var _width: int;
		private var _height: int;
		private var _text: String;
		private var _bmp: Bitmap;
		private var _bmpdata: BitmapData;
		
		private var _checked: Boolean;
		
		public function PetiCheckbox(width: int, height: int, text: String, checked: Boolean) 
		{
			super();
			_width = width;
			_height = height;
			_text = text;
			_checked = checked;
			_icons = new CheckboxIcons();
			
			_bmpdata = new BitmapData(18, 18, true, 0x0000000000);
			_bmp = new Bitmap(_bmpdata);
			
			var txt: TextField = new TextField();
			var tform: TextFormat = new TextFormat('Arial', 11, 0xFFFFFF);
			txt.setTextFormat(tform);
			txt.text = _text;
			//txt.width = _width - 20;
			txt.height = 20;
			txt.textColor = 0xffffff;
			txt.selectable = false;
			txt.x = 20;
			txt.width = txt.textWidth + 4;
			
			var x:int = (_checked) ? 18 : 0;
			_bmpdata.copyPixels(_icons.bitmapData, new Rectangle(x, 0, 18, 18), new Point(0, 0));
			
			addChild(_bmp);
			addChild(txt);
			addEventListener(MouseEvent.CLICK, onCheckboxClick);
			
			useHandCursor = true;
		}
		
		private function onCheckboxClick(e: MouseEvent): void
		{
			_checked = !_checked;
			var x:int = (_checked) ? 18 : 0;
			_bmpdata.copyPixels(_icons.bitmapData, new Rectangle(x, 0, 18, 18), new Point(0, 0));
		}
	
		public function get checked(): Boolean
		{
			return _checked;
		}
		
		public function set checked(ck:Boolean):void
		{
			_checked = ck;
			var x:int = (_checked) ? 18 : 0;
			_bmpdata.copyPixels(_icons.bitmapData, new Rectangle(x, 0, 18, 18), new Point(0, 0));
		}
	}

}