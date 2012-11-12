package 
{
	import com.suinova.pe.DataManager;
	import com.suinova.pe.MsgBox;
	import com.suinova.sgapi.Environment;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	/**
	 * Suinova-Comics Gallery
	 * 
	 * @author Ted Wen
	 */
	public class Main extends Sprite 
	{
		private const CANVAS_WIDTH:int = 740;
		private const shadowFilter: DropShadowFilter = new DropShadowFilter();
		private const glowFilter:GlowFilter =  new GlowFilter(0x0000FF, 1, 15);
		
		private var _testboard: TextField;
		//private var _layers: Array;
		private var _gallery:GalleryView; 
		private var _name:TextField;	//gallery owner's name

		private var _dm: DataManager;
		private var _uid: String;
		
		//private var _cursors: Array;
		[Embed(source = '../lib/SuiGallery-splash.png')]
		private var Splash:Class;
		private var _splash:Bitmap;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;

			_gallery = new GalleryView();
			addChild(_gallery);

			_splash = new Splash();
			_splash.x = (Math.max(stage.stageWidth,stage.width) - _splash.width) / 2;
			_splash.y = (Math.max(stage.height, stage.stageHeight) - _splash.height) / 2;
			addChild(_splash);
			//createLayers();
			
			_testboard = new TextField();
			_testboard.width = 640;
			_testboard.height = 300;
			_testboard.wordWrap = true;
			_testboard.x = 10;
			_testboard.y = 10;
			_testboard.mouseEnabled = false;
			addChild(_testboard);
			
			_name = new TextField();
			var tfmt:TextFormat = new TextFormat('Arial');
			tfmt.size = 18;
			_name.autoSize = 'left';
			_name.selectable = false;
			_name.defaultTextFormat = tfmt;
			_name.textColor = 0xffff00;
			_name.x = 5;
			_name.y = 5;
			_name.filters = [new GlowFilter(), new DropShadowFilter()];
			addChild(_name);

			var prompt:TextField = new TextField();
			var tf:TextFormat = new TextFormat('Arial', 16, 0, true);
			tf.align = 'center';
			tf.color = 0x0000ff;
			prompt.autoSize = 'center';
			prompt.defaultTextFormat = tf;
			prompt.text = 'To decorate your gallery, Use the items in your inventory below.';
			prompt.width = 100;
			prompt.height = 32;
			prompt.x = (stage.stageWidth - prompt.width) / 2;
			prompt.y = 10;
			prompt.mouseEnabled = false;
			//prompt.filters = [new DropShadowFilter(2)];
			addChild(prompt);
			setTimeout(function():void { 
				prompt.parent.removeChild(prompt);
				}, 8000);
			
			//createCursors();
			
			initData();
		}
/*		
		private function createLayers(n:int=1):void
		{
			_layers = new Array(n);
			for (var i:int = 0; i < n; i++) {
				_layers[i] = new Sprite();
				addChild(_layers[i]);
			}
		}
		
		private function showCursor(bar:String, x:int=0, y:int=0):void
		{
			if (bar == null) {
				_cursors[0].visible = false;
				_cursors[1].visible = false;
				//Mouse.show();
			} else {
				//Mouse.hide();
				_cursors[BARDIR[bar]].visible = true;
				_cursors[BARDIR[bar]].x = (bar=='left')?x+1:x-30;
				_cursors[BARDIR[bar]].y = y-11;
			}
		}
		
		private function createCursors():void
		{
			var bmps:Array = [new HandLeft(), new HandRight()];
			_cursors = [new Sprite(), new Sprite()];
			for (var i:int = 0; i < bmps.length; i++) {
				_cursors[i].graphics.beginBitmapFill(bmps[i].bitmapData);
				_cursors[i].graphics.drawRect(0, 0, bmps[i].width, bmps[i].height);
				_cursors[i].graphics.endFill();
				_cursors[i].mouseEnabled = false;
				_cursors[i].mouseChildren = false;
				_cursors[i].visible = false;
				stage.addChild(_cursors[i]);
			}
		}
*/
		private function addMsg(msg:String):void
		{
			if (typeof(_testboard) != undefined) {
				_testboard.appendText('\r\n' + msg);
			}
		}
		/**
		 * Prepare initial data loading from server by detecting player id from the browser.
		 * The player may have logged in to a SNS like Facebook and has got a valid access_token already.
		 * By calling getEnv from external JavaScript code, an environment dataset can be obtained containing sth like:
		 * {cookie:'SC_Session="xxxx=xxx",host:"",book:n,page:n,user:uid}
		 * If external interface is not found in case of standalone debugging, a random uid is generated to call the server.
		 */
		private function initData(): void
		{
			var env:Environment = Environment.instance;
			_dm = DataManager.instance;
			//addMsg('Calling ExternalInterface...');
			if (env.hasExternalInterface()) {
				//addMsg('Environment.loadEnv...');
				env.loadEnv('suigallery',function(resp:Object):void { 
					//return {cookie:'SC_Session="xxxx=xxx",host:"",book:n,page:n,user:uid}.
					if (resp) {
						//addMsg(resp.host);
						_dm.setBaseURL(resp.host);
						var s:String = resp.cookie;
						var n:int = s.indexOf('SC_Session');
						if (n >= 0) {
							var n1:int = s.indexOf('"', n);
							var n2:int = s.indexOf('"', n1 + 1);
							_dm.setEnv( { 'SC_Session':s.substring(n1, n2 + 1) } );
							//addMsg('SC_Session = ' + s.substring(n1, n2 + 1));
						}
						n1 = s.indexOf('uid=');
						n2 = s.indexOf('&', n1); if (n2 < 0) n2 = s.indexOf('"', n1);
						if (n2 > n1) _uid = s.substring(n1 + 4, n2);
						if (resp.user) {
							loadGallery(resp.user);
						}else{
							loadGallery(_uid);
						}
					}
				} );
			} else {
				//test only
				_dm.setBaseURL('http://localhost:8084');
				//_book = new Book('290');
				//loadBook('290');
				_uid = 'gg_185804764220139124118';
				//view
				loadGallery(_uid);
			}
		}

		/**
		 * Load info about somebody's gallery from the server.
		 * {"uid":"%s","name":"%s","rooms":%d,"items":%d,"content":%s,"vgs":{['"%s":{"name":"%s","v":%d,"note":"%s","bk":%s}}}
		 * @param	uid - user keyname
		 */
		public function loadGallery(uid:String):void
		{
			//load page list from server via dm
			var url: String = '/gallery/all/' + uid;
			_dm.post(url, null, function(e:String, ds:Object):void {
				if (e == Event.COMPLETE) {
					if (ds == null) {
						trace('ds returned null');
					} else
					if (ds['error']) {
						trace(ds.error);
					} else {
						_gallery.setGallery(ds, isOwner(uid));
						_gallery.drawAll();
						removeChild(_splash);
						if (ds.name)
							_name.text = ds.name + "'s gallery ";
						if (ds.give) {
							Confirm.show(stage, 'Send a free credit to your friends?', ['Yes', 'No'], function(res:String):void {
								//call env.post
								if(res == 'Yes') {
									var en:Environment = Environment.instance;
									en.calljs('sendCredits', { }, function(ds:Object):void {
										trace('credits sent to friends',ds);
									} );
								}
							} );
						}
					}
				}
			}, function(msg:String):void {
				trace('loadBook returned error:', msg);
				showMessage(msg);
			} );
		}
		
		private function isOwner(uid:String):Boolean
		{
			return (uid == _uid);
		}

		private function showMessage(msg:String):void
		{
			var emsg:MsgBox = new MsgBox(msg, 200, 80, false, 3000);
			emsg.x = (Math.min(720, stage.width) - emsg.width) / 2;
			emsg.y = (Math.min(740, stage.height) - emsg.height) / 2;
			stage.addChild(emsg);
			emsg.addEventListener(Event.CLOSE, function(e:Event):void { stage.removeChild(emsg); } );
		}
		
		private function onPurchase(e:PurchaseEvent):void
		{
			var items:String = e.items;
			var env:Environment = Environment.instance;
			env.purchase(items, function(re:Object):void {
				trace('Main.onPurchase(', re, ')');
				if (re.error) {
					showMessage(re.error);
				} else {
					//loadPage(_book.cpage);
				}
			} );
		}
		
	}
	
}