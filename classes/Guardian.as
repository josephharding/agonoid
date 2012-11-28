package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class Guardian extends EnemyShip {
		var BULLET_SPEED:int=6;
		var ADVANCE_SPEED:Number=3.5;
		var SCREEN_WIDTH:Number=650;

		var NODE_ONE:int=60;
		var NODE_TWO:int=500;
		var NODE_THREE:int=600;
		var NODE_FOUR:int=800;

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

		public function Guardian(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(40,40,3,3,new guardian(120,40),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			LIVES=1;
			pointValue=40;

			//number of times bomber shoots per strafe
			shootTimer=new Timer(200,1);
			shootTimer.addEventListener(TimerEvent.TIMER, shoot);

			coolTimer=new Timer(3000);
			coolTimer.addEventListener(TimerEvent.TIMER, readyUp);
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
			var flySpeed:int=1;
			var distance:Number=Math.pow(Math.pow(Math.abs(shipSprite.y-playerY),2)+Math.pow(Math.abs(shipSprite.x-playerX),2),.5);

			if (hostile) {
				if (shipSprite.y<NODE_ONE) {
					shipSprite.y+=flySpeed;
				} else if ( shipSprite.y >= NODE_ONE && shipSprite.y <= NODE_TWO) {
					shipSprite.y+=flySpeed/3;
					shipSprite.x += 2 * Math.sin((shipSprite.y)/20);
				} else if ( shipSprite.y > NODE_TWO ) {
					shipSprite.y+=flySpeed;
				}

				if (shipSprite.y>=NODE_ONE&&shipSprite.y<=NODE_THREE) {
					if (shipSprite.x>=0&&shipSprite.x<=SCREEN_WIDTH) {
						if (! coolTimer.running) {
							shootTimer.start();
						}
					}
				}

				if (shipSprite.y>playerY) {
					shipSprite.y += (2*flySpeed);
				}
			} else {
				shipSprite.y+=flySpeed;
			}

			if (shipSprite.y>830) {
				killMe=true;
			}
		}

		override public function shoot(e:TimerEvent):void {
			fighterBulletSound.play();
			trace("the defender shoots");

			var dx:Number=playerX-shipSprite.x;
			var dy:Number=playerY-shipSprite.y;
			angle=Math.atan(dy/dx);
			var bullet:Bullet;

			if (dx<0) {
				angle+=Math.PI;
			}

			bullet=new Bullet(10,10,4,1,new torpedo(40,10),true,angle,shipSprite.x+20,shipSprite.y+20,BULLET_SPEED,parentIndex,"Torpedo");
			bulletList.push(bullet);
			justFired=true;
			if (! coolTimer.running) {
				coolTimer.start();
			}
		}
	}
}