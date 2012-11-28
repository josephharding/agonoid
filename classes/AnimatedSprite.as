package {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.utils.Timer;

	public class AnimatedSprite extends Sprite {

		var tileSheet:BitmapData;
		var canvasBD:BitmapData;
		var canvasBitmap:Bitmap;
		var tileWidth:int;
		var tileHeight:int;
		var numFrames:int;
		var animationIndex:int;
		var totalAnimationIndex:int;
		var animationCount:int;
		var animationDelay:int;
		var spriteRect:Rectangle;
		var currentPoint:Point;
		var initX:int;
		var initY:int;
		var numRows:int;
		var repeat:Boolean;
		var gameTimer:Timer;
		var done:Boolean;
		var framesPerRow:int;
		var currentRow:int;

		public function AnimatedSprite(w:int, h:int, numF:int, delay:int, image:BitmapData, r:Boolean, rows:int) {

			tileWidth=w;
			tileHeight=h;
			numFrames=numF;
			animationDelay=delay;
			tileSheet=image;
			repeat=r;
			numRows=rows;
			framesPerRow = (numFrames/numRows);
			currentRow=0;
			done=false;

			totalAnimationIndex=0;
			animationIndex=0;
			animationCount=0;
			initX=0;
			initY=0;

			spriteRect=new Rectangle(0,0,tileWidth,tileHeight);
			currentPoint=new Point(initX,initY);
			
			canvasBD=new BitmapData(tileWidth,tileHeight,true,0x000000);
			canvasBitmap=new Bitmap(canvasBD);

			addChild(canvasBitmap);
			
			if( numFrames > 1) {
				gameTimer=new Timer(30);
				gameTimer.addEventListener(TimerEvent.TIMER, drawSprite);
				gameTimer.start();
			} else
				drawStaticSprite();
		}
		
		private function drawStaticSprite():void {
			spriteRect.x=0;
			spriteRect.y=0;
			canvasBD.copyPixels(tileSheet, spriteRect, currentPoint);
		}

		private function drawSprite(e:TimerEvent):void {

			if (animationCount==animationDelay) {
				animationIndex++;
				totalAnimationIndex++;
				animationCount=0;
				if (animationIndex==framesPerRow) {
					currentRow++;
					animationIndex=0;
				}
				if (totalAnimationIndex==numFrames) {
					if (!repeat) {
						done=true;
					}
					totalAnimationIndex=0;
					currentRow = 0;
				}
			} else {
				animationCount++;
			}
			if (! done) {
				spriteRect.x = int((animationIndex % numFrames))*tileWidth;
				spriteRect.y=tileHeight*currentRow;
				canvasBD.copyPixels(tileSheet, spriteRect, currentPoint);
			}
		}
	}
}