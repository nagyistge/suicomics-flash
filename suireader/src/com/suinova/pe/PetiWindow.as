package com.suinova.pe 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Popup modal or modeless window with an imaged frame, html content, one or two buttons at the bottom and a header at the top.
	 * 
	 * @author Ted
	 */
	public class PetiWindow extends Sprite
	{
		private var _title: String;
		private var _body: String;
		private var _width: int;
		private var _height: int;
		private var _bgcolor: uint = 0xFFBBD60F;
		private var _frame: Array;
		private var _okbtn: PetiButton;
		private var _cancelbtn: PetiButton;
		private var _padding: int = 8;	//8-pixel on all sides of content
		private var _modal_layer: Bitmap;
		
		[Embed(source = '../../../../lib/r9bcv.png')]
		private var Corners: Class;	//top-left:0,top-right:32,bot-left:64,bot-right:96
		
		[Embed(source = '../../../../lib/r9bh.png')]
		private var TopBottom: Class;	//top:0; bot:32, width:28
		
		[Embed(source = '../../../../lib/r9bv.png')]
		private var LeftRight: Class;	//left:0; right:32; height:28
		
		[Embed(source = '../../../../lib/title.png')]
		private var Title: Class;	//width:256; height:30
		
		public function PetiWindow(width:int, height:int, title: String, body: String) 
		{
			super();
			_title = title;
			_width = width;
			_height = height;
			_body = body;
			
			var tf:TextField = new TextField();
			//var tform = new TextFormat();
			//tf.setTextFormat(tform);
			tf.multiline = true;
			tf.wordWrap = true;
			tf.width = width;
			tf.x = 32+_padding;
			tf.y = 32 + _padding;
			tf.selectable = false;
			tf.htmlText = body;
			_height = Math.max(_height, tf.textHeight + 64 + 2 * _padding);
			
			var corners:Bitmap = new Corners();
			var topbot:Bitmap = new TopBottom();
			var leftright:Bitmap = new LeftRight();
			var titlebmp:Bitmap = new Title();
			
			var bmpdata:BitmapData = new BitmapData(_width, _height, true, 0x0000000000);
			
			bmpdata.fillRect(new Rectangle(32, 32, _width - 64, _height - 64), _bgcolor);
			var r:Rectangle = new Rectangle(0, 0, 28, 32);
			var r2:Rectangle = new Rectangle(0, 32, 28, 32);
			for (var x:int = 32; x < _width - 32; x += 28) {
				bmpdata.copyPixels(topbot.bitmapData, r, new Point(x, 0));
				bmpdata.copyPixels(topbot.bitmapData, r2, new Point(x, _height - 32));
			}
			r = new Rectangle(0, 0, 32, 28);
			r2 = new Rectangle(32, 0, 32, 28);
			for (var y:int = 32; y < _height - 32; y += 28) {
				bmpdata.copyPixels(leftright.bitmapData, r, new Point(0, y));
				bmpdata.copyPixels(leftright.bitmapData, r2, new Point(_width - 32, y));
			}
			bmpdata.copyPixels(corners.bitmapData, new Rectangle(0, 0, 32, 32), new Point(0, 0));
			bmpdata.copyPixels(corners.bitmapData, new Rectangle(32, 0, 32, 32), new Point(_width - 32, 0));
			bmpdata.copyPixels(corners.bitmapData, new Rectangle(64, 0, 32, 32), new Point(0, _height - 32));
			bmpdata.copyPixels(corners.bitmapData, new Rectangle(96, 0, 32, 32), new Point(_width - 32, _height - 32));
			bmpdata.copyPixels(titlebmp.bitmapData, new Rectangle(0, 0, 256, 32), new Point((_width - 256) / 2, 0), null, null, true);
			//bmpdata.draw(tf);
			var bmp:Bitmap = new Bitmap(bmpdata);
		/*	
			var modalbmpdata: BitmapData = new BitmapData(760, 740, true, 0x40ff0000);
			modalbmpdata.fillRect(new Rectangle(0, 0, 760, 740), 0x40ff0000);
			_modal_layer = new Bitmap(modalbmpdata);
			addChild(_modal_layer);
		*/	
			addChild(bmp);
			addChild(tf);
			mouseChildren = false;
			//addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void { 
			//	trace(e.localX,e.localY);
			//	} );
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void { trace('added, stage: w=', stage.width,' h=',stage.height);
				//removeEventListener(Event.ADDED_TO_STAGE, this);
				addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { 
					trace(e.target);
					e.target.visible = false;
					dispatchEvent(new Event(Event.CLOSE));
				} );
			} );
		}
		
	}

}