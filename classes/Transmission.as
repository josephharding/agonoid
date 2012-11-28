package {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.text.*;

	public class Transmission extends Sprite {

		var SLIDE_SPEED:int=5;
		var TOP_MAX:int=800-97-10;
		var LEFT_MAX:int=10;
		var RIGHT_MAX:int=LEFT_MAX+359;

		var portraitSprite:AnimatedSprite;
		var leftBorder:AnimatedSprite;
		var rightBorder:AnimatedSprite;
		var backScreen:AnimatedSprite;

		var headerText:TextBox;
		var bodyText:TextBox;

		var animateTimer:Timer;
		var fadeTimer:Timer;
		var textTimer:Timer;
		var transmissionTimer:Timer;

		var startText:Boolean=false;

		var headerRect1:Rectangle;
		var headerRect2:Rectangle;

		var bodyRect:Rectangle;

		var currentPoint:Point;

		var canvasBitmapHeader1:Bitmap;
		var canvasBitmapHeader2:Bitmap;

		var canvasBitmapBody:Bitmap;

		var image:BitmapData;
		var canvasBDHeader:BitmapData;
		var canvasBDHeader1:BitmapData;
		var canvasBDHeader2:BitmapData;

		var canvasBDBody:BitmapData;
		var canvasBDBody1:BitmapData;

		var holder:int=0;
		var testText:TextField;

		var fadeOut:Boolean=false;
		var moveOut:Boolean=false;
		
		var transmissionDone:Boolean = false;
		var transmissionActive:Boolean = false;
		
		var transmissionTimeCounter:Number = 0.0;
		var speakerName:String;

		public function Transmission(avatar:String, header:String, body:String) {
			
			leftBorder=new AnimatedSprite(5,95,1,1,new cl_leftborder(5,95),true,1);
			rightBorder=new AnimatedSprite(5,95,1,1,new cl_rightborder(5,95),true,1);
			backScreen=new AnimatedSprite(354,96,2,1,new cl_backscreen_darker(354,196),true,2);

			if(avatar=="ray") {
				image = new ray(72, 78);
			} else if( avatar=="yuri") {
				image = new yuri(72, 78);
			} else if( avatar=="victor") {
				image = new victor(72, 78);
			} else if( avatar=="computer") {
				image = new computer(72, 78);
			}  else if( avatar=="frank") {
				image = new frank(72, 78);
			}
			
			portraitSprite=new AnimatedSprite(72,78,1,1,image,true,1);
			headerText=new TextBox(header,7);
			bodyText=new TextBox(body,8);

			currentPoint=new Point(0,0);
			headerRect1=new Rectangle(0,0,354,16);
			headerRect2=new Rectangle(-Math.max(headerText.theText.width,headerRect1.width),0,354,16);
			bodyRect=new Rectangle(0,- Math.max(bodyText.theText.height, 79),277,79);

			leftBorder.x=-10;
			leftBorder.y=TOP_MAX;

			rightBorder.x=-5;
			rightBorder.y=TOP_MAX;

			backScreen.alpha=0;
			backScreen.x=LEFT_MAX+5;
			backScreen.y=TOP_MAX;

			portraitSprite.x=LEFT_MAX+11;
			portraitSprite.y=TOP_MAX+16;

			addChild(backScreen);
			addChild(leftBorder);
			addChild(rightBorder);

			canvasBDHeader=new BitmapData(Math.max(headerText.theText.width, headerRect1.width),16,true,0x00000000);
			canvasBDHeader.draw(headerText.theText);
			canvasBDHeader1=new BitmapData(Math.max(headerText.theText.width, headerRect1.width),16,true,0x000000);
			canvasBDHeader2=new BitmapData(Math.max(headerText.theText.width, headerRect1.width),16,true,0x000000);

			canvasBitmapHeader1=new Bitmap(canvasBDHeader1);
			canvasBitmapHeader1.x=LEFT_MAX+10;
			canvasBitmapHeader1.y=TOP_MAX;

			canvasBitmapHeader2=new Bitmap(canvasBDHeader2);
			canvasBitmapHeader2.x=LEFT_MAX+10;
			canvasBitmapHeader2.y=TOP_MAX;

			canvasBDBody=new BitmapData(bodyText.theText.width,Math.max(bodyText.theText.height-1,79),true,0x00000000);
			canvasBDBody.draw(bodyText.theText);
			canvasBDBody1=new BitmapData(bodyText.theText.width,Math.max(bodyText.theText.height-1,79),true,0x00000000);

			canvasBitmapBody=new Bitmap(canvasBDBody1);
			canvasBitmapBody.x=LEFT_MAX+82;
			canvasBitmapBody.y=TOP_MAX+16;

			animateTimer=new Timer(10);
			animateTimer.addEventListener(TimerEvent.TIMER, introAnimation);
			
			transmissionTimer=new Timer(500);
			transmissionTimer.addEventListener(TimerEvent.TIMER, transTimer);
		}
		
		public function beginTransmission(actorName:String):void {
			speakerName = actorName;
			animateTimer.start();
			transmissionTimer.start();
			trace(speakerName + "'s transmission starts");
		}
		
		public function transTimer(e:TimerEvent):void {
			transmissionTimeCounter+= 0.5;
		}

		private function introAnimation(e:TimerEvent):void {
			if (moveOut) {
				if (leftBorder.x>=-15 && rightBorder.x<=LEFT_MAX) {
					leftBorder.x-=SLIDE_SPEED;
				} 
				if (rightBorder.x>=-10) {
					rightBorder.x-=SLIDE_SPEED;
				} else {
					animateTimer.stop();
					animateTimer.removeEventListener(TimerEvent.TIMER, introAnimation);
					transmissionDone = true;
					transmissionTimer.stop();
					trace(speakerName + "'s transmission is done in: " + transmissionTimeCounter);
				}
			} else {
				if (leftBorder.x<=LEFT_MAX) {
					leftBorder.x+=SLIDE_SPEED;
				}
				if (rightBorder.x<=RIGHT_MAX) {
					rightBorder.x+=SLIDE_SPEED;
				} else {
					animateTimer.stop();
					fadeTimer=new Timer(100);
					fadeTimer.addEventListener(TimerEvent.TIMER, fadeScreen);
					fadeTimer.start();
				}
			}
		}

		private function textScroll(e:TimerEvent):void {
			//spent way too much time on this, blanks are OK, just write bigger header strings
			if (headerRect1.x<=headerText.theText.width) {
				headerRect1.x++;
				canvasBDHeader1.copyPixels(canvasBDHeader, headerRect1, currentPoint);
			} else {
				headerRect1.x=-Math.max(headerText.theText.width,headerRect1.width);
			}
			if (headerRect2.x<=headerText.theText.width) {
				headerRect2.x++;
				canvasBDHeader2.copyPixels(canvasBDHeader, headerRect2, currentPoint);
			} else {
				headerRect2.x=-Math.max(headerText.theText.width,headerRect2.width);
			}
			
			if (bodyRect.y<=bodyText.theText.height+20) {
				bodyRect.y+=0.2;
				canvasBDBody1.copyPixels(canvasBDBody, bodyRect, currentPoint);
			} else {
				removeChild(canvasBitmapHeader1);
				removeChild(canvasBitmapHeader2);
				removeChild(canvasBitmapBody);
				removeChild(portraitSprite);
				textTimer.stop();
				textTimer.removeEventListener(TimerEvent.TIMER, textScroll);
				fadeOut=true;
				fadeTimer.start();
			}
		}

		private function fadeScreen(e:TimerEvent):void {
			if (fadeOut) {
				if (backScreen.alpha<=0) {
					fadeTimer.stop();
					moveOut = true;
					animateTimer.start();
					fadeTimer.removeEventListener(TimerEvent.TIMER, fadeScreen);
				} else {
					backScreen.alpha-=0.1;
				}
			} else {
				if (backScreen.alpha>=1) {
					fadeTimer.stop();
					fadeTimer.reset();
					addChild(portraitSprite);
					addChild(canvasBitmapHeader1);
					addChild(canvasBitmapHeader2);
					addChild(canvasBitmapBody);
					textTimer=new Timer(10);
					textTimer.addEventListener(TimerEvent.TIMER, textScroll);
					textTimer.start();
				} else {
					backScreen.alpha+=0.1;
				}
			}
		}
	}
}