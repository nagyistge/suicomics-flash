package  
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Framed selector for various transformation and manipulation of image objects on the canvas.
	 * 
	 * @author Ted Wen
	 */
	public class Selector extends Sprite
	{
		private const _color:uint = 0xff0000;
		
		private const _buttonSize:int = 10;
		
		private var _resizer:Sprite;
		private var _closer:Sprite;
		private var _fronter:Sprite;
		private var _backer:Sprite;
		
		private var _selected:Sprite;
		
		private var _startx:int;
		private var _starty:int;
		private var _dragging:Boolean;
		
		public function Selector()
		{
			super();
			init();
			mouseEnabled = false;
		}

		public function select(sp:Sprite):void
		{
			_selected = sp;
			update();
			stage.setChildIndex(this, stage.numChildren - 1);
			visible = true;
			//trace('visible is true');
		}
		
		public function hide():void
		{
			visible = false;
		}
		
		private function init():void
		{			
			_resizer = new Sprite();
			var g:Graphics = _resizer.graphics;
			g.beginFill(0, 0);
			g.lineStyle(1, _color);
			g.drawRect(0, 0, _buttonSize - 1, _buttonSize - 1);
			g.beginFill(_color);
			g.moveTo(0, _buttonSize-1);
			g.lineTo(_buttonSize-1, _buttonSize-1);
			g.lineTo(_buttonSize-1, 0);
			g.lineTo(0, _buttonSize-1);
			g.endFill();
			addChild(_resizer);
			_resizer.addEventListener(MouseEvent.MOUSE_DOWN, onResizeStart);
			_resizer.addEventListener(MouseEvent.MOUSE_UP, onResizeEnd);
			_resizer.addEventListener(MouseEvent.MOUSE_MOVE, onResizing);
			
			_closer = new Sprite();
			g = _closer.graphics;
			g.beginFill(0, 0);
			g.lineStyle(1, _color);
			g.drawRect(0, 0, _buttonSize - 1, _buttonSize - 1);
			g.moveTo(0, 0);
			g.lineTo(_buttonSize - 1, _buttonSize - 1);
			g.moveTo(0, _buttonSize - 1);
			g.lineTo(_buttonSize - 1, 0);
			addChild(_closer);
			_closer.addEventListener(MouseEvent.CLICK, onClose);
			
			_fronter = new Sprite();
			g = _fronter.graphics;
			g.beginFill(0, 0);
			g.lineStyle(1, _color);
			g.drawRect(0, 0, _buttonSize - 1, _buttonSize - 1);
			g.beginFill(_color);
			g.moveTo(0, _buttonSize-1);
			g.lineTo(_buttonSize-1, _buttonSize-1);
			g.lineTo(_buttonSize / 2, 0);
			g.lineTo(0, _buttonSize-1);
			g.endFill();
			addChild(_fronter);
			_fronter.addEventListener(MouseEvent.CLICK, onBringFronter);
			
			_backer = new Sprite();
			g = _backer.graphics;
			g.beginFill(0, 0);
			g.lineStyle(1, _color);
			g.drawRect(0, 0, _buttonSize - 1, _buttonSize - 1);
			g.beginFill(_color);
			g.moveTo(0, 0);
			g.lineTo(_buttonSize-1, 0);
			g.lineTo(_buttonSize / 2, _buttonSize-1);
			g.lineTo(0, 0);
			g.endFill();
			addChild(_backer);
			_backer.addEventListener(MouseEvent.CLICK, onSendBacker);
		}
		
		private function onBringFronter(e:MouseEvent):void
		{
			//trace('bring fronter one layer');
			dispatchEvent(new LayerEvent(LayerEvent.BRING_TO_FRONT));
		}
		private function onSendBacker(e:MouseEvent):void
		{
			//trace('send back one layer');
			dispatchEvent(new LayerEvent(LayerEvent.SEND_TO_BACK));
		}
		
		private function onClose(e:MouseEvent):void
		{
			e.stopPropagation();
			dispatchEvent(new Event(Event.CLOSE));
		}
		private function onResizeStart(e:MouseEvent):void
		{
			e.stopPropagation();
			_startx = e.stageX;
			_starty = e.stageY;
			_dragging = true;
			e.currentTarget.startDrag();
		}
		private function onResizeEnd(e:MouseEvent):void
		{
			e.stopPropagation();
			_dragging = false;
			e.currentTarget.stopDrag();
			dispatchEvent(new Event(Event.RESIZE));
		}
		private function onResizing(e:MouseEvent):void
		{
			if (!_dragging) return;
			//trace('resizing');
			e.stopPropagation();
			var t:DisplayObject = e.currentTarget as DisplayObject;	//t's parent is Selector
			//trace(t.x, t.y, t.parent.localToGlobal(new Point(t.x, t.y)));
			var nw:int = t.x + _buttonSize;
			var nh:int = t.y + _buttonSize;
			if (nw >= 20 && nh >= 20 && nw <=740 && nh <= 500) {
				_selected.width = t.x + _buttonSize;
				_selected.height = t.y + _buttonSize;
				redraw(_selected.width, _selected.height);
			}
		}
		
		private function update():void
		{
			if (_selected != null) {
				redraw(_selected.width, _selected.height);
				//trace('update redrawn');
				this.x = _selected.x;
				this.y = _selected.y;
			}
		}
		private function redraw(w:int, h:int):void
		{
			graphics.clear();
			graphics.beginFill(0, 0);
			graphics.lineStyle(1, _color);
			graphics.drawRect(0, 0, w-1, h-1);
			graphics.endFill();
			_resizer.x = w - _buttonSize;
			_resizer.y = h - _buttonSize;
			_closer.x = w - _buttonSize;
			_backer.y = h - _buttonSize;
		}
	}

}