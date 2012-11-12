package com.suinova.pe 
{
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	
	/**
	 * PetiPanel is a rectangular space to hold display objects.
	 * All objects will be placed inside a margin area one per row.
	 * Space between control lines is determined by bottom margin.
	 * The first control starts at top margin.
	 * 
	 * @author Ted Wen
	 */
	public class PetiPanel extends Sprite
	{
		public static const TOP: int = 0;
		public static const RIGHT: int = 1;
		public static const BOTTOM: int = 2;
		public static const LEFT: int = 3;
		
		protected var _width:int;
		protected var _height:int;
		protected var _border:int = 2;
		protected var _lineColor:uint = 0x000000;
		protected var _bgcolor:uint = 0x002068;
		protected var _rounded:int = 10;
		protected var _font: String = 'Arial';
		protected var _fontSize: int = 16;
		protected var _textColor: uint = 0xE9A854;
		protected var _dropShadow: DropShadowFilter = new DropShadowFilter(1, 45, 0, 1, 2, 2);
		
		protected var _currentY: int = 0;
		protected var _margins: Array = [4, 4, 4, 4];
		protected var _controls: Array = new Array();
		
		protected var _timer: Timer;
		protected var _modalLayer: Sprite;
		
		/**
		 * Construct a PetiPanel of a given width and height.
		 * @param	w - width
		 * @param	h - height
		 * @param	drawbg - draw background if true
		 * @param	modal - draw a under layer to prevent mouse click outside to appear as a modal dialog box
		 * @param	rounded - 10 by default for rounded corner value
		 * @param	center - by default, the panel is centered on stage, if a child panel needs to be inside this panel, center argument should be set to false.
		 */
		public function PetiPanel(w:int, h:int, drawbg:Boolean = true, modal:Boolean = false, rounded:int=10, center:Boolean=true) 
		{
			super();
			
			if (modal) {
				if (stage) {
					drawModalLayer(null);
				} else
					addEventListener(Event.ADDED_TO_STAGE, drawModalLayer);
			} else {
				_modalLayer = null;
			}
			
			_width = w;
			_height = h;
			_rounded = rounded;
			
			if (drawbg) {
				drawGradientBackground(0xC3CDDA, 0x16416B, false);
			}
			_currentY = _margins[TOP];
			
			if (center)
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{
			//trace('----onAddedToStage,x,y=',x,y,width,height);
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			this.x = (Math.max(0, Math.min(stage.stageWidth, stage.width)) - width) / 2;
			this.y = (Math.max(0, Math.min(stage.stageHeight, stage.height)) - height) / 2;
			//trace('----after centered:,x,y=', x, y,width,height);
		}
		
		public function drawModalLayer(e:Event):void
		{
			//removeEventListener(Event.ADDED_TO_STAGE, drawModalLayer);
			if (_modalLayer == null){
			_modalLayer = new Sprite();
			_modalLayer.graphics.beginFill(0, 0.5);
			_modalLayer.graphics.drawRect(0, 0, Math.max(stage.stageWidth, stage.width), Math.max(stage.stageHeight, stage.height));
			_modalLayer.graphics.endFill();
			}
			//if (stage) {
				stage.addChildAt(_modalLayer, stage.getChildIndex(this));
			//} else if (parent) {
			//	parent.addChildAt(_modalLayer, parent.getChildIndex(this));
			//}
		}
		
		protected function drawGradientBackground(topleftColor: uint, botrightColor:uint, adjustHeight:Boolean=true): void
		{
			if (adjustHeight) {
				if (_height < _currentY) {
					_height = _currentY;
				} else if (_height - _currentY > 20)
					_height = _currentY + 10;
			}
			var gtype: String = GradientType.LINEAR;
			var colors: Array = [topleftColor, botrightColor];
			var alphas: Array = [1, 1];
			var ratios: Array = [0, 255];
			var mx: Matrix = new Matrix();
			mx.createGradientBox(_width, _height, Math.PI / 4);
			var sm: String = SpreadMethod.PAD;
			graphics.beginGradientFill(gtype, colors, alphas, ratios, mx, sm);
			graphics.lineStyle(1, _lineColor);
			graphics.drawRoundRect(0, 0, _width, _height, _rounded, _rounded);
			graphics.endFill();
		}
		
		public function get backgroundColor(): uint
		{
			return _bgcolor;
		}
		public function set backgroundColor(bc: uint): void
		{
			_bgcolor = bc;
		}
		public function get lineColor(): uint
		{
			return _lineColor;
		}
		public function set lineColor(color: uint): void
		{
			_lineColor = color;
		}
		public override function get width():Number
		{
			return Math.max(_width, super.width);
		}
		
		/**
		 * Top margin specifies the first control position, bottom margin adds to the space between two lines of controls.
		 * All controls are centered in the panel, but if anything is longer than the margin, it's aligned on the left margin.
		 * 
		 * @param	topMargin
		 * @param	rightMargin
		 * @param	botMargin
		 * @param	leftMargin
		 */
		public function setMargins(topMargin: int, rightMargin: int, botMargin: int, leftMargin: int): void
		{
			_margins[TOP] = topMargin;
			_margins[RIGHT] = rightMargin;
			_margins[BOTTOM] = botMargin;
			_margins[LEFT] = leftMargin;
			updateControls();
		}
		
		public function set marginLeft(leftMargin: int): void
		{
			_margins[LEFT] = leftMargin;
			updateControls();
		}
		public function set marginRight(rightMargin: int): void
		{
			_margins[RIGHT] = rightMargin;
			updateControls();
		}
		public function set marginBottom(botMargin: int): void
		{
			_margins[BOTTOM] = botMargin;
			updateControls();
		}
		public function set marginTop(topMargin: int): void
		{
			_margins[TOP] = topMargin;
			updateControls();
		}
		
		/**
		 * Adjust positions to all controls in the list according to the new margins.
		 * Top and bottom margins as well as left margins apply.
		 */
		public function updateControls(): void
		{
			_currentY = _margins[TOP];
			for (var i: int = 0; i < _controls.length; i++) {
				var o: DisplayObject = _controls[i] as DisplayObject;
				o.x = (_width - o.width) / 2;
				if (o.x < _margins[LEFT]) o.x = _margins[LEFT];
				o.y = _currentY;
				_currentY += o.height + _margins[BOTTOM];
			}
		}
		
		public function adjustDimension():void
		{
			_currentY = _margins[TOP];
			for (var i:int = 0; i < _controls.length; i++) {
				var o:DisplayObject = _controls[i] as DisplayObject;
				if (o.width + _margins[LEFT] + _margins[RIGHT] > width) {
					_width = width = o.width + _margins[LEFT] + _margins[RIGHT];
				}
				_currentY += o.height + _margins[BOTTOM];
			}
			height = _currentY;
		}
		
		/**
		 * Add this control to the list and adjust its position, and addChild to Sprite.
		 * @param	ctrl
		 */
		public function addControl(ctrl: DisplayObject, align: String = TextFormatAlign.CENTER): void
		{
			_controls.push(ctrl);
			if (align == TextFormatAlign.CENTER) {
				ctrl.x = (_width - ctrl.width) / 2;
	//trace('center text at ', ctrl.x, ',_width=', _width, ',ctrl.width=', ctrl.width);
			} else if (align == TextFormatAlign.LEFT) {
				ctrl.x = _margins[LEFT];
			} else {
				ctrl.x = _width - ctrl.width - _margins[RIGHT];
	//trace('right align control here');
			}
		//trace('addControl, ctrl.width=', ctrl.width, 'x=', ctrl.x);
			if (ctrl.x < _margins[LEFT]) ctrl.x = _margins[LEFT];
			ctrl.y = _currentY;
			_currentY += ctrl.height + _margins[BOTTOM];
			addChild(ctrl);
		}
		
		public function addControls(lst: Array, align: String = TextFormatAlign.CENTER): void
		{
			var innerMargins:int = (lst.length - 1) * (_margins[LEFT] + _margins[RIGHT]);
			var sumWidth:int = 0;
			var maxHeight: int = 0;
			for (var i:int = 0; i < lst.length; i++) {
				var ctrl: DisplayObject = lst[i] as DisplayObject;
				sumWidth += ctrl.width;
				if (ctrl.height > maxHeight) maxHeight = ctrl.height;
			}
			var totalWidth:int = sumWidth + innerMargins;
			var cx: int = _margins[LEFT];
			if (align == TextFormatAlign.CENTER && totalWidth < _width)
				cx = (_width - totalWidth) / 2;
	//trace('addControls: totalWidth=', totalWidth, '_width=', _width, 'sumWidth=', sumWidth,',cx=',cx);
			for (i = 0; i < lst.length; i++) {
				ctrl = lst[i] as DisplayObject;
				_controls.push(ctrl);
				ctrl.x = cx;
				ctrl.y = _currentY + (maxHeight - ctrl.height) / 2;
				cx += ctrl.width + _margins[LEFT] + _margins[RIGHT];
	//trace('PetiPanel.addControls: set ctrl[', i, '].x=', ctrl.x, ',y=', ctrl.y,'dim=',ctrl.width,ctrl.height);
				addChild(ctrl);
			}
			_currentY += maxHeight + _margins[BOTTOM];
		}
		
		public function clear(): void
		{
			for (var i: int = 0; i < _controls.length; i++) {
				var o: DisplayObject = _controls[i] as DisplayObject;
				removeChild(o);
			}
			_controls = new Array();
			_currentY = _margins[TOP];
		}
		
		protected function separator(): Shape
		{
			var sx: int = _margins[LEFT];
			var ex: int = _width - _margins[RIGHT] - _margins[LEFT];
			var sp: Shape = new Shape();
			sp.graphics.beginFill(0);
			sp.graphics.moveTo(sx, 0);
			sp.graphics.lineStyle(1, 0x111111);
			sp.graphics.lineTo(ex, 0);
			sp.graphics.moveTo(sx, 1);
			sp.graphics.lineStyle(1, 0xffffff);
			sp.graphics.lineTo(ex, 1);
			sp.graphics.endFill();
			return sp;
		}
		
		public function addSeparator(): void
		{
			addControl(separator(), TextFormatAlign.LEFT);
		}
		
		public function addSpace(pixels:int):void
		{
			_currentY += pixels;
		}
		
		/**
		 * Create a TextField for label, not for INPUT.
		 * Some attributes can be provided through params object:
		 * font, size, color, align, bold:true,wrap:true,html:true
		 * @param	txt
		 * @param	params
		 * @return
		 */
		protected function createText(txt: String, params: Object=null): TextField
		{
			var f: TextFormat = new TextFormat(_font, _fontSize);
			//t.autoSize = TextFormatAlign.LEFT;
			if (params) {
				if (params['font']) f.font = params['font'];
				if (params['size']) f.size = params['size'];
				if (params['color']) f.color = params['color']; else f.color = _textColor;
				if (params['align']) f.align = params['align'];
				if (params['bold']) f.bold = params['bold'];
			}
			var t: TextField = new TextField();
			t.defaultTextFormat = f;
			var wset:Boolean = false;
			if (params) {
				if (params['input']) t.type = (params['input'])?TextFieldType.INPUT:TextFieldType.DYNAMIC; else t.selectable = false;
				if (params['width']) { t.width = params['width']; wset = true;}
				if (params['wrap']) t.wordWrap = params['wrap'];
				if (params['html'])	t.htmlText = txt; else t.text = txt;
				if (params['selectable']) t.selectable = params['selectable']; 
				//if (params['color']) t.textColor = params['color'];
			} else {
				t.text = txt;
				t.selectable = false;
			}
			if (!wset)
				t.width = t.textWidth + 4;
			t.height = t.textHeight + 4;
			if (params) {
				if (params['filters'])
					t.filters = params['filters'];
				else
					t.filters = [_dropShadow];
			} else {
				t.filters = [_dropShadow];
			}
			return t;
		}
		
		/**
		 * Add a text label (one line normally) as a single row control.
		 * @param	txt
		 * @param	params
		 * @param	align
		 */
		public function addText(txt: String, params: Object = null, align: String = TextFormatAlign.CENTER): void
		{
			var t: TextField = createText(txt, params);
			addControl(t, align);
		}

		/**
		 * Set a timer to automatically close this dialogbox after a number of milliseconds.
		 * setTimeout(1000);
		 * @param	ms
		 */
		public function setTimeout(ms: uint): void
		{
			_timer = new Timer(ms);
			_timer.addEventListener(TimerEvent.TIMER, timeoutHandler, false, 0, true);
			_timer.start();
		}
		private function timeoutHandler(e: TimerEvent): void
		{
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, timeoutHandler);
			if (parent && parent.getChildIndex(this)>=0) {
				//parent.removeChild(this);
				close();
			}
		}
	
		/**
		 * Set the panel clickable and close upon a click.
		 * clickClose = true;
		 */
		public function set clickClose(yes: Boolean): void
		{
			if (yes) {
				addEventListener(MouseEvent.CLICK, clickHandler, false, 0, true);
			} else {
				removeEventListener(MouseEvent.CLICK, clickHandler);
			}
		}
		private function clickHandler(e:MouseEvent):void
		{
			removeEventListener(MouseEvent.CLICK, clickHandler);
			if (_timer) {
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER, timeoutHandler);
			}
			if (parent && parent.getChildIndex(this)>=0) {
				//parent.removeChild(this);
				close();
			}
		}
		
		public function close():void
		{
			if (_modalLayer != null) {
				stage.removeChild(_modalLayer);
			}
			parent.removeChild(this);
		}
		
		//public function adjustHeight(): void
		//{
			//this.height = _currentY;
	//trace('this.height=', this.height , ',_currenty=', _currentY);
		//}
	}

}