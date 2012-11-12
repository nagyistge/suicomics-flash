package  
{
	import com.suinova.pe.DataManager;
	import com.suinova.sgapi.Environment;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	
	/**
	 * Gallery is a long canvas (Sprite) with all virtual assets displayed on it.
	 * The default gallery has one room of 740px wide, and additional rooms will enlarge this canvas.
	 * This class also contains data from server.
	 * '{"rooms":3,"items":5,"uid":"uid","name":"user_name",
	 * "content":{key:{'id':int(itm),'x':x,'y':y,'z':z,'sx':1.0,'sy':1.0,'ms':''}},
	 * "vgs":{"vgid":{"name":"vgname","v":1,"note":"text","bk":124}}'
	 * @author Ted Wen
	 */
	public class GalleryView extends Sprite
	{
		private const _roomWidth:int = 740;
		
		private var _rooms:int = 1;
		private var _items:int = 0;
		private var _content:Object;
		private var _vgoods:Object;
		
		private var _left:int = 0;
		private var _top:int = 0;	//always 0
		
		private var _editable:Boolean;
		private var _objects:Object;
		private var _selected:Sprite;
		private var _dragx:int;
		private var _dragy:int;
		private var _selectedBeforeDrag:Boolean;
		private var _selector:Selector;
		private var _tip:TextField;
		
		private var _dm:DataManager = DataManager.instance;
		private var _env:Environment = Environment.instance;
		
		public function GalleryView() 
		{
			super();
			_tip = new TextField();
			_tip.autoSize = 'left';
			_tip.background = true;
			_tip.backgroundColor = 0xffff00;
			_tip.border = true;
			_tip.borderColor = 0;
			_tip.multiline = true;
			
			if (stage) drawAll(); else addEventListener(Event.ADDED_TO_STAGE, drawAll);
		}
		
		/**
		 * Create a gradient Shape object with given size, colours etc.
		 * @param	width
		 * @param	height
		 * @param	colors : [color1, color2]
		 * @param	degree : []
		 * @param	tx
		 * @return
		 */
		protected function createGradientShape(width: int, height: int, colors: Array, degree: Number, tx: int): Shape
		{
			var s: Shape = new Shape();
			var matrix: Matrix = new Matrix();
			matrix.createGradientBox(width, height, degree * Math.PI / 180, 0, 0);
			s.graphics.beginGradientFill(GradientType.LINEAR, colors, [1, 1], [tx, 255], matrix);
			s.graphics.drawRect(0, 0, width, height);
			return s;
		}
		
		public function drawAll(e:Event=null):void
		{
			if (e) removeEventListener(Event.ADDED_TO_STAGE, drawAll);
			if (_content == null) return;
			
			clear();
			//draw default background wall:
			var g:Graphics = graphics;
			//colors:cyan:0xBFCDCE purple:0xB1A0CD
			g.beginFill(0xF1DB78);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight-100);
			//draw gradient floor:
			var floor:Shape = createGradientShape(stage.stageWidth, 100, [0x995105, 0xD47007],  90, 0);
			var bmpdata:BitmapData = new BitmapData(stage.stageWidth, 100);
			bmpdata.draw(floor);
			g.beginBitmapFill(bmpdata);
			g.drawRect(0, stage.stageHeight - 100, stage.stageWidth, 100);
			//draw frame line
			g.beginFill(0, 0);
			g.lineStyle(1, 0x533C2A);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			g.endFill();
			
			_objects = { };
			var drawables:Array = new Array();
			for (var cid0:String in _content) {
				var c0:Object = _content[cid0];
				drawables.push({key:cid0, id:c0.id, z:c0.z});
			}
			drawables.sort(function(a:Object, b:Object):int { return a.z - b.z; } );
			
			for (var i:int = 0, c1:Object; c1 = drawables[i]; i++) {
				var cid:String = c1.key;
				var c:Object = _content[cid];
				drawItem(cid, c);
			}
			_env.calljs('newitem', {src:'suigallery'}, onNewItem);
		}
		/**
		 * Draw a single item (virtual goods image vgb_id)
		 * @param	cid : String as item key in gallery, equals id or id_offset
		 * @param	c : {"303":{"id":303,"x":155,"y":209,"z":0,"sx":1.0,"sy":1.0,"ms":""}}
		 */
		private function drawItem(cid:String, c:Object):void
		{
			var sp:Sprite = addChild(new Sprite()) as Sprite;
			addChild(sp);
			sp.name = cid;
			_objects[sp.name] = sp;
			sp.x = c.x;
			sp.y = c.y;
			if (c.sx > 1.0 || c.sx < 1.0) sp.scaleX = c.sx;
			if (c.sy > 1.0 || c.sy < 1.0) sp.scaleY = c.sy;
			trace('add object ', sp.name, ' at ', sp.x, sp.y,'vg=',c.id);
			addEvents(sp, _editable);
			var cimg:String = goodsLogoUrl(c.id);
			_dm.loadImage(cimg, _objects[cid], function(re:Object):void {
				var errmsg:String = re.error;
				trace(errmsg);
			},false );
		}
		
		/**
		 * Called by ExternalInterface to add a new item to the gallery.
		 * And virtual goods name and note may be required.
		 * @param	params : {'items':1,'k':key,'id':vgid,'x':100,'y':100,'z':5}
		 */
		private function onNewItem(params:Object):void
		{
			trace(params,params['k']);
			var cid:String = params.k;
			_content[cid] = { id:params.id, x:params.x, y:params.y, z:params.z, sx:1.0, sy:1.0, ms:'', v:params.v };
			if (_vgoods[cid]==null)
				_vgoods[cid] = { name:params.name, v:params.v, note:params.note, bk:params.bk };
			drawItem(cid, _content[cid]);
		}
		
		/*private function onImageLoaded(ldr:Loader, url:String, cid:String):void
		{
			//var re:RegExp = /vgb_(\d+)\?v=/;
			//var result:Object = re.exec(url);
			//var vgid:String = result[1];
			var sp:Sprite = _objects[cid] as Sprite;
			sp.addChild(ldr);
		}*/
		
		private function addEvents(sp:Sprite, editable:Boolean):void
		{
			//sp.addEventListener(MouseEvent.CLICK, onClickObject);
			sp.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverObject);
			sp.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			sp.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutObject);
			if(editable){
				sp.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				sp.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			var sp:Sprite = e.currentTarget as Sprite;
			sp.startDrag();
			_dragx = sp.x;
			_dragy = sp.y;
			_selectedBeforeDrag = (_selected != null);
			if (_selectedBeforeDrag) 
				deselect();
			//trace('drag start at ', _dragx, _dragy);
		}
		private function onMouseUp(e:MouseEvent):void
		{
			var sp:Sprite = e.currentTarget as Sprite;
			sp.stopDrag();
			//trace('drag end at ', sp.x, sp.y);
			if (sp.x != _dragx || sp.y != _dragy){
				trace('Send new pos ', sp.x, sp.y, 'to server');
				_dm.post('/gallery/moveto/' + sp.name + '/' + sp.x + '/' + sp.y, { }, function(ev:String, red:Object):void {
					trace(red);
				}, function(ev:String,msg:String):void {
					trace(msg);
				} );
				_selectedBeforeDrag = false;
			} else {
				if (!_selectedBeforeDrag)
					select(sp);
			}
		}
		
		private function revokeItem(e:Event):void
		{
			trace('>>>TODO: please confirm to send this back to inventory?');
			Confirm.show(stage, 'Are you sure to send this back to your inventory?', ['Yes', 'No'], function(res:String):void {
				trace('ConfirmBox result:', res);
				if (res == 'Yes') {
					_dm.post('/gallery/revoke/' + _selected.name + '/' + _selected.x + '/' + _selected.y, { }, function(ev:String, ds:Object):void {
						if (ev != Event.COMPLETE) return;
						trace('Item revoked, remove it here');
						_env.calljs('revoke', ds, function(p:Object):void { } );
						delete _objects[_selected.name];
						_selected.parent.removeChild(_selected);
						_selected = null;
						_selector.hide();
					}, function(ev:String, msg:String):void {
						trace('Error:', ev, msg);
					} );
				}
			} );
		}
		
		/**
		 * Show a message box.
		 * @param	msg
		 */
		private function showMessage(msg:String):void
		{
			var emsg:MessageBox = new MessageBox(null, msg);
			stage.addChild(emsg);
		}
		
		private function select(sp:Sprite):void
		{
			_selected = sp;
			//_selector = new Selector(sp);
			if (_selector == null) {
				_selector = new Selector();
				stage.addChild(_selector);
				_selector.addEventListener(Event.CLOSE, revokeItem);
				_selector.addEventListener(Event.RESIZE, function(e:Event):void {
					trace('>>>TODO: resize this object to ', _selected.width, _selected.height);
					_dm.post('/gallery/resize/' + _selected.name + '/' + _selected.scaleX + '/' + _selected.scaleY, {}, function(ev:String, ds:Object):void {
						trace('Done resize on server',ds);
					}, function(ev:String, msg:String):void {
						showMessage('error:'+msg);
					} );
				});
				_selector.addEventListener(LayerEvent.BRING_TO_FRONT, function(e:LayerEvent):void {
					//trace('>>>TODO: bring to front, update server', _selected.name);
					//test_printObjects();
					//var old:int = _selected.parent.getChildIndex(_selected);
					_selected.parent.setChildIndex(_selected, _selected.parent.numChildren - 1);
					//test_printObjects();
					//var layers:String = stringifyLayers();
					//var z:int = _selected.parent.getChildIndex(_selected);
					_dm.post('/gallery/tofront/' + _selected.name + '/' + _selected.x + '/' + _selected.y, { }, function(ev:String, ds:Object):void {
						trace('Done moveto',ds);
					}, function(ev:String, msg:String):void {
						showMessage('Error:' + msg);
					} );
				} );
				_selector.addEventListener(LayerEvent.SEND_TO_BACK, function(e:LayerEvent):void {
					//trace('>>>TODO: send to back, update server', _selected.name);
					//var old:int = _selected.parent.getChildIndex(_selected);
					_selected.parent.setChildIndex(_selected, 0);
					//var z:int = _selected.parent.getChildIndex(_selected);
					//var layers:String = stringifyLayers();
					_dm.post('/gallery/toback/' + _selected.name + '/' + _selected.x + '/' + _selected.y, { }, function(ev:String, ds:Object):void {
						trace('Done moveto',ds);
					}, function(ev:String, msg:String):void {
						showMessage('Error:'+msg);
					} );
				} );
			}
			_selector.select(sp);
		}
		
		private function stringifyLayers():String {
			var buf:Array = [];
			for (var on:String in _objects) {
				var o:DisplayObject = _objects[on];
				buf.push(o.name +':' + o.parent.getChildIndex(o));
				//trace(o.name, o.parent.getChildIndex(o));
			}
			//trace(buf.join(', '));
			return '{' + buf.join(',') + '}';
		}
		
		private function deselect():void
		{
			if (_selector != null) {
				//_selector.parent.removeChild(_selector);
				//_selector = null;
				_selector.hide();
				_selected = null;
			}
		}

		private function onMouseOverObject(e:MouseEvent):void
		{
			var sp:Sprite = e.currentTarget as Sprite;
			//trace('Mouse move ', _dragged, _selected);
			var vg:Object = _vgoods[sp.name];
			stage.addChild(_tip);
			//if (typeof(vg.title) != undefined) {
				_tip.htmlText = '<b>' + vg.name + '</b><br>' + (vg.title || '');
				_tip.x = e.stageX;
				_tip.y = e.stageY + 24;
			//}
		}
		private function onMouseMove(e:MouseEvent):void
		{
			if (stage.contains(_tip)) {
				_tip.x = e.stageX;
				_tip.y = e.stageY + 24;
			}
		}
		private function onMouseOutObject(e:MouseEvent):void
		{
			var sp:Sprite = e.currentTarget as Sprite;
			//trace('Mouse out of ', sp.name);
			if (stage.contains(_tip))
				stage.removeChild(_tip);
		}
		
		public function setGallery(gobject:Object, editable:Boolean):void
		{
			_editable = editable;
			_rooms = gobject['rooms'];
			_items = gobject['items'];
			_content = gobject['content'];
			_vgoods = gobject['vgs'];
			//_content.sort(function(a:Object, b:Object):int { return a.z - b.z; } );
			var env:Environment = Environment.instance;
			var ids:Array = [];
			for (var vg:String in _vgoods) {
				var bkid:int = _vgoods[vg].bk.toString();
				if (ids.indexOf(bkid) < 0) {
					ids.push(bkid);
				}
			}
			env.calljs('bookNames', { ids:ids.join(',') }, function(resp:Object):void {
				//resp:{'26':'Monkey K','id':..}
				for (var vg:String in _vgoods) {
					var bkid:String = _vgoods[vg].bk.toString();
					_vgoods[vg].title = resp[bkid];
				}	
				} );
		}
		
		/**
		 * Delete all child display objects on this Sprite.
		 */
		public function clear():void
		{
			while (this.numChildren > 0) {
				trace('removing object');
				this.removeChildAt(0);
			}
		}
		
		public function get rooms(): int
		{
			return this._rooms;
		}
		public function get items(): int
		{
			return this._items;
		}
		public function get content(): Object
		{
			return this._content;
		}
		public function itemName(itemid:String):String
		{
			if (_vgoods)
				return _vgoods[itemid]['name'];
			return '';
		}
		public function goods(itemid:String):Object
		{
			if (_vgoods)
				return _vgoods[itemid];
			return null;
		}
		public function goodsLogoUrl(itemid:String):String
		{
			if (_vgoods)
				return '/mm/vgb_' + itemid + '?v=' + _vgoods[itemid]['v'];
			return itemid;
		}
		
	}

}