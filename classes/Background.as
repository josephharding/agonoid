package
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.Sprite;

	public class Background extends Sprite
	{
		var req:URLRequest;
		var loader:Loader = new Loader();
		var loader2:Loader = new Loader();
		var scrollSpeed:Number = 3;
		
		var SCREEN_WIDTH:int;
		var SCREEN_HEIGHT:int;
		
		public function Background(imageString:String, sWidth:int, sHeight:int) {
			req = new URLRequest(imageString);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			loader.load(req);
			loader2.load(req);
			addEventListener(Event.ENTER_FRAME, updateBackground);
			
			SCREEN_WIDTH = sWidth;
			SCREEN_HEIGHT = sHeight;
		}
		
		public function imageLoaded(e:Event):void {
			addChild(loader);
			addChild(loader2);
			loader.y = 0;
			loader2.y = -2045;
		}
		//2048 height, dimensions are a bit weird, not sure this is perfect yet
		public function updateBackground(e:Event):void {
			loader.y += scrollSpeed;
			loader2.y += scrollSpeed;
			if( loader.y >= SCREEN_HEIGHT )
				loader.y = -3290;
			if( loader2.y >= SCREEN_HEIGHT )
				loader2.y = -3290;
		}
	}
}