package  
{
	/**
	 * Book data class
	 * 
	 * @author Ted Wen
	 */
	public class Book
	{
		private var _id: String;
		private var _title: String;
		private var _authors: Array;
		private var _pages: Array;	//of Page
		private var _requires: Object;
		private var _rewards: Object;
		private var _cpage: int = 0;
		private var _lastpage: int = 0;
		
		public function Book(bkid:String, page:int=0)
		{
			this._id = bkid;
			this._cpage = this._lastpage = page;
		}
		
		/**
		 * Fill pages from JSON dataset from server.
		 * All requirements and rewards from these pages are collected together.
		 * @param	ds
		 */
		public function setPages(ds: Array):void
		{
			this._pages = new Array();
			this._requires = new Object();
			this._rewards = new Object();
			for (var i:int = 0; i < ds.length; i++) {
				var p:Object = ds[i] as Object;
				var pg:Page = new Page(p);
				this._pages.push(pg);
				for (var rq:String in pg.requires)
					this._requires[rq] = pg.requires[rq];
				for (var rw:String in pg.rewards)
					this._rewards[rw] = pg.rewards[rw];
			}
			trace('pages=', this._pages.length);
		}
		public function get pageCount():int
		{
			return (this._pages==null)?0:this._pages.length;
		}
		public function get pages(): Array
		{
			return this._pages;
		}
		public function set pages(pages: Array): void
		{
			this._pages = pages;
		}
		public function get cpage():int
		{
			return this._cpage;
		}
		public function set cpage(pg:int):void
		{
			this._cpage = pg;
			if (pg > this._lastpage) this._lastpage = pg;
		}
		public function get lastpage():int
		{
			return this._lastpage;
		}
		public function set lastpage(lp:int):void
		{
			this._lastpage = lp;
		}
		public function get id(): String
		{
			return this._id;
		}
		public function set id(bkid: String):void
		{
			this._id = bkid;
		}
		public function get title(): String
		{
			return this._title;
		}
		public function set title(bktitle:String):void
		{
			this._title = bktitle;
		}
		public function get authors(): Array
		{
			return this._authors;
		}
		public function set authors(aus: Array):void
		{
			this._authors = aus;
		}
		public function get requires(): Object
		{
			return this._requires;
		}
		public function set requires(reqs:Object):void
		{
			this._requires = reqs;
		}
		public function get rewards():Object
		{
			return this._rewards;
		}
		public function set rewards(rews:Object):void
		{
			this._rewards = rews;
		}
	}

}