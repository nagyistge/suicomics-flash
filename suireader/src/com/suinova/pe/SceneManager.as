package com.suinova.pe 
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	/**
	 * Singleton scene manager to show or hide scene views by state.
	 * 
	 * @author Ted Wen
	 */
	public class SceneManager
	{
		private static const _instance: SceneManager = new SceneManager();
		private var _stage: Stage;
		private var _scenes: Object;
		
		public function SceneManager() 
		{
			if (_instance != null)
				throw new Error("Cannot construct a singleton");
			_scenes = new Object();
		}
		
		public static function get instance(): SceneManager
		{
			return _instance;
		}
		
		/**
		 * Setter to set the Stage instance after ADDED_TO_STAGE event is received.
		 */
		public function set stage(stage_: Stage): void
		{
			_stage = stage_;
		}
		
		public function get scenes(): Object
		{
			return _scenes;
		}
		
		public function addScene(sceneName: String, scene: DisplayObject): void
		{
			_scenes[sceneName] = scene;
		}
		
		public function getScene(sceneName: String): DisplayObject
		{
			for (var s: String in _scenes) {
				if (s == sceneName) {
					return _scenes[s];
				}
			}
			return null;
		}
		
		public function removeScene(sceneName: String): void
		{
			if (_scenes[sceneName] != undefined)
			{
				delete _scenes[sceneName];
			}
		}
		
		/**
		 * Show only the specified DisplayObject by adding it to the Stage and removing all the rest.
		 * @param	sceneName: name of scene
		 * @return 	selected scene
		 */
		public function switchScene(sceneName: String): DisplayObject
		{
			if (_stage == null)
				throw new Error("Stage not set");
			if (_scenes[sceneName] == undefined)
			{
				throw new Error("Scene " + sceneName + " not found");
			}
			var selected: DisplayObject = null;
			TooltipMan.instance.hideTip();
			for (var s: String in _scenes)
			{
				var d: DisplayObject = _scenes[s];
				if (s == sceneName)
				{
					if (!_stage.contains(d))
					{
		//trace('SceneManager.switchScene: addChildAt(', s, ',bottom)');
						_stage.addChildAt(d, 0);	//add to bottom of queue to allow Tooltips
						selected = d;
					}
				}
				else if (_stage.contains(d))
				{
		//trace('SceneManager.switchScene: removeChild(', s, ')');
					_stage.removeChild(d);
				}
			}
			//if (selected) {
				//selected.stage.stageFocusRect = false;
				//selected.stage.tabChildren = false;
				//selected.stage.focus = selected  as InteractiveObject;
			//}
			return selected;
		}
	}

}