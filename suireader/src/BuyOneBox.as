package
{
    import com.suinova.pe.PetiPanel;
	import com.suinova.pe.PetiButton;
	import com.suinova.pe.PetiCheckbox;
	import com.suinova.pe.DataManager;
    import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;

    /**
     * Buy one of three box.
	 * @author Ted
     */
    public class BuyOneBox extends PetiPanel
    {
		private var _checkboxes:Array = [];
		private var _vgs:Array;
		
        public function BuyOneBox(title:String, vgs:Array,w:int=400,h:int=380)
        {
            super(w,h,false,true);
            
            addText((title==null)?'Choose one item':title,{'size':20,'color':0xffff00,'bold':true});
            addSeparator();
        trace('drawing items...,this.x,y=', x, y,width,height);
			_vgs = vgs;
			var choices:Array = [];
			var chw:int = w / vgs.length - 5;
            for (var i:int = 0, vg:Object; vg = vgs[i]; i++) {
				var p:PetiPanel = new PetiPanel(chw, 80, false, false, 10, false);
				var sp:Sprite = new Sprite();
				sp.name = String(i);
				sp.graphics.beginFill(0xffffff, 0.6);
				//sp.graphics.lineStyle(1, 0xDBDBDB);
				sp.graphics.drawRect(0, 0, 49, 49);
				sp.graphics.endFill();
				sp.filters = [new DropShadowFilter()];
				sp.addEventListener(MouseEvent.CLICK, onSelectItem);
				var dm:DataManager = DataManager.instance;
				dm.loadImage('/mm/vg_' + vg.id + '?v=' + vg.ver, sp, function(msg:Object):void { trace(msg.error); }, true );
				p.addControl(sp);
				p.addText(vg.name);
				var ck:PetiCheckbox = new PetiCheckbox(chw, 20, vg.price.toString(), (i==0));
				_checkboxes.push(ck);
				ck.addEventListener(MouseEvent.CLICK, onCheckBoxClick);
				p.addControl(ck);
                choices.push(p);
            }
			addControls(choices);
            
            var buyBtn:PetiButton = new PetiButton(0, 0, 'Buy');
            var closeBtn:PetiButton = new PetiButton(0, 0, 'Close');
            addControls([buyBtn,closeBtn]);
            buyBtn.addEventListener(MouseEvent.CLICK, onBuyItems);
            closeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { close(); } );
			
			drawGradientBackground(0xC3CDDA, 0x16416B);
        }
		
		private function onSelectItem(e:MouseEvent):void
		{
			var n:int = parseInt(e.currentTarget.name);
			for (var i:int = 0, c:PetiCheckbox; c = _checkboxes[i] as PetiCheckbox; i++) {
				c.checked = (i == n);
			}
		}
		
        private function onCheckBoxClick(e:MouseEvent):void
		{
			for (var i:int = 0, c:PetiCheckbox; c = _checkboxes[i] as PetiCheckbox; i++) {
				if (c == e.currentTarget) {
					c.checked = true;
				} else {
					c.checked = false;
				}
			}
		}

        private function onBuyItems(e:MouseEvent):void
        {
            var itms:Array = [];
            for (var i:int=0,bb:PetiCheckbox; bb=_checkboxes[i]; i++){
                if(bb.checked)
                    itms.push(_vgs[i].id);
            }
            trace('purchase ', itms);
			dispatchEvent(new PurchaseEvent(PurchaseEvent.PURCHASE, itms.join(' ')));
            //$.post('/market/buy',{},function(resp){});
			close();
        }
    }
}
