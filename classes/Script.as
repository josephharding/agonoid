package {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.text.*;
	import flash.xml.*;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;

	public class Script extends Sprite {

		var myXMLScripts:XML;
		var myLoaderScripts:URLLoader;

		var actor:Array=new Array  ;

		var scriptTimer:Timer;
		var done:Boolean=false;
		var scriptActive:Boolean=false;

		var scriptName:String;
		var transmission:Transmission = null;
		var transmissionPoint:int = -1;
		
		var scriptTimeElapsed:Number = 0.0;

		public function Script(sName:String, levelNum:int) {
			scriptName=sName;

			myLoaderScripts = new URLLoader();
			myLoaderScripts.load(new URLRequest("../agonoid/scripts/level" + levelNum + "scripts.xml"));
			myLoaderScripts.addEventListener(Event.COMPLETE, processXMLScripts);

			scriptTimer=new Timer(1000);
			scriptTimer.addEventListener(TimerEvent.TIMER, action);
		}

		private function processXMLScripts(e:Event):void {
			myXMLScripts=new XML(e.target.data);
			myLoaderScripts.removeEventListener(Event.COMPLETE, processXMLScripts);
		}

		public function beginScript():void {
			loadActors();
		}

		private function loadActors():void {
			for (var i:int = 0; i < myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR.length(); i++) {
				var wayPointArray:Array=new Array  ;
				for (var j:int = 0; j < myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT.length(); j++) {
					if(myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].TRANSMISSION.length()) {
						transmission = new Transmission(
						myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].TRANSMISSION.@AVATAR,
						myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].TRANSMISSION.@HEADER,
						myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].TRANSMISSION.@BODY); 
						transmissionPoint = j;
					} else {
						transmissionPoint = -1;
					}
					wayPointArray[j] = new Waypoint(
					myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].@X,
					myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].@Y,
					myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].@WAIT,
					myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].@ANGLE,
					myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].@MAX_SPEED,
					myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].WAYPOINT[j].@ACCELERATION,
					transmission,
					transmissionPoint);
				}
				actor[i] = new Actor(myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].@NAME, wayPointArray);
				actor[i].x=0;
				actor[i].y=0;
			}
			scriptTimer.start();
		}

		private function action(e:TimerEvent):void {
			scriptTimeElapsed+=.5;
			var allActorsDone:Boolean=true;
			for (var i:int = 0; i < actor.length; i++) {
				//strange bug fix where origin on screen set equal to first x and y assignment, have to wait to addChild until off screen
				if(actor[i].counter==myXMLScripts.SCRIPTED.(@NAME==scriptName).ACTOR[i].@REVEALAT) {
					addChild(actor[i]);
				}
				if(actor[i].ready) {
					trace("Actor " + i + " is done with action " + actor[i].counter);
					trace("Actor " + i + " has " + actor[i].wayPointArray.length + " actions");
				}
				if(actor[i].wayPointArray.length>=actor[i].counter) {
					actor[i].nextAction();
					trace("current script time: " + scriptTimeElapsed);
				}
				if(!actor[i].done) {
					allActorsDone = false;
				} else {
					removeChild(actor[i]);
					actor.splice(i, 1);
					//fix needed to keep from exiting loop too early, not sure if it works 100%
					i--;
				}
			}
			if (allActorsDone) {
				scriptTimer.stop();
				scriptTimer.removeEventListener(TimerEvent.TIMER, action);
				done=true;
				trace("script done");
			}
		}
	}
}