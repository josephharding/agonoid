package
{
	
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import com.coreyoneil.collision.CollisionGroup;
	
	public class EnemyShip extends Sprite
	{
		var LIVES:int = 1;
		var shipSprite:AnimatedSprite;
		var dead:Boolean = false;
		var pointValue:int = 0;
		
		var shootTimer:Timer;
		var teleportTimer:Timer;
		var coolTimer:Timer;
		
		var hostile:Boolean = false;
	
		public function EnemyShip() {
			addEventListener(Event.ENTER_FRAME, attack, false, 0, true);
		}
		
		public function setDead(type:String, shipSprite:AnimatedSprite, explode:Boolean):void {
			dead = true;
			removeEventListener(Event.ENTER_FRAME, attack, false);
			shootTimer.stop();
			shootTimer.removeEventListener(TimerEvent.TIMER, shoot);
			if(explode==true) {
				var theExplosion:Explosion = new Explosion(type, shipSprite.x, shipSprite.y);
				stage.addChild(theExplosion);
			}
			//not sure if the other listeners are actually being removed or not...
		}
		
		public function isDead():Boolean {
            return dead;
        }
		
		public function attack(e:Event):void {
		}
		
		public function teleport(e:TimerEvent):void {
		}
		
		public function readyUp(e:TimerEvent):void {
		}
		
		public function shoot(e:TimerEvent):void {
		}
	}
}