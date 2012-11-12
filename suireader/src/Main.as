package 
{
	import com.suinova.pe.DataManager;
	import com.suinova.pe.MsgBox;
	import com.suinova.pe.PetiButton;
	import com.suinova.sgapi.Environment;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.ui.Mouse;
	
	/**
	 * Suinova-Comics Reader
	 * 
	 * @author Ted Wen
	 */
	public class Main extends Sprite 
	{
		private const CANVAS_WIDTH:int = 740;
		private const EDGEBAR_WIDTH:int = 32;
		private const shadowFilter: DropShadowFilter = new DropShadowFilter();
		private const glowFilter:GlowFilter =  new GlowFilter();
		private const BARDIR:Object = { 'left':0, 'right':1 };
		
		private var _testboard: TextField;
		private var _layers: Array;
		private var _pagenum: TextField;	// MsgBox;
		private var _leftBar: Sprite;
		private var _rightBar: Sprite;

		private var _dm: DataManager;
		private var _book: Book = null;
		private var _scriptEngine:ScriptEngine;
		
		private var _cursors: Array;
		//private var _leftCursor: Sprite = null;
		//private var _rightCursor: Sprite = null;
		
		[Embed(source = '../lib/handl.png')]
		private const HandLeft:Class;
		[Embed(source = '../lib/handr.png')]
		private const HandRight:Class;
		[Embed(source = '../lib/thumbs_up.png')]
		private const ThumbUp:Class;
		[Embed(source = '../lib/First.gif')]
		private const FirstArrow:Class;
		[Embed(source = '../lib/Previous.gif')]
		private const PrevArrow:Class;
		[Embed(source = '../lib/Next.gif')]
		private const NextArrow:Class;
		[Embed(source = '../lib/Last.gif')]
		private const LastArrow:Class;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP;
			
			createLayers();
			
			_testboard = new TextField();
			_testboard.width = 640;
			_testboard.height = 300;
			_testboard.wordWrap = true;
			_testboard.x = 10;
			_testboard.y = 10;
			_testboard.mouseEnabled = false;
			addChild(_testboard);

			createCursors();
			createBar(_leftBar, 'left', 0);
			createBar(_rightBar, 'right', CANVAS_WIDTH - EDGEBAR_WIDTH);
			
			_scriptEngine = new ScriptEngine(stage, _layers[0]);
			initData();
			
			createButtons();
			
			//add go to first page button at lower-left corner
		/*	var gofirst: PetiButton = new PetiButton(60, 20, '|< First');
			addChild(gofirst);
			gofirst.y = stage.stageHeight - 30;
			gofirst.x = 10;
			gofirst.addEventListener(MouseEvent.CLICK, onGoFirstPage);
			//like button
			var likebtn: PetiButton = new PetiButton(60, 20, 'Like');
			addChild(likebtn);
			likebtn.x = gofirst.x + gofirst.width + 10;
			likebtn.y = gofirst.y;
			likebtn.addEventListener(MouseEvent.CLICK, onLikeButton);*/
		}
		
		private function createButtons():void
		{
			_pagenum = new TextField();
			var tf:TextFormat = new TextFormat('Arial', 18, 0, true);
			tf.align = 'center';
			tf.color = 0xFFFF00;
			_pagenum.defaultTextFormat = tf;
			_pagenum.text = '- 1 -';
			_pagenum.width = 100;
			_pagenum.height = 32;
			_pagenum.x = (stage.stageWidth - _pagenum.width) / 2;
			_pagenum.y = stage.stageHeight - 30;
			_pagenum.mouseEnabled = false;
			_pagenum.filters = [shadowFilter, glowFilter];
			addChild(_pagenum);
			var btnGlow:GlowFilter = new GlowFilter(0xffff00);
			var firstButton:Sprite = new Sprite();
			var firstIcon:Bitmap = new FirstArrow();
			firstButton.addChild(firstIcon);
			firstButton.x = _pagenum.x - 64;
			firstButton.y = _pagenum.y - 3;
			//firstButton.mouseEnabled = true;
			firstButton.buttonMode = true;
			firstButton.filters = [shadowFilter, btnGlow];
			firstButton.addEventListener(MouseEvent.CLICK, onGoFirstPage);
			addChild(firstButton);
			var prevButton:Sprite = new Sprite();
			var prevIcon:Bitmap = new PrevArrow();
			prevButton.addChild(prevIcon);
			prevButton.x = _pagenum.x - 32;
			prevButton.y = _pagenum.y - 3;
			prevButton.buttonMode = true;
			prevButton.filters = [shadowFilter, btnGlow];
			prevButton.addEventListener(MouseEvent.CLICK, onGoPrevPage);
			addChild(prevButton);
			var nextButton:Sprite = new Sprite();
			var nextIcon:Bitmap = new NextArrow();
			nextButton.addChild(nextIcon);
			nextButton.x = _pagenum.x + _pagenum.width + 1;
			nextButton.y = _pagenum.y - 3;
			nextButton.buttonMode = true;
			nextButton.filters = [shadowFilter, btnGlow];
			nextButton.addEventListener(MouseEvent.CLICK, onGoNextPage);
			addChild(nextButton);
			var lastButton:Sprite = new Sprite();
			var lastIcon:Bitmap = new LastArrow();
			lastButton.addChild(lastIcon);
			lastButton.x = nextButton.x + 32;
			lastButton.y = _pagenum.y - 3;
			lastButton.buttonMode = true;
			lastButton.filters = [shadowFilter, btnGlow];
			lastButton.addEventListener(MouseEvent.CLICK, onGoLastPage);
			addChild(lastButton);
			var likeButton:Sprite = new Sprite();
			var likeIcon:Bitmap = new ThumbUp();
			likeButton.addChild(likeIcon);
			likeButton.x = 10;
			likeButton.y = firstButton.y;
			likeButton.buttonMode = true;
			likeButton.filters = [shadowFilter, glowFilter];
			likeButton.addEventListener(MouseEvent.CLICK, onLikeButton);
			addChild(likeButton);
		}
		
		private function createLayers(n:int=1):void
		{
			_layers = new Array(n);
			for (var i:int = 0; i < n; i++) {
				_layers[i] = new Sprite();
				addChild(_layers[i]);
			}
		}
		
		private function createBar(bar:Sprite, name_:String, x_:int):void
		{
			bar = new Sprite();
			bar.graphics.beginFill(0x0, 0);
			bar.graphics.lineStyle(1, 0, 0);
			bar.graphics.drawRect(0, 0, EDGEBAR_WIDTH, stage.stageHeight);
			bar.x = x_;
			bar.y = 0;
			//bar.buttonMode = true;
			//bar.useHandCursor = true;
			bar.name = name_;
			addChild(bar);
			bar.addEventListener(MouseEvent.MOUSE_OVER, function(e: MouseEvent):void {
				showCursor(e.target.name, e.stageX, e.stageY);
				} );
			bar.addEventListener(MouseEvent.MOUSE_MOVE, function(e: MouseEvent):void {
				showCursor(e.target.name, e.stageX, e.stageY);
				} );
			bar.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				showCursor(null);
			});
			bar.addEventListener(MouseEvent.CLICK, onBarClick);
		}
		
		private function onBarClick(e:MouseEvent):void
		{
			var pg:int = _book.cpage;
			if (e.currentTarget.name == 'left') pg--; else pg++;
			if (pg >= 0 && pg < _book.pageCount)
				loadPage(pg);
		}
		
		private function onGoFirstPage(e:MouseEvent):void
		{
			var pg:int = _book.cpage;
			if (pg < 0) return;
			if (pg >= _book.pageCount) return;
			pg = 0;
			loadPage(pg);
		}
		private function onGoPrevPage(e:MouseEvent):void
		{
			var pg:int = _book.cpage - 1;
			if (pg >= 0 && pg < _book.pageCount)
				loadPage(pg);
		}
		private function onGoNextPage(e:MouseEvent):void
		{
			var pg:int = _book.cpage + 1;
			if (pg >= 0 && pg < _book.pageCount)
				loadPage(pg);
		}
		private function onGoLastPage(e:MouseEvent):void
		{
			var pg:int = _book.lastpage;
			if (pg >= 0 && pg < _book.pageCount)
				loadPage(pg);
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
		 * {cookie:'SC_Session="xxxx=xxx",host:"",book:n,page:n}
		 * If external interface is not found in case of standalone debugging, a random uid is generated to call the server.
		 */
		private function initData(): void
		{
			var env:Environment = Environment.instance;
			_dm = DataManager.instance;
			//addMsg('Calling ExternalInterface...');
			//Security.allowDomain("qui-hua.appspot.com");	//for externalinterface call
			if (env.hasExternalInterface()) {
				//addMsg('Environment.loadEnv...');
				env.loadEnv('suireader',function(resp:Object):void { 
					//return {cookie:'SC_Session="xxxx=xxx",host:"",book:n,page:n}.
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
						var bkid:String = resp.book;
						var pg:int = resp.page;
						//addMsg('book=' + bkid + ',page=' + pg);
						_book = new Book(bkid, pg);
						loadBook(bkid);
						//view page by loading image, setting background button transparent layer
					}
				} );
			} else {
				//test only
				_dm.setBaseURL('http://localhost:8084');
				_book = new Book('26');
				loadBook('26');
				//view
			}
		}

		/**
		 * Load all pages of the given book from the server.
		 * @param	bid
		 */
		public function loadBook(bid:String):void
		{
			//load page list from server via dm
			var url: String = '/book/pages/' + bid;
			_dm.post(url, null, function(e:String, ds:Object):void {
				if (e == Event.COMPLETE) {
					if (ds == null)
						showMessage('Error','Book not found');
					else if (ds.error)
						showMessage('Error',ds.error);
					else {
						_book.setPages(ds as Array);
						loadPage(_book.cpage);
					}
				}
			}, function(msg:String):void {
				trace('loadBook returned error:', msg);
			} );
		}

		/**
		 * Delete all child display objects on all layers.
		 */
		private function clearPage(): void
		{
			for (var i:int = 0, l:Sprite; l = _layers[i] as Sprite; i++) {
				while (l.numChildren > 0) l.removeChildAt(0);
			}
			graphics.clear();
		}
		
		/**
		 * Create a layer by instantiating a SuiLayer class extended from Sprite.
		 * @param	i: which layer from 1
		 * @param	layer : {id,ver,x,y,..}
		 */
		private function loadLayer(i:int, layer:Object): void
		{
			trace('>>>TODO: loadLayer');
			var url:String = '/mm/vgb_' + layer.id + '?v=' + layer.ver;
			var sp:Sprite = new Sprite();
			_dm.loadImage(url, function(ldr:Loader):void {
				sp.addChild(ldr);
				ldr.x = layer.x;
				ldr.y = layer.y;
				}, function(re:Object):void { trace(re.error); } );
			if (_layers.length <= i) _layers.push(sp); else _layers[i] = sp;
		}
		
		/**
		 * Align a displayobject on canvas.
		 * @param	o : DisplayObject
		 * @param	align : lcrtmb (for left, center, right, top, middle, bottom)
		 */
		private function alignLayer(o:DisplayObject, align:String):void
		{
			trace('stage width=', stage.stageWidth, 'stage height=', stage.stageHeight, 'o.width=', o.width, 'o.height=', o.height, 'align=', align, 'o.x=', o.x, 'o.y=', o.y);
			if (o.width < stage.stageWidth) {
				if (align.indexOf('c') >= 0)
					o.x = (stage.stageWidth - o.width) / 2;
				else if (align.indexOf('r') >= 0)
					o.x = stage.stageWidth - o.width;
			}
			if (o.height < stage.stageHeight) {
				if (align.indexOf('m') >= 0)
					o.y = (stage.stageHeight - o.height) / 2;
				else if (align.indexOf('b') >= 0)
					o.y = stage.stageHeight - o.height;
			}
			trace('after: o.x=', o.x, 'o.y=', o.y,'parent.y=',o.parent.x);
		}
		
		private function loadPage(pg:int):void
		{
			_book.cpage = pg;
			_pagenum.text = '- ' + (pg + 1) + ' -';
			var url:String = '/page/' + _book.id + '/' + pg;
			trace(url);
			_dm.loadImage(url, function(ldr:Loader):void {
				//var canvas:Sprite = _layers[0];
				clearPage();
				//while (canvas.numChildren > 0) canvas.removeChildAt(0);
				var o:DisplayObject = _layers[0].addChild(ldr);
				//load other layers if any
				var layrs:Array = _book.pages[pg].layers;
				if (layrs.length > 0) {
					//for each layer, load /page/layer/bkid/pg/layer
					for (var i:int = 0; i < layrs.length; i++) {
						if (layrs[i].id == 0) {
							//{id:0,align:"lcrtmb",filters:["",""],x:,y:,w:,h:,..}
							if (layrs[i].align) {
								alignLayer(o, layrs[i].align);
							}
							if (layrs[i].filters) {
								o.filters = Utils.formatFilters(layrs[i].filters);
							}
							if (layrs[i].bc) {
								var bc:uint = Utils.parseColor(layrs[i].bc);
								graphics.beginFill(bc);
								graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
								graphics.endFill();
							}
						} else
							loadLayer(i+1, layrs[i]);
					}
				} else {
					alignLayer(o, 'cm');	//default center on page
				}
				if (_book.pages[pg].script) {
					_scriptEngine.setScript(_book.id, _book.pages[pg].id, _book.pages[pg].script, _layers, _book.rewards);
					_scriptEngine.run();
				}
			}, function(re:Object):void {
				//var canvas:Sprite = _layers[0];
				//while (canvas.numChildren > 0) canvas.removeChildAt(0);
				clearPage();
				if (re.page) {
					_book.cpage = re.page;
					_pagenum.text = '- ' + (_book.cpage + 1) + ' -';
				}
				var errmsg:String = re.error;
				trace(errmsg);
				//errmsg = 'require';
				//re['vgs'] = [{id:292,name:'Card-1',price:10.0,note:'This page is a portal to the next world, so we must buy a pass here.'},{id:296,name:'Armour',price:20.0,note:'Our hero Max must be equipped with this armour before entering the cave.'},{id:297,name:'Weapon1',price:100.0,note:'June needs a weapon! Buy this Multigun for her, please.'}];
				//re['vgs'] = [{id:292,name:'Card-1',price:10.0,note:'This page is a portal to the next world, so we must buy a pass here.'}];
				if (errmsg == 'require') {
					//ask to buy vgs
					//var vgs:Array = re.vgs; //[{"id":%d,"name":"%s","price":%0.2f,"note":"%s"},..
					var buybox: PurchaseBox = new PurchaseBox(re.vgs);
					//var buybox: BuyOneBox = new BuyOneBox('Required Items', re.vgs);
					stage.addChild(buybox);
					buybox.x = (stage.width - buybox.width) / 2;
					buybox.y = (stage.height - buybox.height) / 2;
					buybox.addEventListener(PurchaseEvent.PURCHASE, onPurchase);
				} else {
					showMessage('Error',errmsg);
				}
			});
		}
		
		private function showMessage(title:String, msg:String):void
		{
			var msgbox: MessageBox = new MessageBox(title,msg,200);
			stage.addChild(msgbox);
			return;
			/*
			var emsg:MsgBox = new MsgBox(msg, 200, 80, false, 3000);
			emsg.x = (Math.min(720, stage.width) - emsg.width) / 2;
			emsg.y = (Math.min(740, stage.height) - emsg.height) / 2;
			stage.addChild(emsg);
			emsg.addEventListener(Event.CLOSE, function(e:Event):void { stage.removeChild(emsg); } );*/
		}
		
		private function onPurchase(e:PurchaseEvent):void
		{
			var items:String = e.items;
			var env:Environment = Environment.instance;
			env.purchase(items, function(re:Object):void {
				trace('Main.onPurchase(', re, ')');
				if (re.error) {
					showMessage('Error',re.error);
				} else {
					loadPage(_book.cpage);
				}
			} );
		}
		/**
		 * Donate some money without buying anything.
		 * @param	e
		 */
		private function onDonate(e:PurchaseEvent):void
		{
			//var items:Array = e.items.split(':'); //id:qty
			var qty:int = parseInt(e.items);
			var env:Environment = Environment.instance;
			env.donate({pid:_book.cpage,pts:qty}, function(re:Object):void {
				trace('Main.onPurchase(', re, ')');
				if (re.error) {
					showMessage('Error',re.error);
				} else {
					showMessage('Thank you.',null);
				}
			});
		}
		private function onLikeButton(e:MouseEvent):void
		{
			var box:DonateBox = new DonateBox('Thank you!', [{"id":1,"ver":0,"price":5,"note":"I'm glad you like this page! Please donate 5 Sudos to support my work. Thank you!"}]);
			box.addEventListener(PurchaseEvent.DONATE, onDonate);
			stage.addChild(box);
		}
	}
	
}