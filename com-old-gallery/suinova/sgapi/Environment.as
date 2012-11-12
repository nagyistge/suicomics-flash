package com.suinova.sgapi 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.external.ExternalInterface;
	import com.adobe.serialization.json.JSON;
	import flash.net.URLRequest;
	
	/**
	 * Environment is the entry point for games to contact the SNS container via ExternalInterface.
	 * 
	 * @author Ted Wen
	 */
	public class Environment
	{
		private static const _instance:Environment = new Environment();
		//private static const _SuinovaUrl:String = 'http://suinova-comics.appspot.com/api';	//use _env['base']+'/api'

		private var _callbacks:Object = new Object;
		
		private var _env:Object;
		private var _sns:String;
		private var _appid:String;
		private var _uid:String;
		private var _token:String;
		private var _expires:String;
		private var _sig:String;
		
		public function Environment() 
		{
			if (_instance != null)
				throw new Error('Environment is a singleton class, call Environment.instance to get the instance.');
		}

		public static function get instance(): Environment
		{
			return _instance;
		}
		
		private function setenv(env:Object):void
		{
			//_env = JSON.decode(ds, false);
			_env = env;
			if (_env) {
				_sns = _env['sns'];
				_appid = _env['appid'];
				_uid = _env['uid'];
				_token = _env['token'];
				_expires = _env['expires'];
				_sig = _env['sig'];
			}
		}
		
		/**
		 * Callback entry point from JavaScript calling Flash.
		 * The command argument should be saved in _callbacks object with a function assigned. If it is found, its called with the parameter.
		 * @param	cmd : String of method to call back
		 * @param	parms : Object containing additional arguments (key:value pairs)
		 */
		private function onJsCallFlash(cmd:String, parms:Object):void
		{
			trace('onJsCallFlash(', cmd, ',', parms, ')');
			if (_callbacks[cmd]) {
				trace('_callbacks[', cmd, '] is ', _callbacks[cmd]);
				_callbacks[cmd](parms);
			} else {
				trace('onJsCallFlash, command', cmd, 'not found in _callbacks!');
			}
		}
		
		/**
		 * Call external interface method and pass argument and assign a callback function.
		 * @param	cmd
		 * @param	parms
		 * @param	callback
		 * @return
		 */
		public function calljs(cmd:String, parms:Object, callback:Function):Boolean
		{
			if (!ExternalInterface.available)
				return false;
			_callbacks[cmd] = callback;
			return ExternalInterface.call('callFromFlash', cmd, parms);
		}
		
		public function hasExternalInterface():Boolean
		{
			return ExternalInterface.available;
		}
		
		/**
		 * Call external method gethost. should return http://localhost:8082 etc.
		 * @param	callback : call this after getting host or null if failed
		 */
		/*public function getHost(callback:Function):void
		{
			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback('jsCallFlash', onJsCallFlash);
					calljs('gethost', null, callback);
				} catch (err:Error) {
					callback(null);
				}
			} else {
				callback(null);
			}
		}*/

		/**
		 * Call external method getbook. should return http://localhost:8084 etc.
		 * @param	callback : call this after getting book id or null if failed
		 */
		/*public function getBook(callback:Function):void
		{
			if (ExternalInterface.available) {
				try {
					ExternalInterface.addCallback('jsCallFlash', onJsCallFlash);
					calljs('getBook', null, callback);
				} catch (err:Error) {
					callback(null);
				}
			} else {
				callback(null);
			}
		}*/
		
		/**
		 * Call this routine to return the Env associative array via callback argument.
		 * @param	callback
		 */
		public function loadEnv(callback:Function):void
		{
			if (_env == null) {
				if (ExternalInterface.available) {
					try {
						ExternalInterface.addCallback('jsCallFlash', onJsCallFlash);
						calljs('getenv', {app:'suigallery'}, callback);
					} catch (err: Error) {
						trace(err.message);
						//_env = { "uid":"gg_185804764220139124118", "appid":"petigems", "sns":"gg", "token":"gg_185804764220139124118_1285466232.72_64143", "expires":"1285470197", "sig":"ec89ef728408fc9a8d9d2cf5861649c7" };
						_env = { book:'290',page:0,host:'http://localhost:8084',cookie:'' };
						callback(env);
					}
				} else {
					trace('ExternalInterface not available.');
					//tmp = { "sns":"gg", "uid":"FB1234", "token":"ABCDEFG", "expires":"163547", "appid":"1001", "sig":"6297f2e7a43ccac979656ff1147c99a4" };
					_env = { book:'290',page:0,host:'http://localhost:8084',cookie:'' };
					callback(env);
				}
			} else {
				callback(env);
			}
		}
		
		/**
		 * Call JavaScript Suinova.purchase(items) and get back result.
		 * @param	items
		 * @param	callback
		 */
		public function purchase(items:String, callback:Function, qty:int=1):void
		{
			if (ExternalInterface.available) {
				try {
					calljs('purchase', { 'itm':items, 'qty':qty }, callback);
				} catch (err: Error) {
					trace(err);
					callback( { 'error':err.message } );
				}
			} else {
				callback( { 'error':'No external interface' } );
			}
		}
		
		public function get env():Object
		{
			return _env;
		}
		public function get sns():String
		{
			return _sns;
		}
		public function get appid():String
		{
			return _appid;
		}
		public function get uid():String
		{
			return _uid;
		}
		public function get token():String
		{
			return _token;
		}
		public function get expires():String
		{
			return _expires;
		}
		public function get sig():String
		{
			return _sig;
		}
		
		/**
		 * Contact hosting browser to get a user's picture URL such as Facebook profile picture.
		 * @param	uid - Suinova UID string
		 * @param	size - small, big, or medium
		 * @param	callback(DisplayObject)
		 */
		public function loadUserPicture(uid:String, size:String, callback:Function):void
		{
			if (uid.indexOf('_') == 2)
				uid = uid.substr(3);
			if (ExternalInterface.available) {
				calljs('getUserPic', uid, function(url:String):void {
					loadImage(url, callback);
					});
			} else {
				trace('ExternalInterface not available.');
				//for testing just pass uid to Facebook API
				var url:String = 'http://graph.facebook.com/' + uid + '/picture?type=square';
				loadImage(url, callback);
			}
		}
		
		/**
		 * Call external routine to get friends and popup PetiPanel to select one or more friends, and
		 * call callback if available and send friend request to SNS as well.
		 * 
		 * @param	message : message to show friends
		 * @param	serverUrl : URL to the server called when invited friend accepts the invitation.
		 * @param	callback : callback function to pass a list of selected friend IDs back for processing, display, etc.
		 * @param	settings : {key:value} to set dialog box styles
		 */
		public function addFriends(message:String=null, serverUrl:String=null, callback:Function = null, settings:*= null):void
		{
			if (hasExternalInterface()) {
				calljs('inviteFriends', { uid:_uid, url:serverUrl || '', msg:message || 'Come and play Petigems with me!' }, function(p:*):void { } );
			}
		}
		
		/**
		 * Call external routine to get a list of friends.
		 * @param	scope : 1=users, 2=non-users, 3=all
		 * @param	callback : return param is [{id:'uid',name:'display name',pic:'thumbnail picture url'},...]
		 */
		public function getFriends(scope:int, callback:Function):void
		{
			if (hasExternalInterface()) {
				calljs('listFriends', scope, callback);
			}
		}
		/**
		 * Load an image from the given url and return it via the parameter to a the callback function.
		 * callback(img:DisplayObject)
		 * @param	url
		 * @param	callback
		 */
		public function loadImage(url:String, callback:Function):void
		{
			var loader:Loader = new Loader();
			var req:URLRequest = new URLRequest(url)
			loader.load(req);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
					trace('Image loaded for ', uid, 'from', url);
					callback(loader);
				});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
					trace("Error: ", e);
					//throw e;
					callback(null);
				});
		}
		
		/**
		 * Add some news to the scrolling news bar on top of the page.
		 * The added news will be displayed randomly in this session, and will not be persisted on the server.
		 * @param	news
		 */
		public function addNews(news:String):void
		{
			if (hasExternalInterface()) {
				calljs('addnews', news, function(p:*):void { } );
			}
		}
		
		/**
		 * Publish on user's profile or wall.
		 * @param	msg
		 */
		public function publish(msg:String):void
		{
			if (hasExternalInterface()) {
				calljs('publish', { 'msg':msg, 'uid':'me' }, function(p:*):void { } );
			}
		}
	}

}