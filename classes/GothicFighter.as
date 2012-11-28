package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class GothicFighter extends EnemyShip {
		var BULLET_SPEED:int=8;
		var ADVANCE_SPEED:Number=4;
		var SCREEN_WIDTH:Number=650;

		var NODE_ONE:int=50;
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
		var killMe:Boolean=false;
		
		var parentIndex:int;
		var moveLeft:Boolean;
		
		var tacticleCounter:int;
		var tacticleYMod:Number;
		var tacticleXMod:Number;
		
		private var fighterBulletSound:Sound=new Sound(new URLRequest("sound/AGO Enemy Fighter Laser.mp3"));

		public function GothicFighter(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(30,27,1,1,new gothic_fighter(30,27),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			LIVES=1;
			pointValue=40;
			
			tacticleCounter = 0;
			tacticleYMod = Math.ceil(Math.random()*4) + 1;
			tacticleXMod = Math.ceil(Math.random()*4) + 1;

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
			var flySpeed:int=ADVANCE_SPEED;

			if (hostile) {
				if (shipSprite.y<NODE_ONE) {
					shipSprite.y+=flySpeed;
				} else if ( shipSprite.y >= NODE_ONE && shipSprite.y <= NODE_TWO) {
					tacticleCounter++;
					shipSprite.y += tacticleYMod * Math.sin((tacticleCounter)/20);
					shipSprite.x += tacticleXMod * Math.cos((tacticleCounter)/20);
					shipSprite.y += flySpeed/5;
					if (shipSprite.x>=0&&shipSprite.x<=SCREEN_WIDTH) {
						if (! coolTimer.running) {
							shootTimer.start();
						}
					}
				} else if ( shipSprite.y > NODE_TWO ) {
					shipSprite.y+=flySpeed;
				}
				if (shipSprite.y>playerY) {
					shipSprite.y += (1.5 * flySpeed);
				}
			} else {
				shipSprite.y+=flySpeed;
			}

			if (shipSprite.y>830) {
				killMe=true;
			}
		}

		override public function shoot(e:TimerEvent):void {
			//fighterBulletSound.play();
			trace("the GothicFighter shoots");

			var dx:Number=playerX-shipSprite.x;
			var dy:Number=playerY-shipSprite.y;
			angle=Math.atan(dy/dx);
			var bullet:Bullet;

			if (dx<0) {
				angle+=Math.PI;
			}

			bullet=new Bullet(10,10,1,1,new gothic_fighter_bullet(10,10),true,angle,shipSprite.x+20,shipSprite.y+20,BULLET_SPEED,parentIndex,"Bullet");
			bulletList.push(bullet);
			justFired=true;
			if (! coolTimer.running) {
				coolTimer.start();
			}
		}
	}
}