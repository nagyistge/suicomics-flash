package  
{
	/**
	 * Script Engine exception class
	 * @author Ted Wen
	 */
	public class ScriptEngineError extends Error
	{
		
		public function ScriptEngineError(message:String, errorID:int=401) 
		{
			super(message, errorID);
		}
		
	}

}