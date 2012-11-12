package  
{
	import flash.display.Sprite;
	
	/**
	 * SuiLayer class extends the Sprite class to add possible effects.
	 * Each layer is a sprite floating on the page canvas.
	 * 
	 * @author Ted Wen
	 */
	public class SuiLayer extends Sprite
	{
		private var _group:int;
		private var _index:int;
		
		public function SuiLayer() 
		{
			super();
			
		}
		
		public function get group():int
		{
			return this._group;
		}
		
		public function show():void
		{
			trace('>>>TODO: add effect before visible');
			visible = true;
		}
		
		public function hide():void
		{
			trace('>>>TODO: add effect before hide');
			visible = false;
		}
	}

}