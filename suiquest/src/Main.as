package 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import com.suinova.pe.DataManager;
	import com.suinova.sgapi.Environment;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	/**
	 * Main class for SuiQuest application.
	 * 
	 * @author Ted Wen
	 */
	public class Main extends Sprite 
	{
		private const CANVAS_WIDTH:int = 740;
		
		private var _dm: DataManager;
		private var _uid: String;
		private var _grayColorFilter: ColorMatrixFilter;
		private var _grayColorFilter2: ColorMatrixFilter;
		private var _grayColor: Number = .3;
		private var _grayAlpha: Number = .3;

        private var _quests: Object;
		private var _missing: Object;
        private var _canvas: Sprite;
        private var _name: TextField;
        private var _progressBar: ProgressBar;
        private var _itemCount: int;
		private var _intervalId: int;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;

			_grayColorFilter = createGrayFilter(_grayColor, _grayAlpha);
			_grayColorFilter2 = createGrayFilter(_grayColor, _grayAlpha + 0.2);
			
            createHeader();
            
			initData();
		}
        
        private function createHeader():void
        {
			_canvas = new Sprite();
            addChild(_canvas);
            
            _name = new TextField();
			var fmt:TextFormat = new TextFormat('Arial',18,0xffff00,true);
			_name.defaultTextFormat = fmt;
			_name.filters = [new DropShadowFilter(), new GlowFilter()];
            _name.x = 5;
            _name.y = 5;
            addChild(_name);
			_name.autoSize = 'left';
			_name.text = 'Mysterious Cave';
			
            _progressBar = new ProgressBar(100,18);
            addChild(_progressBar);
            _progressBar.x = 620;
            _progressBar.y = 10;
			_progressBar.update(0);
        }

		/**
		 * Create a gray color filter for unfilled sprites.
		 * To apply: o.filters = [createGrayFilter(.33)];
		 */
		private function createGrayFilter(gc:Number, ga:Number):ColorMatrixFilter
		{
			return new ColorMatrixFilter([gc, gc, gc, 0, 0, gc, gc, gc, 0, 0, gc, gc, gc, 0, 0, 0, 0, 0, ga, 0]);
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
			if (env.hasExternalInterface()) {
				//addMsg('Environment.loadEnv...');
				env.loadEnv('suiquest',function(resp:Object):void { 
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
						n1 = s.indexOf('uid=');
						n2 = s.indexOf('&', n1); if (n2 < 0) n2 = s.indexOf('"', n1);
						if (n2 > n1) _uid = s.substring(n1 + 4, n2);
						loadQuest(resp.book);
					}
				} );
			} else {
				//test only
				_dm.setBaseURL('http://localhost:8084');
				_uid = 'gg_185804764220139124118';
				loadQuest(26);
			}
		}
		
		/**
		 * Load quest info from server.
         * {quests:
		 * [{"qid":390,"qname":"Mysterious Cave","items":[{"vgid":391,"x":155,"y":308,"sc":1.0,"filters":[],"tip":"on page x"},{"vgid":392,"x":265,"y":78,"sc":1.0,"filters":[]},{"vgid":393,"x":445,"y":315,"sc":1.0,"filters":[]},{"vgid":394,"x":575,"y":30,"sc":1.0,"filters":[]},{"vgid":395,"x":340,"y":252,"sc":1.0,"filters":[],"tip":"This item is in page 20."}],"prize":303}],
         * "filled":[391,392]}
		 * @param	bkid
		 */
		private function loadQuest(bkid:int):void
		{
            clearCanvas();
			//load page list from server via dm
			var url: String = '/book/quests/' + bkid;
			_dm.post(url, null, function(e:String, ds:Object):void {
				if (e == Event.COMPLETE) {
		//ds = {filled:[391, 392], quests: [{"qid":390,"qname":"Mysterious Cave","items":[{"vgid":391,"x":155,"y":308,"sc":1.0,"filters":[],"tip":"on page x"},{"vgid":392,"x":265,"y":78,"sc":1.0,"filters":[]},{"vgid":393,"x":445,"y":315,"sc":1.0,"filters":[]},{"vgid":394,"x":575,"y":30,"sc":1.0,"filters":[]},{"vgid":395,"x":330,"y":260,"sc":0.8,"filters":[],"tip":"This item is in page 20."}],"prize":303}]};
					if (ds == null) {
						trace('ds returned null');
					} else
					if (ds['error']) {
						trace(ds.error);
						    var msgbox:MessageBox = new MessageBox(ds.error,[]);
							stage.addChild(msgbox);
					} else {
						trace(ds);
                        _quests = ds;
                        drawScene();
					}
				}
			}, function(msg:String):void {
				trace('loadBook returned error:', msg);
			} );
		}
        
		/**
		 * Remove all sprites on canvas for new quest.
		 */
        private function clearCanvas():void
        {
            while (_canvas.numChildren > 0) {
                _canvas.removeChildAt(0);
            }
			_missing = new Object();
        }
        
		/**
		 * Draw quest name and progress on top of the canvas.
		 * @param	quest
		 * @param	filled
		 */
        private function drawHeader(quest:Object, filled:Array):void
        {
            var name:String = quest.qname;
            var itms:Array = quest.items;
            var p:Number = filled.length / itms.length;
            _name.text = name;
            _progressBar.update(p);
        }
        
		/**
		 * Draw background image and required items on top of it.
		 */
        private function drawScene():void
        {
            if (_quests == null) return;
            var quests:Array = _quests.quests;
            var which:Number = (root.loaderInfo.parameters.q)?root.loaderInfo.parameters.q:0;
            var quest:Object = quests[0];	//TODO: use q from browser?
            //draw header
            drawHeader(quest, _quests.filled);
            //draw _quest.qid
			_itemCount = -1;
            var url:String = '/mm/vgb_'+quest.qid;
            _dm.loadImage(url,function(ldr:Loader):void{
                _canvas.addChild(ldr);
                drawItems(quest, _quests.filled);
				if (quest.intro.length > 0) {
					_intervalId = setInterval(function():void {
						if(_itemCount == 0) {
							var msg:MessageBox = new MessageBox('Quest',quest.intro);
							stage.addChild(msg); 
							clearInterval(_intervalId);
						}
					}, 1000);
				}
            },function(re:Object):void{
                var errmsg:String = re.error;
                trace(errmsg);
            },false);
            //draw other
        }
        
		/**
		 * Draw all items whether collected or not. Collected items are drawn as they are, while missing ones are grayed.
		 * @param	quest
		 * @param	filled
		 */
        private function drawItems(quest:Object, filled:Array):void
        {
            var itms:Array = quest.items;
            var fills:Object = new Object();
            for (var x:int = 0; x < filled.length; x++) {
				var xs:String = filled[x].toString();
				//trace(xs);
                fills[xs] = xs;
			}
			_itemCount = itms.length;
            for (var i:int=0; i<itms.length;i++){
                //{"vgid":391,"x":155,"y":308,"sc":1.0,"filters":[],"tip":""}
                var itm:Object = itms[i];
                var ids:String = itm.vgid.toString();
				trace('ids=', ids,'in fills:',fills[ids]);
                if (fills[ids])
                    drawItem(itm);
                else
                    drawGrayItem(itm);
            }
        }

        /**
         * Draw a collected item with original image.
         * @param	itm
         */
        private function drawItem(itm:Object):void
        {
			trace('found:', itm.vgid);
            _dm.loadImage('/mm/vgb_'+itm.vgid,function(ldr:Loader):void{
                _canvas.addChild(ldr);
				_itemCount --;
                ldr.x = itm.x;
                ldr.y = itm.y;
				if (itm.sc < 1.0) {
					ldr.scaleX = itm.sc;
					ldr.scaleY = itm.sc;
				}
                if (itm.filters && itm.filters.length>0){
                    ldr.filters = Utils.formatFilters(itm.filters);
                }
            },function(re:Object):void{
                trace(re.error);
            },false);
        }
        
		/**
		 * Draw a missing item with gray-color filter, and mouse-over click to show message event handler.
		 * @param	itm
		 */
        private function drawGrayItem(itm:Object):void
        {
			trace('not found:', itm.vgid);
            _dm.loadImage('/mm/vgb_'+itm.vgid,function(ldr:Loader):void{
                _canvas.addChild(ldr);
				_itemCount --;
                ldr.filters = [_grayColorFilter];
                ldr.x = itm.x;
                ldr.y = itm.y;
				if (itm.sc < 1.0) {
					ldr.scaleX = itm.sc;
					ldr.scaleY = itm.sc;
				}
                ldr.name = itm.vgid.toString();
				_missing[ldr.name] = itm;
				ldr.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverItem);
				ldr.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutItem);
                ldr.addEventListener(MouseEvent.CLICK, onItemClick);
            },function(re:Object):void{
                trace(re.error);
            },false);
        }
		
		/**
		 * Highlight the item when mouse over it.
		 * @param	e
		 */
		private function onMouseOverItem(e:MouseEvent):void
		{
			var img:Loader = e.currentTarget as Loader;
			img.filters = [_grayColorFilter2];
		}

		/**
		 * Restore grayed image when mouse out of it.
		 * @param	e
		 */
   		private function onMouseOutItem(e:MouseEvent):void
		{
			var img:Loader = e.currentTarget as Loader;
			img.filters = [_grayColorFilter];
		}

		/**
		 * Show a message box when click on the missing item showing its picture and tip.
		 * @param	e
		 */
        private function onItemClick(e:MouseEvent):void
        {
			var vgid:String = e.currentTarget.name;
			var itm:Object = _missing[vgid];
			trace(itm.tip);
			var itms:Object = { id:vgid, ver:0, name:itm.name || '', note:itm.tip || '' };
            var msgbox:MessageBox = new MessageBox('Find this in the book',[itms]);
            stage.addChild(msgbox);
        }

	}
	
}
