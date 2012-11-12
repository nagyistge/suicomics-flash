package
{
    import com.suinova.pe.PetiPanel;
	import com.suinova.pe.PetiButton;
	import com.suinova.pe.PetiCheckbox;
	import com.suinova.pe.DataManager;
    import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.text.TextField;

    /**
     * Exchange virtual goods.
	 * @author Ted
     */
    public class ChangeBox extends PetiPanel
    {
		private var _vgs:Array;
		
        public function ChangeBox(title:String, vgs:Array,w:int=400,h:int=380)
        {
            super(w,h,false,true);
            
            addText((title==null)?'Exchange items':title,{'size':20,'color':0xffff00,'bold':true});
            addSeparator();
        
			_vgs = vgs;
			
            for (var i:int=0,vg:Object; vg=vgs[i]; i++){
                addrow(0, vg.id, vg.name, vg.price, vg.note);
            }
            
            //var buyBtn:PetiButton = new PetiButton(0, 0, 'Buy');
            var closeBtn:PetiButton = new PetiButton(0, 0, 'Close');
            //closeBtn.x = (_width - closeBtn.width) / 2;
            //closeBtn.y = h - 30;
            addChild(closeBtn);
            //addControls([buyBtn,closeBtn]);
            //buyBtn.addEventListener(MouseEvent.CLICK, onBuyItems);
            closeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { close(); } );
			
			drawGradientBackground(0xC3CDDA, 0x16416B);
        }
        
        private function addrow(idx:int, vgid:int, vgname:String, vgprice:Number, vgnote:String):void
        {
            //icon/price/buy_button, name/note slash is line break
			var left:PetiPanel = new PetiPanel(80, 100, false, false, 10, false);
            var ico:Sprite = new Sprite();
			ico.graphics.beginFill(0, 0);
			ico.graphics.drawRect(0, 0, 50, 50);
			ico.graphics.endFill();
            //ico.x = 2;
            //ico.y = idx * _rowheight + _topmargin;
            left.addControl(ico);
            var dm:DataManager = DataManager.instance;
            dm.loadImage('/mm/vg_'+vgid, function(img:Loader):void{
                ico.addChild(img);
            },function(er:Object):void{
                trace(er.error);
            });
            var txt:TextField = createText('Price: '+vgprice.toString(),{'size':10});
            //txt.x = 2;
            //txt.y = ico.y + 50;
			left.addControl(txt);
            var chbx:PetiCheckbox = new PetiCheckbox(70, 10, 'Buy', true);
//			_itemchecks.push(chbx);
            //_itemchecks[idx].x = 2;
            //_itemchecks[idx].y = txt.y + txt.height;
			left.addControl(chbx);
			//left.adjustDimension();
            //name and note
			var right:PetiPanel = new PetiPanel(_width - 110, 100, false, false, 10, false);
            var sname:TextField = createText(vgname, {'bold':true});
            //sname.x = 100;
            //sname.y = ico.y;
            right.addControl(sname,'left');
            var snote:TextField = createText(vgnote, {'width':_width-140,'align':'left','html':true,'wrap':true});
            //snote.x = 100;
            //snote.y = sname.y + sname.height;
            right.addControl(snote,'left');
            //right.adjustDimension();
			
			addControls([left, right], 'left');
            //useHandCursor = true;
            addSeparator();
        }
        
    }
}
