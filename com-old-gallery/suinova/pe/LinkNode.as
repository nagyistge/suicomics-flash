package com.suinova.pe 
{
	/**
	 * Node class for linked list data structure classes such as Stack.
	 * @author Ted Wen
	 */
	public class LinkNode
	{
		private var dataObj : Object;
		private var nextNode : LinkNode;
		
		public function LinkNode(dataObj: Object, nextNode: LinkNode = null)
		{
			this.dataObj = dataObj;
			this.nextNode = nextNode;
		}
		
		public function get data(): Object
		{
			return this.dataObj;
		}
		
		public function set data(data: Object): void
		{
			this.dataObj = data;
		}
		
		public function get next(): LinkNode
		{
			return this.nextNode;
		}
		
		public function set next(node: LinkNode): void
		{
			this.nextNode = node;
		}
	}

}