package com.suinova.pe 
{
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class Queue
	{
		private var headNode: LinkNode;
		private var tailNode: LinkNode;
		
		public function Queue() 
		{
		}
		
		public function isEmpty(): Boolean
		{
			return this.headNode == null;
		}
		
		public function enqueue(dataObj: Object): void
		{
			if (isEmpty())
			{
				this.headNode = this.tailNode = new LinkNode(dataObj);
			}
			else
			{
				this.tailNode.next = new LinkNode(dataObj);
				this.tailNode = this.tailNode.next;
			}
		}
		
		public function dequeue(): Object
		{
			if (isEmpty())
				return null;
			var headData: Object = this.headNode.data;
			this.headNode = this.headNode.next;
			return headData;
		}
		
		public function peekHead(): Object
		{
			if (isEmpty()) return null;
			return this.headNode.data;
		}
		
		public function peekTail(): Object
		{
			if (isEmpty()) return null;
			return this.tailNode.data;
		}
	}

}