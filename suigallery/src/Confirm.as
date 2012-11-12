package
{
	import com.suinova.pe.PetiButton;
	import com.suinova.pe.PetiPanel;
	import flash.display.Stage;
	import flash.events.MouseEvent;

	/**
	 * Confirm is like JavaScript confirm prompt to display a coupld of buttons and click to close and callback with the button name.
	 */
    public class Confirm extends PetiPanel
    {
        private var _prompt:String;
        private var _buttons:Array;
        private var _callback:Function;
        
        public function Confirm(w:int, h:int, msg:String, btns:Array, cb:Function)
        {
            super(w, h, false, true);
            this._prompt = msg;
            this._callback = cb;
            
            addText(msg,{width:180,size:14,bold:true,html:true,wrap:true});
            _buttons = new Array();
            for (var i:int=0; i<btns.length; i++){
                var btn:PetiButton = new PetiButton(0,0,btns[i]);
                _buttons.push(btn);
                btn.name = btns[i];
                btn.addEventListener(MouseEvent.CLICK, onButtonClick);
            }
			//addSeparator();
            addControls(_buttons);
			
			drawGradientBackground(0xC3CDDA, 0x16416B);
        }
        
        private function onButtonClick(e:MouseEvent):void
        {
            var btn:PetiButton = e.currentTarget as PetiButton;
            //trace(btn.name,'clicked');
            _callback(btn.name);
            close();
        }
    
        public static function show(stage:Stage, prompt:String, buttons:Array, callback:Function):void
        {
            var cb:Confirm = new Confirm(200,100,prompt,buttons,callback);
            stage.addChild(cb);
            //cb.x = (stage.width - cb.width) / 2;
            //cb.y = (Math.min(stage.stageHeight,stage.height) - cb.height) / 2;
        }
    }
}
