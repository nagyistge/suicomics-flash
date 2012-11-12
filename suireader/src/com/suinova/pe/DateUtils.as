package com.suinova.pe 
{
	/**
	 * Utility class to handle Date string conversion using UTC and ISO format.
	 * 
	 * @author Ted Wen
	 */
	public class DateUtils
	{
		
		public function DateUtils() 
		{
			
		}
		
		/**
		 * Parse a date string in ISO format 'YYYY-MM-DDTHH:mm:SS' to Date object.
		 * The date is assumed to be in UTC time (GMT-0000 timezone).
		 * 
		 * @param	ds
		 * @return
		 */
		public static function parseDate(ds: String): Date
		{
	//trace('Enter DateUtils.parseDate(', ds, ')');
			//ds format: '2010-01-01 02:10:01'
			//AS3 parse format: YYYY/MM/DD HH:MM:SS TZD (TZD: UTC-0000)
			if (ds.indexOf('T') == 10)
				ds = ds.replace('T', ' ');
			var newds: String = ds.replace(/-/g, "/") + ' UTC-0000';	//always UTC time GMT-0000
	//trace('ds converted to ', newds);
			var dn: Number = Date.parse(newds);
	//trace('then to number: ', dn);
			return new Date(dn);
		}
		
		/**
		 * Create a random Date of a date time within a year, it can be now or 365 days ago.
		 * @return Date object
		 */
		public static function randomDate(): Date
		{
			var now:Number = new Date().time;
			now -= Math.random() * (365 * 24 * 3600);
			var nd:Date = new Date(now);
			return nd;
		}
		
	}

}