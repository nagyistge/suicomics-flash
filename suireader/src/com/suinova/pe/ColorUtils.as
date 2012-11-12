package com.suinova.pe 
{
	/**
	 * ...
	 * @author Ted Wen
	 */
	public class ColorUtils
	{
		
		public function ColorUtils() 
		{
			
		}
		
		/**
		 * Convert a colour number like 0xAARRGGBB into array [R,G,B,A] or [R,G,B] if A is zero.
		 * 
		 * @param	acolor
		 * @return	[R,G,B[,A]]
		 */
		public static function toRGBArray(acolor: uint): Array
		{
			var b: int = acolor & 0xFF;
			var g: int = (acolor >> 8) & 0xFF;
			var r: int = (acolor >> 16) & 0xFF;
			var a: int = (acolor >> 24) & 0xFF;
			if (a > 0)
				return [r, g, b, a];
			return [r, g, b];
		}
		
		/**
		 * Convert a colour number like 0xAARRGGBB into multiples array [RR/255,GG/255,BB/255,AA/255].
		 * If AA == 0, returns A as 1.0
		 * @param	acolor
		 * @param	base [255,255,255,255]
		 * @return
		 */
		public static function toRGBAMultiples(acolor: uint, base: Array = null): Array
		{
			var b: Number = acolor & 0xFF;
			var g: Number = (acolor >> 8) & 0xFF;
			var r: Number = (acolor >> 16) & 0xFF;
			var a: Number = (acolor >> 24) & 0xFF;
			if (base == null)
				base = [255., 255., 255., 255.];
			if (a > 0)
				return [r/base[0], g/base[1], b/base[2], a/base[3]];
			return [r/base[0], g/base[1], b/base[2], 1.0];
		}
		
		/**
		 * Multiply a colour by a number to light up or darken it.
		 * @param	color
		 * @param	multiple
		 * @return
		 */
		public static function multiply(color: uint, multiple: Number): uint
		{
			var b: Number = color & 0xFF;
			var g: Number = (color >> 8) & 0xFF;
			var r: Number = (color >> 16) & 0xFF;
			var bb: int = b * multiple;
			var bg: int = g * multiple;
			var br: int = r * multiple;
			var rc: int = ((br & 0xFF) << 16) | ((bg & 0xFF) << 8) | (bb & 0xFF);
		//	trace('multiple(', color.toString(16), ',', multiple, '=', rc.toString(16),'rgb=',r,g,b,'RGB=',br,bg,bb);
			return rc;
		}
		
		/**
		 * Generate a random colour of RGB.
		 * @return
		 */
		public static function randomColor(): uint
		{
			var b: int = Math.random() * 255;
			var g: int = Math.random() * 255;
			var r: int = Math.random() * 255;
			return (r << 16) | (g << 8) | b;
		}
	}

}