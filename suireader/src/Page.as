package  
{
	/**
	 * Page data set.
	 * [{"id":123,"sn":123.0,"bk":101,"sc":"","ls":[],"rq":{},"rw":{}},..]
	 * @author Ted Wen
	 */
	public class Page
	{
		private const MAP: Object = { 'id':'_id', 'bk':'_book', 'sc':'_script', 'ls':'_layers', 'rq':'_requires', 'rw':'_rewards' };
		private var _id: int;
		private var _book: int;
		private var _script: Object;	//can be AS script evaluable to run, or a piece of predefined template code
		private var _layers: Array;	//[{id:'id1[ id2]', x:0, y:0, rq:'vg1[ vg2]' or '(vg1|vg2)&vg3', ev:'click|over:vg(id.1)|msg(..)|play(..)|do(script)'},
		private var _requires: Object;	//{'item_id':quantity,..}
		private var _rewards: Object;	//{'item_id':{'require_item':qty,..},..}
		
		public function Page(obj: Object) 
		{
			if (obj) {
				for (var k:String in obj) {
					try {
						this[MAP[k]] = obj[k];
					} catch (err:Error) {
						//
					}
				}
			}
		}
		
		public function toString():String
		{
			var buf:Array = [];
			for (var k:String in MAP) {
				buf.push(k + ':' + this[MAP[k]]);
			}
			return '{'+buf.join(',')+'}';
		}
		
		public function get id(): int
		{
			return this._id;
		}
		public function set id(pid:int):void
		{
			this._id = pid;
		}
		public function get book(): int
		{
			return this._book;
		}
		public function set book(bkid:int):void
		{
			this._book = bkid;
		}
		public function get script(): Object
		{
			return this._script;
		}
		public function set script(sc:Object):void
		{
			this._script = sc;
		}
		public function get layers(): Array
		{
			return this._layers;
		}
		public function set layers(ls:Array):void
		{
			this._layers = ls;
		}
		public function get requires(): Object
		{
			return this._requires;
		}
		public function set requires(reqs:Object):void
		{
			this._requires = reqs;
		}
		public function get rewards(): Object
		{
			return this._rewards;
		}
		public function set rewards(rew:Object):void
		{
			this._rewards = rew;
		}
		
	}

}