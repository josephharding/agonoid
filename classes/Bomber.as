package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class Bomber extends EnemyShip {
		var BULLET_SPEED:int=5;
		var ADVANCE_SPEED:Number=3.5;

		var NODE_ONE:int=360;
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
		var moveLeft:Boolean;

		var killMe:Boolean=false;

		private var fighterBulletSound:Sound=new Sound(new URLRequest("sound/AGO Enemy Fighter Laser.mp3"));

		public function Bomber(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(48,29,1,3,new dragon_bomber(48,29),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			LIVES=1;
			pointValue=110;

			//number of times bomber shoots per strafe, 1
			shootTimer=new Timer(200,1);
			shootTimer.addEventListener(TimerEvent.TIMER, shoot);

			coolTimer=new Timer(4000);
			coolTimer.addEventListener(TimerEvent.TIMER, readyUp);

			addEventListener(Event.ENTER_FRAME, attack);
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
			var flySpeed:int=2;
			var distance:Number=Math.pow(Math.pow(Math.abs(shipSprite.y-playerY),2)+Math.pow(Math.abs(shipSprite.x-playerX),2),.5);

			if (hostile) {
				if (shipSprite.y>playerY) {
					shipSprite.y+=flySpeed*2;
				}

				if (moveLeft==true) {
					shipSprite.x-=flySpeed;
				} else {
					shipSprite.x+=flySpeed;
				}

				if (distance<=700) {
					if (shipSprite.y<10) {
						shipSprite.y+=flySpeed;
					}
					if (! coolTimer.running) {
						shootTimer.start();
					}
					if (shipSprite.x<10) {
						moveLeft=false;
					} else if (shipSprite.x > 640) {
						moveLeft=true;
					}
				} else {
					shipSprite.y+=flySpeed;

					if (shipSprite.x<10) {
						moveLeft=false;
					} else if (shipSprite.x > 640) {
						moveLeft=true;
					}
				}
			} else {
				shipSprite.y+=flySpeed;
			}

			if (shipSprite.y>830) {
				removeEventListener(Event.ENTER_FRAME, attack);
				shootTimer.stop();
				shootTimer.removeEventListener(TimerEvent.TIMER, shoot);
				coolTimer.stop();
				coolTimer.removeEventListener(TimerEvent.TIMER, readyUp);
				killMe=true;
			}
		}

		override public function shoot(e:TimerEvent):void {
			fighterBulletSound.play();
			trace("the bomber shoots");

			var dx:Number=playerX-shipSprite.x;
			var dy:Number=playerY-shipSprite.y;
			angle=Math.atan(dy/dx);
			var bullet:Bullet;

			if (dx<0) {
				angle+=Math.PI;
			}

			bullet = new Bullet(15, 25, 2, 1, new dragon_bomb(30, 25), true, angle, shipSprite.x + 20, shipSprite.y + 20, 
			BULLET_SPEED, parentIndex, "Bomb");
			bulletList.push(bullet);
			justFired=true;
			if (! coolTimer.running) {
				coolTimer.start();
			}
		}
	}
}