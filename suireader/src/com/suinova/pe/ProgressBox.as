package com.suinova.pe 
{
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class ProgressBox
	{
		private var _width: int = 300;
		private var _height: int = 200;
		private var _stage: Stage;
		private var _bytesRead: Number;
		private var _totalBytes: Number;
		private var _window: PetiPanel;
		private var _pbar: Shape;
		
		public function ProgressBox(width:int,height:int,title:String,stage:Stage,params:Object=null) 
		{
			_width = width;
			_height = height;
			_stage = stage;
			_window = new PetiPanel(_width, _height);
			_window.x = (stage.width - _width) / 2;
			_window.y = (stage.height - _height) / 2;
			_window.addText(title, { 'bold':true } );
			_pbar = new Shape();
			_pbar.width = _width / 2;
			_pbar.height = 20;
			_window.addControl(_pbar);
			
			_stage.addChild(_window);
		}
		
		public function setProgress(bytesRead:Number, total:Number):void
		{
			_bytesRead = bytesRead;
			if (total > 0 && total != _totalBytes)
				_totalBytes = total;
			else if (_totalBytes <= 0)
				_totalBytes = _bytesRead + _bytesRead + 1;
			update();
		}
		
		private function update(): void
		{
			//update graphics
			var g:Graphics = _pbar.graphics;
			g.clear();
			g.beginFill(0xdddd88, 0.5);
			g.lineStyle(1, 0);
			g.drawRect(0, 0, _pbar.width - 1, _pbar.height - 1);
			var pw:int = _pbar.width * (_bytesRead / _totalBytes);
			g.endFill();
			g.beginFill(0xffff00);
			g.drawRect(0, 0, pw, _pbar.height - 1);
			g.endFill();
		}
		
		public function close():void
		{
	trace('About to close ProgressBox');
			_stage.removeChild(_window);
	trace('ProgressBox closed');
		}
	}

}