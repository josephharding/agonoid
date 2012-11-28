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

	public class Actor extends Sprite {

		var updateTimer:Timer;

		var wayPointArray:Array=new Array  ;
		var actorName:String;

		var actorSprite:AnimatedSprite;
		var done:Boolean=false;

		var counter:int=0;

		var targetX:int;
		var targetY:int;
		var speed:Number;

		var ready:Boolean=true;
		var waitTime:int;
		var timeElapsed:int = 0;
		
		var distance:Number;
		var originalDistance:Number;
		var maxSpeed:Number;
		
		var actorTrans:Transmission;
		var transHere:Boolean = false;
		
		var myRotator:Rotator;
		var angleDegree:Number = 0;
		
		var rotateDone:Boolean = true;
		var driftCounter:int = 0;

		public function Actor(sName:String, wpArray:Array) {
			wayPointArray=wpArray;
			actorName=sName;

			updateTimer=new Timer(30);
			updateTimer.addEventListener(TimerEvent.TIMER, update);

			if (actorName=="FIGHTER") {
				actorSprite=new AnimatedSprite(55,52,1,3,new dragon_fighter(55,52),true,1);
			} else if (actorName == "GUARDIAN") {
				actorSprite=new AnimatedSprite(40,40,3,2,new guardian(120,40),true,1);
			}  else if (actorName == "DEFENDER") {
				actorSprite=new AnimatedSprite(30,28,1,2,new defender(30,28),true,1);
			}
			
			myRotator = new Rotator(actorSprite, new Point(actorSprite.x + (actorSprite.width/2),actorSprite.y + (actorSprite.height/2)));
			myRotator.rotation = wayPointArray[0].currentAngle;
			addChild(actorSprite);
		}
		
		/*
		private function rotateActor():void {
			myRotator = new Rotator(actorSprite, new Point(actorSprite.x + (actorSprite.width/2),actorSprite.y + (actorSprite.height/2)));
			if(myRotator.rotation != angleDegree) {
				rotateDone = false;
				if(angleDegree>myRotator.rotation) {
					if(Math.abs(angleDegree-myRotator.rotation)<=180)
						myRotator.rotation += 5;
					else
						myRotator.rotation -= 5;
				} else {
					if(Math.abs(myRotator.rotation-angleDegree)<=180)
						myRotator.rotation -= 5;
					else
						myRotator.rotation += 5;
				}
			} else
				rotateDone = true;
			
			trace(actorName + " rotation: " + myRotator.rotation);
			trace(actorName + " x: " + actorSprite.x);
			trace(actorName + " y: " + actorSprite.y);
		}
		*/

		private function update(e:TimerEvent):void {
			driftCounter++;
			if (Math.abs(actorSprite.x-targetX)<=2&&Math.abs(actorSprite.y-targetY)<=2) {
				//slowly weave as you wait
				//actorSprite.x += 2 * Math.sin(driftCounter/6000);
				if (timeElapsed>=waitTime) {
					ready=true;
					//trace("Arrived at: (" + targetX + ", " +targetY + ")");
					//trace("Actor location: (" + actorSprite.x + ", " + actorSprite.y + ")");
				}
			} else {
				var dx:Number=targetX-actorSprite.x;
				var dy:Number=targetY-actorSprite.y;
				var angle:Number=Math.atan(dy/dx);

				if (dx<0) {
					angle+=Math.PI;
				}
				
				distance = Math.pow((dx*dx) + (dy*dy), 0.5);
				speed = Math.max(maxSpeed * Math.sin((distance * Math.PI)/(originalDistance )), 1);
				
				var xInc:Number=Math.cos(angle)*speed;
				var yInc:Number=Math.sin(angle)*speed;

				actorSprite.x+=xInc;
				actorSprite.y+=yInc;
			}
			//rotateActor();
		}

		public function nextAction():void {
			timeElapsed++;
			//trace(actorName + " has counter " + counter);
			if (ready && rotateDone && counter==wayPointArray.length ) {
				if(!transHere) {
					done=true;
					//trace(actorName + " took the first option");
				} else if(actorTrans.transmissionDone) {
					done=true;
					//trace(actorName + " took the second option");
				}
			}
			else if (ready && rotateDone) {
				if (counter==0) {
					updateTimer.start();
				}
				if(wayPointArray[counter].transmissionPoint>-1) {
					actorTrans = wayPointArray[counter].transmission;
					addChild(actorTrans);
					actorTrans.beginTransmission(actorName);
					transHere = true;
					//gets removed when the actor is removed
				}
				targetX=wayPointArray[counter].xPos;
				targetY=wayPointArray[counter].yPos;
				angleDegree = wayPointArray[counter].currentAngle;
				originalDistance = Math.pow((Math.pow((targetX-actorSprite.x), 2) + Math.pow((targetY-actorSprite.y), 2)), 0.5);
				speed=wayPointArray[counter].maxSpeed;
				maxSpeed = speed;
				waitTime=wayPointArray[counter].waitTime;
				timeElapsed = 0;
				
				counter++;
				ready=false;
			}
		}
	}
}