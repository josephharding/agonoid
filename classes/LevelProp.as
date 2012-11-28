package {
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.Timer;
	import flash.events.*;

	public class LevelProp extends Sprite {

		var fileName:String;
		var speed:int;
		var posX:int;
		var repeat:Boolean;
		var waitTime:int;
		var propRotation:Number;
		var dangerous:Boolean;

		var req:URLRequest;
		var loader:Loader = new Loader();
		var myRotator:Rotator;
		var done:Boolean=false;

		var rotComp:int=0;

		var SCREEN_WIDTH:int;
		var SCREEN_HEIGHT:int;
		
		var driftRight:Boolean = true;
		var driftLeft:Boolean = false;
		var driftCounter:int = 0;
		var randNum:Number;
		
		var verticalPlay:Boolean = false;
		var verticalPlayTimer:Timer;

		public function LevelProp(fName:String, s:int, startX:int, r:String, wTime:int, rot:Number, danger:String, sWidth:int, sHeight:int) {
			fileName=fName;
			speed=s;
			posX=startX;
			waitTime=wTime;
			propRotation=rot;

			SCREEN_WIDTH=sWidth;
			SCREEN_HEIGHT=sHeight;

			req=new URLRequest("./images/backgrounds/levelprops/"+fileName);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			loader.load(req);

			if (danger=="false") {
				dangerous=false;
			} else {
				dangerous=true;

			}
			if (r=="false") {
				repeat=false;
			} else {
				repeat=true;
			}
		}

		public function startProp():void {
			addEventListener(Event.ENTER_FRAME, update);
		}

		public function imageLoaded(e:Event):void {
			//loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, imageLoaded);
			if (fileName=="circe/mother.png") {
				loader.y=-600;
				loader.x=posX;
				verticalPlayTimer = new Timer(4000);
				verticalPlayTimer.addEventListener(TimerEvent.TIMER, vertPlay, false, 0, true);
			} else {
				loader.y=-300;
				loader.x=posX;
			}
			addChild(loader);
		}

		public function removeProp():void {
			done=true;
			removeEventListener(Event.ENTER_FRAME, update);
			removeChild(loader);
		}
		
		private function vertPlay(e:TimerEvent):void {
			randNum = Math.random();
			if(randNum > .49) {
				verticalPlay = true;
			} else
				verticalPlay = false;
		}

		public function update(e:Event):void {//this could be spruced up a bit to make the props more exciting
			if (fileName=="circe/mother.png") {
				driftCounter++;
				if(loader.y<=-200) {
					loader.y+=speed;
				} else if (loader.y<=0) {
					loader.y+=speed * (4/5);
				} else if (loader.y<=50) {
					loader.y+=speed * (3/5);
				} else if (loader.y<=100) {
					loader.y+=speed * (1/5);
				}
				
				if(verticalPlay) {
					loader.y+= Math.cos(driftCounter/70);
				}
				if(loader.y>50) {
					loader.x += 2 * Math.sin(driftCounter/30);
					verticalPlayTimer.start();
				}
				
			} else {
				loader.y+=speed;
				myRotator = new Rotator(loader, new Point(loader.x + (loader.width/2),loader.y + (loader.height/2)));
				myRotator.rotation+=propRotation;

				if (loader.x<10) {
					loader.x += (speed/3);
				} else if (loader.x > SCREEN_WIDTH) {
					loader.x -= (speed/3);

				}
				if ( loader.y >= (SCREEN_HEIGHT + 200) && repeat == false) {
					removeProp();
				}
				if (loader.x>=SCREEN_HEIGHT||loader.x<=-200) {
					removeProp();
				}
				if ( loader.y >= (SCREEN_HEIGHT + 200) && repeat == true) {
					loader.y=-200;
				}
			}
		}
	}
}