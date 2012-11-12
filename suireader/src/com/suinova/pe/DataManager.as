package com.suinova.pe 
{
	import com.adobe.crypto.MD5;
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * Singleton data manager to load data models and send back updates to server.
	 * 
	 * @author Ted Wen
	 */
	public class DataManager
	{
		private static const _instance: DataManager = new DataManager();
		private var _baseurl: String = 'http://suinova-comics.appspot.com';
		private var _env: Object = { };
		private var _sigkey: String = null;
		private var _models: Object;
		
		public function DataManager() 
		{
			if (_instance != null)
				throw new Error("Cannot construct a singleton");
			_models = new Object();
		}
		
		public static function get instance(): DataManager
		{
			return _instance;
		}
		
		public function get baseurl(): String
		{
			return _baseurl;
		}
		public function get env(): Object
		{
			return _env;
		}
		
		public function setBaseURL(url:String): void
		{
			if (url == null || url == '') return;
			_baseurl = url;
			if (_baseurl.substr(_baseurl.length - 1) == '/')
				_baseurl = _baseurl.substr(0, _baseurl.length - 1);
		}
		//public function get sigkey(): String
		//{
			//return _sigkey;
		//}
		public function setEnv(env: Object):void
		{
			_env = env;
		}
		public function setSignatureKey(skey:String):void
		{
			_sigkey = skey;
		}
		public function get models(): Object
		{
			return _models;
		}
		
		public function addEntity(dname: String, ent: Object): void
		{
			_models[dname] = ent;
		}
		
		public function removeEntity(dname: String): void
		{
			if (_models[dname] != undefined)
				delete _models[dname];
		}
		
		public function getEntity(dname: String): Object
		{
			if (_models[dname] != undefined) {
				//trace('DataManager.getEntity(', dname, ') return ok');
				return _models[dname];
			} else {
				trace('DataManager.getEntity(', dname, ') not found, create new Player');
				//return new Player(); //TODO: throw new Error('Data entity not found');
				return null;
			}
		}
		
		private function setRequestData(params:Object, request:URLRequest):void
		{
			var hasData: Boolean = false;
			var vars: URLVariables = new URLVariables();
			if (params != null)
				for (var k: String in params){
					vars[k] = params[k];
					hasData = true;
				}
			if (_env != null)
				for (k in _env){
					vars[k] = _env[k];
					hasData = true;
				}
			if (hasData)
				request.data = vars;
		}
		
		/**
		 * Static method to call the server through URLLoader and return result to the callback functions.
		 * The params argument can be null or {key:value,...}. onError function is optional.
		 * 
		 * @param	url - if not starting with http[s]:// then _baseurl is prepended to it.
		 * @param	params
		 * @param	callback with parameter: {'ev': Event.COMPLETE or ProgressEvent.PROGRESS, 'data': loader.data or ProgressEvent}
		 * @param	onError
		 */
		public function post(url: String, params: Object, callback: Function, onError: Function=null): void
		{
			var request: URLRequest = new URLRequest();
			if (_baseurl && url.indexOf('://') < 0) {
				if (url.indexOf('/') != 0) url = '/' + url;
				request.url = _baseurl + url;
			}else
				request.url = url;
			request.method = URLRequestMethod.POST;
			setRequestData(params, request);

			//trace('DataManager.post(', request.url, ',', request.data.toString(), ')');
			var loader: URLLoader = new URLLoader();
		//trace('Adding event handlers...');
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(ev: IOErrorEvent):void {
					trace('DataManager.post('+url+'): IO_Error from URLLoader:', ev);
					if (onError != null) onError(ev.toString());
				});
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void {
					//trace('HTTPStatus event:', e);
					if (e.status != 200) {
						trace('DataManager.post('+url+'): HTTP_STATUS ',e.toString());
						//if (onError != null) onError(e.toString());
					}
				});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
					trace('DataManager.post('+url+'): Security_error: ', e);
					if (onError != null) onError(e.toString());
				});
			loader.addEventListener(Event.COMPLETE, function(e: Event): void { 
		trace('DataManager.post('+url+'): loader complete, data=',loader.data);
					try {
						//var dataobj: Object = JSON.decode(loader.data as String) as Object;
						var decoder:JSONDecoder = new JSONDecoder(loader.data,false);
						var dataobj: Object = (decoder.getValue() as Object);
						callback(Event.COMPLETE, dataobj );
					} catch (err:Error) {
						trace('DataManager.post('+url+'): JSON.decode error:',err.message);
						if (onError != null) onError('JSON.decode failed:' + err.message+',Original:'+loader.data);
					}
				});
			loader.addEventListener(ProgressEvent.PROGRESS, function(e: ProgressEvent): void {
				callback(ProgressEvent.PROGRESS, e);
			});
			try {
				loader.load(request);
			}catch (er: Error) {
				trace('DataManager.post('+url+'): Unable to load');
				if (onError != null)
					onError(er.message);
			}
		}
		
		/**
		 * Load an image or SWF from server, and replace child of canvas sprite if successful. If the returned data
		 * is JSON text starting with '{', then errfunc function is called with the object as argument.
		 * @param	url - URL to server
		 * @param	dataOut - Function or Sprite on which the loaded image is placed as child
		 * @param	errfunc - Function to be called if server returned JSON text instead of image
		 */
		public function loadImage(url: String, dataOut: *, errfunc: Function, center:Boolean=false): void
		{
			if (_baseurl && url.indexOf('://') < 0) {
				if (url.indexOf('/') != 0) url = '/' + url;
				url = _baseurl + url;
			}
		//	var xparam:Object = { };
		//	var n:int = url.lastIndexOf('?v=');
		//	if (n > 0) {
		//		xparams['v'] = url.substr(n + 3);
		//		url = url.substring(0, n);
		//	}
			var request:URLRequest = new URLRequest(url);
		//trace(url);
		//	setRequestData(xparam, request);
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				if (loader.data[0] == 123) {
					try {
						var eo:Object = JSON.decode(loader.data.toString()) as Object;
						if(typeof(errfunc)!=undefined) errfunc(eo);
					} catch (er:Error) {
						trace('DataManager.loadImage('+url+') JSON.decode error:', er, 'date:', loader.data);
					}
					return;
				} else {
					var ldr:Loader = new Loader();
					ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
						if (typeof(dataOut) == 'function') {
							(dataOut as Function)(ldr); 
						} else {
							var sp:Sprite = dataOut as Sprite;
							sp.addChild(ldr);
							if (center){
								ldr.x = (sp.width - ldr.width) / 2;
								ldr.y = (sp.height - ldr.height) / 2;
							}
						}
						} );
					ldr.loadBytes(loader.data);
					//dataFunc(ldr);
				}
				//while (canvas.numChildren > 0) canvas.removeChildAt(0);
				//canvas.addChild(ldr);
				//if (ldr.width < width)
				//	ldr.x = (width - ldr.width) / 2;
				/*
				var myBitmap:BitmapData = new BitmapData(ldr.width, ldr.height, false);
				var mtx: Matrix = new Matrix();
				myBitmap.draw(ldr, mtx);
				canvas.graphics.clear();
				canvas.graphics.beginBitmapFill(myBitmap, mtx, true);
				width = Math.min(Math.max(width, ldr.width), 720);
				height = Math.max(height, ldr.height);
				canvas.graphics.drawRect(0, 0, width, height);
				canvas.graphics.endFill();*/
				});
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
				trace('DataManager.loadImage('+url+') IO_Error: ', e);
				
				});
		}
		
		/**
		 * Base class function to be shared by all data classes.
		 * @param	url - URL of the server to send data command to
		 * @param	params - {key:value} pairs as associative array
		 */
		public function post0(url: String, params: Array = null): void
		{
			var request: URLRequest = new URLRequest();
			request.url = url;
			request.method = URLRequestMethod.POST;
			if (params != null) {
				var variables:URLVariables = new URLVariables();
				for (var k: String in params) {
					variables[k] = params[k];
				}
				request.data = variables;
			}
			var loader: URLLoader = new URLLoader();
			//loader.dataFormat = URLLoaderDataFormat.VARIABLES; //use default .TEXT
			loader.addEventListener(Event.COMPLETE, function(e: Event): void {
				var result:Array = JSON.decode(loader.data);
				parseResult(result);
			});
			try {
				loader.load(request);
			} catch (error:Error) {
				trace('Unable to load URL');
			}
		}
		
		/**
		 * Parse the JSON dataset returned from the server into current object property values.
		 * @param	json - {"key":"value",...}
		 */
		protected function parseResult(json: Array): void
		{
			if (json['RE'] && json['RE'] == 'OK')
			{
				for (var k:String in json)
				{
					var prop: String = '_' + k;
					if (this[prop]) {
						this[prop] = json[k];
					} else {
						trace('not found property: ', k);
					}
				}
			} else {
				trace('Error: ', json);
			}
		}
	
		/**
		 * Generate a MD5 hex-string for a list of key:value pairs in params sorted by key=value string.
		 * {'a':12,'b':'aa'} ==> 'a=12b=aa' ==> 
		 * @param	params
		 * @return
		 */
		public function md5(params: Object): String
		{
			var buf:Array = new Array();
			for (var k:String in params) {
				var v:String = params[k];
				var s:String = k + '=' + v;
				buf.push(s);
			}
			buf.sort();
			s = buf.join('');
			if (_sigkey != null) s += _sigkey;
	//trace('md5:', s);
			return MD5.hash(s);
		}
	}

}