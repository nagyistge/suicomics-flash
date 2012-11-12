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
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

    /**
     * Donate box.
	 * @author Ted
     */
    public class DonateBox extends PetiPanel
    {
		private var _inputbox:TextField;
		
		/**
		 * Constructor
		 * @param	title - on title line of the window, can be 'Donate!'
		 * @param	vgs - array of items, actually only one line for the items, vgs[0].note is the message, .price is default donation
		 * @param	btn - The buy button label, 'Donate' by default, can be set to others like 'Buy Now'.
		 * @param	w - width is 300 default
		 * @param	h - height is 380 default
		 */
        public function DonateBox(title:String, vgs:Array,btn:String='Donate',w:int=300,h:int=380)
        {
            super(w,h,false,true);
            
            addText((title==null)?'Donate!':title,{'size':20,'color':0xffff00,'bold':true});
            addSeparator();
        
/*			if (vgs != null && vgs.length > 0) {
				var vg:Object = vgs[0];
				_itemid = vg.id;
				addrow(vg.ver, vg.id, vg.name, vg.price, vg.note);
			} else {
				_itemid = 'donated';
				addrow('0', 1, 'Donation', 5, 'Thank you for your donation!');
			}*/
			
			var v:String = '5';
			if (vgs != null && vgs.length > 0 && vgs[0].price) {
				v = new String(vgs[0].price);
				if (vgs[0].note && vgs[0].note.length>0)
					addText(vgs[0].note, { width:w - 8, wrap:true } );
				else
					addText('Amount to donate:');
			} else
				addText('Amount to donate:');
			_inputbox = createText(v, { align:'center', input:true, color:0xff0000 } );
			_inputbox.border = true;
			_inputbox.borderColor = 0;
			_inputbox.background = true;
			_inputbox.backgroundColor = 0xF9F3A8;
			_inputbox.width = 100;
			_inputbox.height = _inputbox.textHeight + 4;
			_inputbox.type = TextFieldType.INPUT;
			addControl(_inputbox);
			addSeparator();
			
            
            var buyBtn:PetiButton = new PetiButton(0, 0, btn);
            var closeBtn:PetiButton = new PetiButton(0, 0, 'Later');
            addControls([buyBtn,closeBtn]);
            buyBtn.addEventListener(MouseEvent.CLICK, onDonate);
            closeBtn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { close(); } );
			
			drawGradientBackground(0xC3CDDA, 0x16416B);
        }
        
        private function addrow(ver:String, vgid:int, vgname:String, vgprice:Number, vgnote:String):void
        {
            //icon/price/buy_button, name/note slash is line break
			var left:PetiPanel = new PetiPanel(80, 100, false, false, 10, false);
			if (vgid > 1) {
				var ico:Sprite = new Sprite();
				ico.graphics.beginFill(0, 0);
				ico.graphics.drawRect(0, 0, 50, 50);
				ico.graphics.endFill();
				left.addControl(ico);
				var dm:DataManager = DataManager.instance;
				dm.loadImage('/mm/vg_'+vgid+'?v='+ver, function(img:Loader):void{
					ico.addChild(img);
				},function(er:Object):void{
					trace(er.error);
				});
			}
            _inputbox = new TextField();
			var tf:TextFormat = new TextFormat('Arial',11,0);
			tf.align = TextFormatAlign.CENTER;
			_inputbox.type = TextFieldType.INPUT;
			_inputbox.defaultTextFormat = tf;
			_inputbox.text = vgprice.toString();
			_inputbox.border = true;
			_inputbox.borderColor = 0;
			_inputbox.background = true;
			_inputbox.backgroundColor = 0xffff00;
			_inputbox.height = _inputbox.textHeight + 4;
			left.addControl(_inputbox);
			//left.adjustDimension();
            //name and note
			var right:PetiPanel = new PetiPanel(_width - 110, 100, false, false, 10, false);
            var sname:TextField = createText(vgname || 'Donate', {'bold':true});
            //sname.x = 100;
            //sname.y = ico.y;
            right.addControl(sname,'left');
            var snote:TextField = createText(vgnote || '', {'width':_width-140,'align':'left','html':true,'wrap':true});
            //snote.x = 100;
            //snote.y = sname.y + sname.height;
            right.addControl(snote,'left');
            //right.adjustDimension();
			
			addControls([left, right], 'left');
            //useHandCursor = true;
            addSeparator();
        }
        
        private function onDonate(e:MouseEvent):void
        {
			var qty:String = _inputbox.text;
            trace('donate', qty);
			try {
				var q:int = parseInt(qty);
				if (q > 0)
					dispatchEvent(new PurchaseEvent(PurchaseEvent.DONATE, qty));
			} catch (e:Error) {
				trace('Not a number');
			}
			close();
        }
    }
}
