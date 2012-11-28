package
{	

	import flash.xml.*;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.KeyboardEvent;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.Timer;
	import com.coreyoneil.collision.CollisionGroup;

	public class Agonoid extends Sprite
	{
		public function Agonoid() {
			
			/*
			var testLevel:Level = new Level(4, 4, this.stage.stageWidth, this.stage.stageHeight);
			addChild(testLevel);
			*/
			
			var theMenu:MenuScreen = new MenuScreen(this.stage.stageWidth, this.stage.stageHeight);
			addChild(theMenu);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, theMenu.myKeyDown);
		}
	}
}

