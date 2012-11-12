package  
{
	import adobe.utils.CustomActions;
	import com.adobe.serialization.json.JSON;
	import com.suinova.pe.DataManager;
	import com.suinova.pe.PetiPanel;
	import com.suinova.sgapi.Environment;
	import flash.display.Loader;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	/**
	 * Script execution engine.
	 * 
	 * A script is a text in JSON format stored in a SuiPage.script field. It's generated when authors compile page effects.
	 * 
	 * Script specification 1.0:
	 * 
	 * script = {"version":"1.0","controls":[CTRL,CTRL,..]}
	 * CTRL := {"type":"button|sprite|timer","repeat":0|1,"area":AREA,"trigger":"click|mouseover|SECONDS",
	 * 		"popup":POPUP,"action":{"method":"name_func","args":{"key1":"val1",..}}}
	 * AREA := {"item":"vg_145","ver":0,"tip":"tip text","x":0,"y":0,"z":0,"w":100,"h":100,"filters":["filter1","filter2",..]}
	 * SECONDS := 0..10 seconds
	 * POPUP := {"show":"PurchaseBox|MessageBox|ChangeBox|None","title":"window title","items":[ITEM,ITEM,..]}
	 * ITEM := {"id":133,"ver":0,"name":"xxx","price":1,"note":"description","editable":0|1}
	 * 
	 * 
	 * Note: a script has a number of controls driven by a mouse event or timer event. Once a control becomes activated, a popup
	 * dialog box will show up or an action is done.  If a popup is shown, an event is issued to do some actions accordingly. These
	 * events are predefined such as purchase of virtual goods.
	 * 
	 * Possible actions include: prompt to buy virtual goods; show a message such as a reward; send a reward to the server;
	 * show or hide a layer sprite; switch to show one of a group of layers sprites; add filters to a layer sprite;
	 * show sprite effects; do some animation; play a swf movie. The last several can be implemented in later versions.
	 * 
	 * Predefined actions: buy a number of virtual goods; exchange several virtual goods for a new one (ChangeBox); 
	 * 
	 * @author Ted Wen
	 */
	public class ScriptEngine
	{
		private var _dm:DataManager = DataManager.instance;
		private var _stage:Stage;
		private var _canvas:Sprite;
		private var _book:String;
		private var _page:int;	//id not seq
		private var _scriptObject:Object;
		private var _layers:Array; //of Sprite
		private var _rewards:Object; //rewards from book
		private var _firstTime:Boolean = true;
		private var _timers:Array = [];
		private var _tip:TextField;
		
		/**
		 * Create an instance of this engine for a page. It just parses a string into AS3 object, and throws JSON exception if error.
		 * @param	script
		 */
		public function ScriptEngine(stage:Stage, canvas:Sprite, script:Object = null) 
		{
			_stage = stage;
			_canvas = canvas;
			if (script != null)
				_scriptObject = script;
			_tip = new TextField();
			_tip.background = true;
			_tip.backgroundColor = 0xFFFBCB;
			_tip.border = true;
			_tip.borderColor = 0x723F00;
			_tip.autoSize = 'left';
			_tip.multiline = true;
			_tip.selectable = false;
		}
		
		/**
		 * Set data info.
		 * @param	bk - book id as string
		 * @param	pgid - page id
		 * @param	sc - script Object parsed from DataManager.post
		 * @param	ls - layers of Array of SuiLayer (Sprite) objects
		 */
		public function setScript(bk:String, pgid:int, sc:Object, ls:Array, rw:Object):void
		{
			if (bk != null) _book = bk;
			if (pgid >= 0) _page = pgid;
			if (sc != null) _scriptObject = sc;
			if (ls != null) _layers = ls;
			_rewards = rw;
		}
		
		/**
		 * Replace script object with the new script by parsing the string into JSON object.
		 */
		public function set script(sc:Object):void
		{
			if (sc == null) 
				_scriptObject = null;
			else
				_scriptObject = sc;
		}
		
		/**
		 * Set the array of layer/sprite.
		 */
		public function set layers(ls:Array):void
		{
			_layers = ls;
		}
		
		/**
		 * Called upon page display. If not called for the first time, the repeat=0 controls will not be run.
		 */
		public function run():void
		{
			if (_scriptObject == null) {
				trace('No script');
				return;
			}
			clearTimers();
			if (_scriptObject.version)
				if (_scriptObject.version != '1.0')
					throw new ScriptEngineError('Invalid version', 401);
			if (_scriptObject.controls) {
	//trace('number of controls = ' + _scriptObject.controls.length);
				if (_scriptObject.controls.length > 0) {
					for (var i:int = 0, c:Object; c = _scriptObject.controls[i]; i++) {
						if (!isCollected(c, _rewards)) {
							parse(i, c);
						}
					}
				} else {
					throw new ScriptEngineError('No controls', 402);
				}
			}
			_firstTime = false;
		}
		
		/**
		 * Test whether items in script are collected, ie, not in rewards object for this book by this user.
		 * @param	c
		 * @param	rewards
		 * @return
		 */
		private function isCollected(c:Object, rewards:Object):Boolean
		{
			if (c.hasOwnProperty('popup')) {
				if (c.popup.show == 'RewardBox') {
					if (rewards == null || rewards == {}) return true;
					for (var i:int = 0, it:Object; it = c.popup.items[i]; i++) {
						if (!rewards.hasOwnProperty(it.id.toString())) {
							return true;
						}
					}
				}
			} else if (c.hasOwnProperty('action')) {
				if (c.action.method == 'collect') {
					if (rewards == null || rewards == { } ) return true;
					//action has only one item
					var itm:int = c.action.params.item;
					return !rewards.hasOwnProperty(itm.toString());
				}
			}
			return false;
		}
		
		/**
		 * Stop all timers and then delete all instances.
		 */
		public function clearTimers():void {
			for (var i:int = 0, t:Timer; t = _timers[i] as Timer; i++) {
				t.stop();
			}
			_timers = [];
		}
		
		/**
		 * Parse the script object and prepare for the event handlers.
		 * @param	index - which control
		 * @param	control - the control object
		 */
		protected function parse(index:int, control:Object):void
		{
trace('parse ' + index);
			if (control.type == 'button' || control.type == 'sprite') {
				if (control.area){
					var area:Object = control.area;
					var idp:String = (control.type == 'button')?'vg_':'vgb_';
					var sp:Sprite = new Sprite();
					sp.name = index.toString();
					sp.x = area.x;
					sp.y = area.y;
					if (control.type == 'button') {
						//for button type, add BevelFilter to w,h bounds
						sp.graphics.beginFill(0xdddddd, 1);
						//sp.graphics.lineStyle(1, 0);
						sp.graphics.drawRect(0, 0, area.w - 1, area.h - 1);
						sp.graphics.endFill();
						sp.filters = [new BevelFilter()];
						sp.buttonMode = true;
						//sp.useHandCursor = true;
					} else if (area.filters) {
						sp.filters = Utils.formatFilters(area.filters);
						control['sp'] = sp; //for removal
					}
					this._canvas.addChild(sp);
					//_stage.addChild(sp);
					if (area.item > 0){
						var url:String = '/mm/' + idp + area.item + '?v=' + area.ver;
						_dm.loadImage(url, function(ldr:Loader):void {
							if (control.type == 'button') {
								sp.addChild(ldr);
								ldr.x = (sp.width - ldr.width) / 2;
							} else
								sp.addChild(ldr);
							}, function(res:Object):void { trace(res.error); } );
					} else {
						//text button
						var t:TextField = new TextField();
						var tf:TextFormat = new TextFormat();
						tf.font = 'Arial';
						tf.size = 14;
						t.defaultTextFormat = tf;
						t.text = area.tip;
						t.height = t.textHeight + 4;
						t.selectable = false;
						t.mouseEnabled = false;
						t.filters = [new DropShadowFilter()];
						sp.addChild(t);
						t.x = (sp.width - t.width) / 2;
						t.y = (sp.height - t.height) / 2;
					}
					if (control.trigger) {
						var tr:String = control.trigger;
						if (tr == 'click') {
							sp.addEventListener(MouseEvent.CLICK, onMouseClick);
							if (control.area && control.area.tip){
								sp.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
								sp.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
								sp.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
							}
						} else {
							throw new ScriptEngineError('Unknown trigger: ' + tr);
						}
					}
				}
			} else if (control.type == 'timer') {
				//trigger:"1000,0" -- 1 second before invocation, and repeat forever(0), if no ,0 repeat once
				if (control.trigger) {
					var tgrs:Array = control.trigger.split(',');
					var secs:int = parseInt(tgrs[0]);
					var reps:int = 1;
					if (tgrs.length > 1) reps = parseInt(tgrs[1]);
					var timr:TriggerTimer = new TriggerTimer(index, secs, reps);
					_timers.push(timr);
					timr.addEventListener(TimerEvent.TIMER, onTimer);
					timr.start();
				} else {
					throw new ScriptEngineError('Timer has no trigger:"secs,repeat"');
				}
			}
		}
		
		/**
		 * Show popup dialog box if available for a control.
		 * @param	popup - popup dialog box data
		 * @param	evs - from which event this is called
		 */
		protected function showPopup(popup:Object, evs:String):void
		{
	trace('showPopup, event is ', evs, 'popup = ', popup);
			var title:String = (typeof(popup.title)==undefined)?null:popup.title;
			var items:Array = (typeof(popup.items) == undefined)?null:popup.items;
			if (typeof(popup.show) == undefined) throw new ScriptEngineError('No show in popup');
			var s:String = popup.show;
			var box:PetiPanel = null;
			if (s == 'PurchaseBox') {
				if (items == null) throw new ScriptEngineError('items is null in PurchaseBox popup');
				box = new PurchaseBox(items);
				box.addEventListener(PurchaseEvent.PURCHASE, onPurchase);
			}
			else if (s == 'ChangeBox') {
				trace('ChangeBox');
				box = new ChangeBox(title,items);
				trace('>>>TODO: implement exchange items here');
			}
			else if (s == 'MessageBox') {
				box = new MessageBox(title, items);
			}
			else if (s == 'BuyOneBox') {
				box = new BuyOneBox(title, items);
				box.addEventListener(PurchaseEvent.PURCHASE, onPurchase);	//only one is selected
			}
			else if (s == 'DonateBox') {
				box = new DonateBox(title, items);
				box.addEventListener(PurchaseEvent.DONATE, onDonate);
			}
			else if (s == 'RewardBox') {
				box = new RewardBox(title, items);
				box.addEventListener(ScriptEvent.REWARD, onReward);
			}
			else if (s == 'Sprite') {
				var sp:Sprite = createPopupSprite(popup);
                _canvas.addChild(sp);
                return; //prevent from add to stage
			}
			else {
				throw new ScriptEngineError('Unknown popup show type: ' + s);
			}
			if (box != null) {
				_stage.addChild(box);
				//box.x = (_stage.width - box.width) / 2;
				//box.y = (Math.min(_stage.height,_stage.stageHeight) - box.height) / 2;
			} else {
				trace('!!! box is null');
			}
		}

		/**
         * Create a Sprite object for a popup control.
         */
		protected function createPopupSprite(popup:Object):Sprite
        {
			trace('createPopupSprite');
            var sp:Sprite = new Sprite();
            sp.x = popup.x;
            sp.y = popup.y;
            if (popup.filters) {
                sp.filters = Utils.formatFilters(popup.filters);
            }
            if (popup.id) {
                var url:String = '/mm/vgb_'+popup.id+'?v='+(popup.ver || 0);
				trace('about to load ' + url);
                _dm.loadImage(url, function(ldr:Loader):void {
                    sp.addChild(ldr);
                },function(res:Object):void{trace(res.error);});
            }
			return sp;
        }
        
		/**
		 * Accepted a reward event. Send to server to get result. Only one reward a page assumed.
		 * @param	e
		 */
		protected function onReward(e:ScriptEvent):void
		{
			trace('onReward');
			var vg:int = parseInt(e.item as String);
			_dm.post('/page/reward', { bk:_book, pg:_page, vg:vg }, function(es:String, ds:Object):void {
				if (es == Event.COMPLETE) {
					trace(ds);
					if (ds.error) {
						showMessage(ds.error);
					} else {
						//ds.item: {item.id, ver, name, note}
						var msg:MessageBox = new MessageBox('You got a Reward!', [ds.item]);
						_stage.addChild(msg);
						//msg.x = (Math.max(0, Math.min(_stage.stageWidth, _stage.width)) - msg.width) / 2;
						//msg.y = (Math.max(0, Math.min(_stage.stageHeight, _stage.height)) - msg.height) / 2;
						delete _rewards[ds.item.id.toString()];
						notifyInventory(vg.toString(), 1);
					}
				}
			}, function(msg:String):void {
				trace(msg);
			} );
		}
		
		/**
		 * Action to send server a collect-a-gift command.
		 * Return: {item:id,qty:1,name:item_name}
		 * @param	params : {item:id,qty:1}
		 */
		protected function doCollect(params:Object):void
		{
			trace('collect an item');
			//params['pg'] = _page;
			_dm.post('/page/collect', { bk:_book, pg:_page, vg:params.item, qty:params.qty }, function(es:String, ds:Object):void {
				if (es != Event.COMPLETE) return;
				if (ds.error)
					showMessage(ds.error);
				else {
					var msg:MessageBox = new MessageBox('Congratulations! You collected', [{id:ds.item,ver:0,name:ds.name}]);
					_stage.addChild(msg);
					//msg.x = (_stage.width - msg.width) / 2;
					//msg.y = (Math.min(_stage.height, _stage.stageHeight) - msg.height) / 2;
					delete _rewards[ds.item.toString()];
					notifyInventory(params.item.toString(), params.qty);
				}
			}, function(msg:String):void {
				trace(msg);
			} );
		}
		
		/**
		 * Process purchase action.
		 * @param	e
		 */
		protected function onPurchase(e:PurchaseEvent):void
		{
			var items:String = e.items;
			var env:Environment = Environment.instance;
			env.purchase(items, function(re:Object):void {
				trace('Main.onPurchase(', re, ')');
				if (re.error) {
					showMessage(re.error);
				} else {
					showMessage('Thank you.');
					//if action available, try it
					trace('>>>TODO: modify PurchaseEvent to include control index, so as to link to action after purchase');
				}
			} );
		}
		
		/**
		 * Donate some money without buying anything.
		 * @param	e
		 */
		protected function onDonate(e:PurchaseEvent):void
		{
			//var items:Array = e.items.split(':'); //id:qty
			var qty:int = parseInt(e.items);
			var env:Environment = Environment.instance;
			env.donate({pid:_page,pts:qty}, function(re:Object):void {
				trace('Main.onPurchase(', re, ')');
				if (re.error) {
					showMessage(re.error);
				} else {
					showMessage('Thank you.');
					//if action available, try it
					trace('>>>TODO: modify PurchaseEvent to include control index, so as to link to action after purchase');
				}
			});
		}
		
		/**
		 * Show a message box.
		 * @param	msg
		 */
		private function showMessage(msg:String):void
		{
			//var emsg:MsgBox = new MsgBox(msg, 200, 80, false, 3000);
			var emsg:MessageBox = new MessageBox(null, msg);
			//emsg.x = (Math.min(740, _stage.width) - emsg.width) / 2;
			//emsg.y = (Math.min(600, _stage.height) - emsg.height) / 2;
			_stage.addChild(emsg);
		}

		/**
		 * Do an action if available for a control.
		 * @param	action - action data
		 * @param	evs - from which event this is called
		 */
		protected function doAction(action:Object, evs:String):void
		{
			trace('doAction, event is ', evs, 'action = ', action);
			var params:Object = action.params;
			var method:String = action.method;
			var layer:int = 0;
			if (method == 'show') {
				layer = params.layer;	//index or id?
				if (layer >= 0 && layer < _layers.length) {
					_layers[layer].show();
				}
			}
			else if (method == 'hide') {
				layer = params.layer;	//index or id?
				if (layer >= 0 && layer < _layers.length) {
					_layers[layer].hide();
				}
			}
			else if (method == 'switch') {
				layer = params.layer;	//index or id?
				var group:int = params.group;
				
				if (layer >= 0 && layer < _layers.length) {
					for (var i:int = 0, l:SuiLayer; l = _layers[i]; i++) {
						if (l.group == group) {
							if (i != layer) {
								l.hide();
							}
						}
					}
					_layers[layer].show();
				}
			}
			else if (method == 'collect') {
				doCollect(params);
			}
			else if (method == 'reward') {
				var vg:int = params.vgid;
				_dm.post('/page/reward', { bk:_book, pg:_page, vg:vg }, function(es:String, ds:Object):void {
					trace(ds);
					if (ds.error) {
						showMessage(ds.error);
					} else {
						//ds.item: {item.id, ver, name, note}
						var msg:MessageBox = new MessageBox('You got a Reward!', [ds.item]);
						_canvas.addChild(msg);
						notifyInventory(ds.item.id.toString(), 1);
					}
				}, function(msg:String):void {
					trace(msg);
				} );
			}
			else if (method == 'browse') {
				var link:URLRequest = new URLRequest(params.url);
				navigateToURL(link, '_blank');
			}
		}
		
		/**
		 * Mouse clicked on an added button/sprite.
		 * @param	e
		 */
		protected function onMouseClick(e:MouseEvent):void {
			var sp:Sprite = e.currentTarget as Sprite;
			var i:int = parseInt(sp.name);
			var so:Object = _scriptObject.controls[i];
			if (so.popup) {
				showPopup(so.popup, MouseEvent.CLICK);
			} else if (so.action) {
				doAction(so.action, MouseEvent.CLICK);
			}
			if (so.sp) {
				if (so.sp.parent) so.sp.parent.removeChild(so.sp);
			}
		}
		
		/**
		 * Mouse moved over an added sprite to show tip if any.
		 * @param	e
		 */
		protected function onMouseOver(e:MouseEvent):void {
			var sp:Sprite = e.currentTarget as Sprite;
			var i:int = parseInt(sp.name);
			var so:Object = _scriptObject.controls[i];
			if (so.area) {
				if (so.area.tip) {
					_tip.htmlText = so.area.tip;
					_stage.addChild(_tip);
					_tip.x = e.stageX;
					_tip.y = e.stageY + 20;
				}
			}
		}
		
		/**
		 * Mouse moving on an added sprite to show tip if any.
		 * @param	e
		 */
		protected function onMouseMove(e:MouseEvent):void {
			if (_stage.contains(_tip)) {
				_tip.x = e.stageX;
				_tip.y = e.stageY + 20;
			}
		}
		
		/**
		 * Mouse left an added sprite to show tip if any.
		 * @param	e
		 */
		protected function onMouseOut(e:MouseEvent):void {
			if (_stage.contains(_tip)) {
				_stage.removeChild(_tip);
			}
		}
		
		/**
		 * Time out for a timer on a control. There can be multiple timers, each for a control.
		 * @param	e
		 */
		protected function onTimer(e:TimerEvent):void {
			var tt:TriggerTimer = e.currentTarget as TriggerTimer;
			var i:int = tt.index;
			var so:Object = _scriptObject.controls[i];
			if (so.popup) {
				showPopup(so.popup, TimerEvent.TIMER);
			} else if (so.action) {
				doAction(so.action, TimerEvent.TIMER);
			}
		}
		
		public function notifyInventory(vid_: String, qty_: int): void
		{
			var env:Environment = Environment.instance;
			env.calljs('collected', { vid:vid_, qty:qty_ }, null);
		}
		
	}

}