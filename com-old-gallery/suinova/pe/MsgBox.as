package com.suinova.pe 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * Popup modal or modeless window with an imaged frame, html content for message or tooltip with or without an arrow.
	 * 
	 * @author Ted
	 */
	public class MsgBox extends Sprite
	{
		private const _shadowFilter: DropShadowFilter = new DropShadowFilter(2);
		protected var _textField: TextField;
		protected var _width: int;
		protected var _height: int;
		protected var _bgcolor: uint = 0xF9EB73;
		private var _frame: Array;
		private var _closebtn: PetiButton;
		private var _timeout: int;
		private var _timer: Timer;
		//private var _cancelbtn: PetiButton;
		private var _margin: int = 4;	//8-pixel on all sides of content
		private var _corneradius: int = 10;
		private var _modal_layer: Bitmap;
		
		public function MsgBox(msg: String, width:int = 140, height:int = 25, close:Boolean = false, timeout:int = 0) 
		{
			super();
			_width = width;
			_timeout = timeout;
			
			_textField = new TextField();
			addChild(_textField);

			var tform:TextFormat = new TextFormat();
			tform.font = 'Arial';
			tform.size = 16;
			tform.align = 'center';
			//_textField.setTextFormat(tform);
			_textField.defaultTextFormat = tform;
			_textField.selectable = false;
			_textField.htmlText = msg;
		//	_textField.multiline = true;
			_textField.wordWrap = true;
			_textField.autoSize = TextFieldAutoSize.CENTER;
			_textField.x = _margin;
			_textField.y = _margin;
			_textField.width = width - _margin * 2;
			_textField.filters = [_shadowFilter];
			//trace('numLines=',_textField.numLines);
		//trace('MsgBox.textField.textHeight=',_textField.textHeight );
			_height = Math.max(height, _textField.textHeight + 8 + 2 * _margin);
			
			drawBox();
			
			if (close) {
				_closebtn = new PetiButton(50, 20, 'Close');
				_height += 25;
				_closebtn.x = (_width - _closebtn.width) / 2;
				_closebtn.y = _height - 28;
				_closebtn.addEventListener(MouseEvent.CLICK, closeHandler, false, 0, true);
				addChild(_closebtn);
			}

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		private function drawBox():void
		{
			graphics.clear();
			graphics.beginFill(_bgcolor, 0.8);
			graphics.lineStyle(1, 0);
			graphics.drawRoundRect(0, 0, _width, _height, _corneradius);
			graphics.endFill();
		}
		public function set text(txt: String): void
		{
			_textField.htmlText = txt;
		}
		
		public function get text(): String
		{
			return _textField.htmlText;
		}
		
		public function getWidth(): int
		{
			return _width;
		}
		
		public function getHeight(): int
		{
			return _height;
		}
		
		public function show(px: int, py: int, msg: String):void
		{
			x = px;
			y = py;
			if (msg != _textField.text) {
				text = msg;
				_height = _textField.textHeight + 8 + _textField.y * 2;
				height = _height;
				drawBox();
				trace('MsgBox.show: redraw box, textHeight=', _textField.textHeight, '_height=', _height);
			}
			visible = true;
			if (_timeout > 0) {
		//trace('MsgBox.show: new Timer(', _timeout, ')');
				_timer = new Timer(_timeout);
				_timer.addEventListener(TimerEvent.TIMER, timeoutHandler, false, 0, true);
				_timer.start();
			}
		}
		
		private function addedToStage(e:Event): void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			//trace('added, stage: w=', stage.width, ' h=', stage.height);
			if (_timeout > 0) {
				_timer = new Timer(_timeout);
				_timer.addEventListener(TimerEvent.TIMER, timeoutHandler, false, 0, true);
				_timer.start();
			} else if (_closebtn == null) {
				addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
					//trace('Click on MsgBox');
					dispatchEvent(new Event(Event.CLOSE));
				}, false, 0, true);
			}
		}
		
		private function timeoutHandler(e:TimerEvent): void
		{
			//e.target.visible = false;
			//trace('MsgBox.timeoutHandler');
			//_timer.removeEventListener(TimerEvent.TIMER, timeoutHandler);
			_timer.stop();
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function closeHandler(e:MouseEvent): void
		{
			//e.target.parent.visible = false;
			//trace('MsgBox.closeHandler');
			//_closebtn.removeEventListener(MouseEvent.CLICK, closeHandler);
			dispatchEvent(new Event(Event.CLOSE));
		}
		
	}

}