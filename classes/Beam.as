package
{
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.geom.Point;
	import flash.events.*;
	
	public class Beam extends Sprite
	{
		//var pointerSprite:AnimatedSprite;
		var beamShine:AnimatedSprite;
		var moveCheck:Timer;
		
		var moveRight:Boolean = false;
		var moveLeft:Boolean = false;
		var beamActive:Boolean;
		
		var slope:Number;
		
		var originX:Number;
		var originY:Number;
		
		var offsetX:Number;
		var offsetY:Number;
		
		var endX:Number;
		var endY:Number;
		
		var SCREEN_WIDTH:int = 650;
		var SCREEN_HEIGHT:int = 800;
		
		var leftBeam:Sprite;
		var centerBeam:Sprite;
		var rightBeam:Sprite;
		
		var range:int = 50;
		
		public function Beam(x:Number, y:Number, angle:Number) {
			slope = -9999;
			originX = x;
			originY = y;
			endY = 0;
			endX = originX - (originY/slope);
			beamActive = true;
			
			beamShine = new AnimatedSprite(20, 20, 3, 1, new beam_shine(60, 20), true, 1);
			beamShine.x = originX + 10;
			beamShine.y = originY + 10;
			addChild(beamShine);
			
			/*
			pointerSprite = new AnimatedSprite(10, 10, 3, 1, new Drone_bullet_sheet(30, 10), true, 1);
			pointerSprite.x = 100;
			pointerSprite.y = 0;
			addChild(pointerSprite);
			*/
			
			moveCheck=new Timer(1);
			moveCheck.addEventListener(TimerEvent.TIMER, moveTarget);
			moveCheck.start();
			
			leftBeam = new Sprite();
			centerBeam = new Sprite();
			rightBeam = new Sprite();
			
			addChild(leftBeam);
			addChild(centerBeam);
			addChild(rightBeam);
		}
		
		public function kill():void {
			moveCheck.stop();
			moveCheck.removeEventListener(TimerEvent.TIMER, moveTarget);
			//removeChild(pointerSprite);
			beamActive = false;
		}
		
		public function updateOrigin(newX:Number, newY:Number):void {
			originX = newX;
			originY = newY;
			endX = originX - (originY/slope);
			beamShine.x = originX - 10;
			beamShine.y = originY + 10;
		}
		
		private function moveTarget(e:TimerEvent):void {
			if(moveRight) {
				endX += 10;
			} else if(moveLeft) {
				endX -= 10;
			}
			
			slope = (endY - originY)/(endX - originX);
			drawBeam();
		}
		
		private function drawBeam():void {
			/*
			if(endX >= (SCREEN_WIDTH - 10)) {
				pointerSprite.x = (SCREEN_WIDTH - 10)
				pointerSprite.y = originY - (slope * (originX - (SCREEN_WIDTH-10)));
			} else if (endX <= 0) {
				pointerSprite.x = 0
				pointerSprite.y = originY - (slope * originX);
			} else {
				pointerSprite.x = endX;
				pointerSprite.y = endY;
			}
			*/
			
			removeChild(leftBeam);
			removeChild(centerBeam);
			removeChild(rightBeam);
			
			leftBeam = new Sprite();
			centerBeam = new Sprite();
			rightBeam = new Sprite();
			
			leftBeam.graphics.lineStyle(1, 0x35badb);
			centerBeam.graphics.lineStyle(1, 0xbaedf9);
			rightBeam.graphics.lineStyle(1, 0x35badb);
			
			leftBeam.graphics.moveTo(originX-1, originY+20);
			centerBeam.graphics.moveTo(originX, originY+20);
			rightBeam.graphics.moveTo(originX+1, originY+20);
			
			leftBeam.graphics.lineTo(endX-1, endY);
			centerBeam.graphics.lineTo(endX, endY);
			rightBeam.graphics.lineTo(endX+1, endY);
	
			addChild(leftBeam);
			addChild(centerBeam);
			addChild(rightBeam);
		}
	}
}