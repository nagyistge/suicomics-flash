package
{
	import com.suinova.pe.DataManager;
	import com.suinova.pe.PetiButton;
	import com.suinova.pe.PetiPanel;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

    /**
     * Reward box.
	 * @author Ted
     */
    public class RewardBox extends PetiPanel
    {
		private var _itm:String;
		
		/**
		 * Show a reward box with a title, an image logo, and a message.
		 * @param	title - title text or 'Reward' if null
		 * @param	items - vg items with log and note if not null
		 * @param	w
		 * @param	h
		 */
        public function RewardBox(title:String,items:Array,w:int=400,h:int=380)
        {
            super(w,h,false,true);
            
            addText((title==null)?'Reward':title,{'size':20,'color':0xffff00,'bold':true});
            addSeparator();
        
            for (var i:int = 0, itm:Object; itm = items[i]; i++) {
				_itm = itm.id;
                addrow(0, itm);
            }
			
            var closeBtn:PetiButton = new PetiButton(0, 0, 'Accept');
            addControl(closeBtn);
            closeBtn.addEventListener(MouseEvent.CLICK, onAccept);
			
			drawGradientBackground(0xC3CDDA, 0x16416B);
        }
		
		private function onAccept(e:MouseEvent):void 
		{
			trace('>>>TODO: send this to server /reader/reward');
			dispatchEvent(new ScriptEvent(ScriptEvent.REWARD, _itm));
			close(); 
		}
		
		/**
		 * Display one row of item.
		 * @param	idx
		 * @param	itm : Object
		 */
        private function addrow(idx:int, itm:Object):void
        {
            //icon, name/note slash is line break
			var left:PetiPanel = new PetiPanel(80, 100, false, false, 10, false);
            var ico:Sprite = new Sprite();
			ico.graphics.beginFill(0, 0);
			ico.graphics.drawRect(0, 0, 50, 50);
			ico.graphics.endFill();
            //ico.x = 2;
            //ico.y = idx * _rowheight + _topmargin;
            left.addControl(ico);
            var dm:DataManager = DataManager.instance;
            dm.loadImage('/mm/vg_'+itm.id+'?v='+itm.ver, function(img:Loader):void{
                ico.addChild(img);
            },function(er:Object):void{
                trace(er.error);
            });
            //name and note
			var right:PetiPanel = new PetiPanel(_width - 110, 100, false, false, 10, false);
			if (typeof(itm.name)!=undefined && itm.name != '') {
				var sname:TextField = createText(itm.name, {'bold':true});
				right.addControl(sname, 'left');
			}
			if (typeof(itm.note) != undefined && itm.note != '') {
				trace('RewardBox, note width:', _width, _width - 140);
				var snote:TextField = createText(itm.note, { 'width':_width - 140, 'align':'left', 'html':true, 'wrap':true } );
				trace('snote.width=', snote.width);
				right.addControl(snote,'left');
            }
			
			addControls([left, right], 'left');
            addSeparator();
        }

    }
}
