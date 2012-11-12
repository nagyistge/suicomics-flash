package com.suinova.pe
{
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * ...
	 * @author Ted Wen
	 */
	public class PetiButton extends SimpleButton
	{
		private var _text: String;
		private var _width: int;
		private var _height: int;
		private var _padding: int = 4;
		private var _sp: Sprite;
		private var _dropShadow: DropShadowFilter = new DropShadowFilter(1);
		
		public function PetiButton(width:int, height:int, text:String) 
		{
			_width = width;
			_height = height;
			_text = text;
			var downText:TextField = createText(true);
			if (width == 0) {
				_width = downText.textWidth + _padding + _padding;
			}
			if (height == 0) {
				_height = downText.textHeight + _padding + _padding;
			}
			//super(upState, overState, downState, hitTestState);
			downState = drawButton(_width, _height, 0x545D72, 0xC3C8D3, downText);
			overState = drawButton(_width, _height, 0xC3C8D3, 0x545D72, createText());
			upState = drawButton(_width, _height, 0x545D72, 0xC3C8D3, createText());
			hitTestState = upState;
			//hitTestState.x = -(size / 4);
			//hitTestState.y = hitTestState.x;
			//super(upState, overState, downState, hitTestState);
			useHandCursor  = true;
		}
		
		private function createText(down:Boolean=false): TextField
		{
			var tf:TextField = new TextField();
			tf.width = _width;
			tf.height = _height;
			tf.text = _text;
			var tform: TextFormat = new TextFormat('Arial', 12, 0xFFFFFF);
			tform.align = TextFormatAlign.CENTER;
			tf.setTextFormat(tform);
			tf.y = (_height - tf.textHeight) / 2;
			tf.y -= 2;
			if (down) {
				tf.x += 1;
				tf.y += 1;
			}
			tf.filters = [_dropShadow];
			return tf;
		}
		/*
		private function drawButtonShadow(): void
		{
			//drop shadow button
			var ds: DropShadowFilter = new DropShadowFilter();
			ds.distance = 5;
			ds.blurX = ds.blurY = 10;
			ds.alpha = .6;
			_sp = new Sprite();
			with (_sp.graphics) {
				lineStyle(1, 0x000000, 1, true);
				beginFill(0xffff00, .8);
				drawRoundRect(0, 0, 100, 50, 15);
				endFill();
			}
			_sp.buttonMode = true;
			_sp.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
			_sp.addEventListener(MouseEvent.MOUSE_UP, onUp, false, 0, true);
			_sp.addEventListener(MouseEvent.MOUSE_OUT, onUp, false, 0, true);
		//	addChild(_sp);
			_sp.filters = [ds];

		}
		private function onDown(e: MouseEvent): void
		{
			_sp.filters = [];
		}
		private function onUp(e: MouseEvent): void
		{
			_sp.filters = [];
		}*/
		
		private function drawButton(w:int,h:int,upcolor:int,botcolor:int, tf:TextField): Sprite
		{
		//trace('PetiButton.drawButton: text=' + tf.text);
			var type:String = GradientType.LINEAR;
			var colors:Array = [upcolor,botcolor];
			var alphas:Array = [1, 0];
			var ratios:Array = [0, 255];
			var spreadMethod:String = SpreadMethod.PAD;
			var interp:String = InterpolationMethod.LINEAR_RGB;
			var focalPtRatio:Number = 0;

			var matrix: Matrix = new Matrix();
			var boxWidth:Number = w;
			var boxHeight:Number = h;
			var boxRotation:Number = Math.PI / 2;
			var tx:Number = 0;
			var ty:Number = 0;
			matrix.createGradientBox(boxWidth, boxHeight, boxRotation, tx, ty);

			var square:Shape = new Shape();
			square.graphics.beginGradientFill(type, colors, alphas, ratios, matrix, spreadMethod, interp, focalPtRatio);
			square.graphics.drawRect(0, 0, w, h);
			square.graphics.lineStyle(1, 0xffffff);
			square.graphics.beginFill(0xffffff, 0.5);
			square.graphics.drawRect(0, 0, w, h);
			square.graphics.endFill();
			square.filters = [new DropShadowFilter(5)];
			
			var sprite:Sprite = new Sprite();
			sprite.addChild(square);
			sprite.addChild(tf);
			
			return sprite;
		}
		
	}
	
}