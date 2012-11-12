package com.suinova.pe 
{
	import flash.events.MouseEvent;
	/**
	 * Show a dialog box to confirm by choosing yes or no button.
	 * @author Ted Wen
	 */
	public class ConfirmBox extends PetiPanel
	{
		public static const YESNO:String = 'YN';
		public static const YESNOCANCEL:String = 'YNC';
		
		private var _msg: String;
		
		public function ConfirmBox(msg:String,w:int=200, h:int=20,buttons:String='YN') 
		{
			super(w, h, false, true);
			_msg = msg;
			
			addText(msg);
			addSeparator();
			
			var yesbtn:PetiButton = new PetiButton(0, 0, 'Yes');
			var nobtn:PetiButton = new PetiButton(0, 0, 'No');
			yesbtn.addEventListener(MouseEvent.CLICK, onYes);
			nobtn.addEventListener(MouseEvent.CLICK, onNo);
			var btns = [yesbtn, nobtn];
			if (buttons == YESNOCANCEL) {
				var cancelbtn:PetiButton = new PetiButton(0, 0, 'Cancel');
				cancelbtn.addEventListener(MouseEvent.CLICK, onCancel);
				btns.push(cancelbtn);
			}
			addControls(btns);
		}
		
		private function onYes(e:MouseEvent):void
		{
			dispatchEvent(DialogEvent.YES);
		}
		private function onNo(e:MouseEvent):void
		{
			dispatchEvent(DialogEvent.NO);
		}
		private function onCancel(e:MouseEvent):void
		{
			dispatchEvent(DialogEvent.CANCEL);
		}
	}

}