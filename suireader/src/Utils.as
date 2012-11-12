package  
{
	import flash.filters.BevelFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	/**
	 * Some static utility routines.
	 * @author Ted Wen
	 */
	public class Utils
	{
		
		public function Utils() 
		{
			
		}
		
		/**
		 * Parse color string in the format of '#FFFF00' into an int.
		 * @param	cs : color string as #RRGGBB
		 * @return : int of 0xRRGGBB
		 */
		public static function parseColor(cs:String):int
		{
			var i:int = 0;
			if (cs.charAt(0) == '#') i++;
			return parseInt(cs.substr(i), 16);
		}

		/**
		 * Format filters into AS3 filter objects.
		 * Supported filters:
		 * 	BevelFilter, DropShadowFilter, GlowFilter
		 * 	Keywords: Bevel, Shadow, Glow
		 * 	Parameters: in the order of their constructors
		 * 	{"Bevel":{"distance":4,"angle":45,"highlightColor":"#FFFFFF","highlightAlpha":1,"shadowColor":"#000000","shadowAlpha":1,"blurX":4,"blurY":4,"strength":1,"quality":1}}
		 * 	{"Shadow":{"distance":4.0,"angle":45,"color":"#000000","alpha":1,"blurX":4,"blurY":4,"strength":1,"quality":1}}
		 * 	{"Glow":{"color":"#FF0000","alpha":1.0,"blurX":6,"blurY":6,"strength":2,"quality":1}}
		 * @param	filters - [{"Bevel":{},..]
		 * @return [GlowFilter(), ...]
		 */
		public static function formatFilters(filters:Array):Array
		{
			trace('>>>TODO: change filters GlowFilter, BevelFilter');
			var flts:Array = new Array();
			for (var i:int = 0, fo:Object; fo = filters[i]; i++) {
			for (var f:String in fo) {
				if (f == 'Bevel') {
					var bf:BevelFilter = new BevelFilter();
					for (var fp:String in fo[f]) {
						bf[fp] = (fp=='color')? Utils.parseColor(fo[f][fp]):fo[f][fp];
					}
					flts.push(bf);
				}
				else if (f == 'Shadow') {
					var sf:DropShadowFilter = new DropShadowFilter();
					for (fp in fo[f]) {
						sf[fp] = (fp=='color')? Utils.parseColor(fo[f][fp]):fo[f][fp];
					}
					flts.push(sf);
				}
				else if (f == 'Glow') {
					var gf:GlowFilter = new GlowFilter();
					for (fp in fo[f]) {
						gf[fp] = (fp=='color')? Utils.parseColor(fo[f][fp]):fo[f][fp];
					}
					flts.push(gf);
				}
			}
			}
			return flts;
		}
		
	}

}