package
{
	import com.suinova.pe.DataManager;
	import com.suinova.pe.PetiButton;
	import com.suinova.pe.PetiPanel;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

    /**
     * Message box.
	 * @author Ted
     */
    public class MessageBox extends PetiPanel
    {
		/**
		 * Show a message box with a title, an image logo, and a message.
		 * @param	title - title text or 'Message' if null
		 * @param	items - vg items with log and note if not null
		 * @param	w
		 * @param	h
		 */
        public function MessageBox(title:String,items:*,w:int=400,h:int=380)
        {
            super(w,h,false,true);
            
            addText((title==null)?'Message':title,{'size':20,'color':0xffff00,'bold':true});
            addSeparator();
        
			if (items is Array) {
				for (var i:int=0,itm:Object; itm=items[i]; i++){
					addrow(0, itm);
				}
			}
			else if (items is String) {
				trace('MessageBox, width=', (_width - _margins[LEFT] * 2), _width, w);
				addText(items as String, { align:'center', width: (_width - _margins[LEFT] * 2), wrap:true, html:true }, 'left');
				addSeparator();
			}
			
            var closeBtn:PetiButton = new PetiButton(0, 0, 'Close');
            addControl(closeBtn);
            closeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { close(); } );
			
			drawGradientBackground(0xC3CDDA, 0x16416B);
			
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
			if (typeof(itm.note)!=undefined && itm.note != '') {
				var snote:TextField = createText(itm.note, {'width':_width-140,'align':'left','html':true,'wrap':true});
				right.addControl(snote,'left');
            }
			
			addControls([left, right], 'left');
            addSeparator();
        }

    }
}
