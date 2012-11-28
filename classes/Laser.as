package
{
	import flash.display.Sprite;
	import flash.events.*;
	
	public class Laser extends Sprite
	{
		var laserSprite:AnimatedSprite;
		var dead:Boolean = false;
		
		public function Laser(x:Number, y:Number) {
			laserSprite = new AnimatedSprite(12, 18, 3, 3, new player_proj(12, 18), true, 1);
			laserSprite.x = x + 14;
			laserSprite.y = y - 1;
			addChild(laserSprite);
			addEventListener(Event.ENTER_FRAME, updateLasers);
			dead = false;
		}
		
		public function updateLasers(e:Event):void {
			laserSprite.y -= 25;
		}
		
		public function setDead():void {
			dead = true;
		}
		
		public function isDead():Boolean {
            return dead;
        }
	}
}