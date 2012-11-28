package
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class Bullet extends Sprite
	{
		
		var HOMING_LIFE_LIMIT:uint = 160;
		var BOMB_RADIUS:uint = 60;
		
		var bulletSprite:AnimatedSprite;
		var dead:Boolean = false;
		var angle:Number;
		var bulletSpeed:int;
		var parentIndex:int;
		
		var xInc:Number;
		var yInc:Number;
		
		var isBomb:Boolean;
		var weaponType:String;
		
		var imageType:BitmapData;
		
		var dx:Number;
		var dy:Number;
		var homingCount:uint;
		var myRotator:Rotator;
		
		public function Bullet(w:int, h:int, numF:int, delay:int, image:BitmapData, r:Boolean, ang:Number, posX:int, posY:int, speed:int, 
				index:int, type:String) {
			bulletSprite = new AnimatedSprite(w, h, numF, delay, image, r, 1);
			angle = ang;
			bulletSpeed = speed
			parentIndex = index;
			dead = false;
			addChild(bulletSprite);
			addEventListener(Event.ENTER_FRAME, updateBullet);
			bulletSprite.x = posX;
			bulletSprite.y = posY;
			weaponType = type;
			imageType = image;
			
			xInc = Math.cos(angle) * bulletSpeed;
			yInc = Math.sin(angle) * bulletSpeed;
			
			if(weaponType == "Bomb") {
				rotateBullet();
			}
		}
		
		public function updateAngle(playerX:Number, playerY:Number) {
			if(homingCount > HOMING_LIFE_LIMIT)
				setDead();
			
			dx = playerX - bulletSprite.x;
			dy = playerY - bulletSprite.y;
			angle = Math.atan(dy/dx);
			
			if(dx < 0)
				angle += Math.PI;
				
			xInc = Math.cos(angle) * bulletSpeed;
			yInc = Math.sin(angle) * bulletSpeed;
			
			homingCount++;
		}
		
		public function rotateBullet():void {
			//not totally sure why the angle needs to be anjusted by 90 degrees
			myRotator = new Rotator(bulletSprite, new Point(bulletSprite.x + (bulletSprite.width/2),bulletSprite.y + (bulletSprite.height/2)));
			myRotator.rotation += (360 * (angle/(2*Math.PI))) - 90;
		}
		
		public function updateBullet(e:Event):void {
			bulletSprite.x += xInc;
			bulletSprite.y += yInc;
			
			if ( bulletSprite.y > 800 || bulletSprite.y < -20 || bulletSprite.x < -20  || bulletSprite.x > 700) {
				setDead();
			}
		}
		
		public function setDead():void {
			dead = true;
			removeEventListener(Event.ENTER_FRAME, updateBullet);
		}
		
		public function isDead():Boolean {
            return dead;
        }
	}
}