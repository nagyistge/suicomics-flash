package com.suinova.pe 
{
	/**
	 * A Stack class to implement stack push/pop operations of any data object
	 * @author Ted Wen
	 */
	public class Stack
	{
		private var firstNode : LinkNode;
		
		public function Stack() 
		{
		}
	
		public function isEmpty(): Boolean
		{
			return this.firstNode == null;
		}
		
		public function push(dataObj: Object): void
		{
			var old: LinkNode = this.firstNode;
			this.firstNode = new LinkNode(dataObj, old);
		}
		
		public function pop(): Object
		{
			if (isEmpty())
				return null;
			var dobj: Object = this.firstNode.data;
			this.firstNode = this.firstNode.next;
			return dobj;
		}
		
		public function seek(): Object
		{
			if (isEmpty())
				return null;
			return this.firstNode.data;
		}
	}

}