package com.suinova.pe
{
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * An image button class.
	 * @author Ted Wen
	 */
	public class ImageButton extends SimpleButton
	{
		private var _width: int;
		private var _height: int;
		private var _img: Bitmap;
		//private var _tip: String;
		private var _bgcolor: uint = 0xFFFFFF;
		private var _drawEdge:Boolean = true;
		
		private var _sp: Sprite;
		
		public function ImageButton(width:int, height:int, img: Bitmap, bgcolor: uint = 0xE9DACC, drawEdge:Boolean=true) 
		{
			_width = width;
			_height = height;
			_img = img;
			//_tip = tip;
			_bgcolor = bgcolor;
			_drawEdge = drawEdge;
			//super(upState, overState, downState, hitTestState);
			downState = drawButton(img, 0x545D72, 0xC3C8D3, 1);
			overState = drawButton(img, 0xC3C8D3, 0x545D72, 0);
			upState = drawButton(img, 0x545D72, 0xC3C8D3, 0);
			hitTestState = upState;
			//hitTestState.x = -(size / 4);
			//hitTestState.y = hitTestState.x;
			//super(upState, overState, downState, hitTestState);
			useHandCursor  = true;
			//if (tip != null) {
				//TooltipMan.instance.add(this, _tip);
			//}
		}
		
		private function drawButton(bmp: Bitmap, topcolor: uint, botcolor: uint, shift: int = 0): Sprite
		{
			//trace('ImageButton.drawButton');
			var sp: Sprite = new Sprite();
			//draw edges
			if (_drawEdge){
			sp.graphics.beginFill(_bgcolor);
			sp.graphics.moveTo(1 + shift, _height - 2 + shift);
			sp.graphics.lineStyle(1, topcolor);
			sp.graphics.lineTo(1 + shift, 1 + shift);
			sp.graphics.lineTo(_width - 2 + shift, 1 + shift);
			sp.graphics.lineStyle(1, botcolor);
			sp.graphics.lineTo(_width - 2 + shift, _height - 2 + shift);
			sp.graphics.lineTo(1 + shift, _height - 2 + shift);
//			sp.graphics.endFill();
			}
			//
			var x:int = (_width - bmp.width) / 2;
			var y:int = (_height - bmp.height) / 2;
			sp.graphics.beginBitmapFill(bmp.bitmapData);
			sp.graphics.drawRect(x+shift, y+shift, bmp.width, bmp.height);
			sp.graphics.endFill();
			//
			return sp;
		}
		
	}
	
}