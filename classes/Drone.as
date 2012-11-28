package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class Drone extends EnemyShip {
		var BULLET_SPEED:int=6;
		var ADVANCE_SPEED:Number=3;

		var NODE_ONE:int=200;
		var NODE_TWO:int=400;
		var NODE_THREE:int=500;
		var NODE_FOUR:int=600;

		var initialX:int;
		var bulletList:Array=new Array  ;
		var playerX:Number;
		var playerY:Number;
		var angle:Number;
		var cg_die:CollisionGroup;
		var justFired:Boolean=false;
		var parentIndex:int;
		var randShoot:Number;
		var killMe:Boolean=false;

		private var droneLaserSound:Sound=new Sound(new URLRequest("sound/AGO Enemy Drone Laser.mp3"));

		public function Drone(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(30,23,1,3,new dragon_drone(30,23),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			pointValue=40;

			shootTimer=new Timer(1000,1);
			shootTimer.addEventListener(TimerEvent.TIMER, shoot, false, 0, true);
			
			coolTimer=new Timer(2000);
			coolTimer.addEventListener(TimerEvent.TIMER, readyUp, false, 0, true);
		}
		
		public override function readyUp(e:TimerEvent):void {
			shootTimer.stop();
			shootTimer.reset();
			coolTimer.stop();
			coolTimer.reset();
		}

		public function trackPlayer(px:Number, py:Number, pw:int):void {
			playerX=px;
			playerY=py;
			if (pw!=2) {
				hostile=true;
			}
		}

		override public function attack(e:Event):void {
			/*
			if (dead==true) {
			removeEventListener(Event.ENTER_FRAME, attack);
			shootTimer.stop();
			shootTimer.removeEventListener(TimerEvent.TIMER, shoot);
			}
			*/

			if (hostile) {
				if (shipSprite.y<NODE_ONE) {
					shipSprite.y+=ADVANCE_SPEED;
				} else if ( shipSprite.y >= NODE_ONE && shipSprite.y < NODE_TWO ) {
					shipSprite.y+=ADVANCE_SPEED/4;
					shipSprite.x+=evasive(shipSprite.y);
				} else if ( shipSprite.y >= NODE_TWO && shipSprite.y < NODE_THREE ) {
					shipSprite.y+=ADVANCE_SPEED;
				} else if ( shipSprite.y >= NODE_THREE && shipSprite.y < NODE_FOUR) {
					shipSprite.y+=ADVANCE_SPEED/3;
					shipSprite.x+=evasive(shipSprite.y);
				} else if ( shipSprite.y >= NODE_FOUR && shipSprite.y <= 830) {
					shipSprite.y+=ADVANCE_SPEED;
				}
			} else {
				shipSprite.y+=ADVANCE_SPEED;
			}

			if (shipSprite.y>=NODE_ONE&&shipSprite.y<NODE_FOUR) {
				if (! coolTimer.running) {
					shootTimer.start();
				}
			}
			if (shipSprite.y>830 || shipSprite.x<-10 || shipSprite.x>660) {
				killMe=true;
			}
		}

		private function evasive(posX:Number):Number {
			return Math.cos(posX/20) * 5;
		}

		override public function shoot(e:TimerEvent):void {
			randShoot=Math.random();
			if (randShoot>.6) {
				droneLaserSound.play();
				trace("a drone has shot a bullet");
				var bulletSpeed:int=BULLET_SPEED;
				var dx:Number=playerX-shipSprite.x;
				var dy:Number=playerY-shipSprite.y;
				angle=Math.atan(dy/dx);
				//this -1 accounts for the COS in droneBullet.updateBullet
				if (dx<0) {
					bulletSpeed=bulletSpeed*-1;
				}

				var droneBullet:Bullet=new Bullet(10,10,3,1,new Drone_bullet_sheet(30,10),true,angle,shipSprite.x,shipSprite.y,bulletSpeed,parentIndex,"Bullet");
				bulletList.push(droneBullet);
				justFired=true;
			}
		}
	}
}