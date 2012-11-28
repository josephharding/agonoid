package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class Fighter extends EnemyShip {
		var BULLET_SPEED:int=7;
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

		var killMe:Boolean=false;

		private var fighterBulletSound:Sound=new Sound(new URLRequest("sound/AGO Enemy Fighter Laser.mp3"));

		public function Fighter(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(55,52,1,3,new dragon_fighter(55,52),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			LIVES=1;
			pointValue=200;
			ADVANCE_SPEED = ADVANCE_SPEED + (2 * Math.random());

			//number of times fighter shoots per strafe, 3
			shootTimer=new Timer(200,3);
			shootTimer.addEventListener(TimerEvent.TIMER, shoot, false, 0, true);

			coolTimer=new Timer(3000);
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
			var flySpeed:int=6;
			
			var distance:Number=Math.pow(Math.pow(Math.abs(shipSprite.y-playerY),2)+Math.pow(Math.abs(shipSprite.x-playerX),2),.5);
				var xDistance:Number=Math.abs(playerX-shipSprite.x);
				var yDistance:Number=Math.abs(playerY-shipSprite.y);
				angle=Math.atan(yDistance/xDistance);
			
			if (hostile) {
				
				if(shipSprite.y > playerY)
					shipSprite.y += flySpeed;

				if(distance >= 500) {
					if( playerX - shipSprite.x > 0 ) {
						shipSprite.x +=  Math.cos(angle) * flySpeed;
					} else {
						shipSprite.x -=  Math.cos(angle) * flySpeed;
					}
					if( playerY - shipSprite.y > 0 ) {
						shipSprite.y +=  Math.sin(angle) * flySpeed;
					} else {
						shipSprite.y -=  Math.sin(angle) * flySpeed;
					}
				} else if((shipSprite.y - playerY) < 500) { 
					if(distance <= 10) {
						shipSprite.x += ADVANCE_SPEED/3;
						shipSprite.y -= ADVANCE_SPEED;
					} else if(shipSprite.x <= playerX) {
						shipSprite.y += Math.pow(ADVANCE_SPEED, .5);
						shipSprite.x += ADVANCE_SPEED;
						if(!coolTimer.running)
							shootTimer.start();
					} else if(shipSprite.x > playerX) {
						shipSprite.y += Math.pow(ADVANCE_SPEED, .5);
						shipSprite.x -= (ADVANCE_SPEED);
						if(!coolTimer.running)
							shootTimer.start();
					}
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
			trace("the fighter shoots");

			var dx:Number=playerX-shipSprite.x;
			var dy:Number=playerY-shipSprite.y;
			angle=Math.atan(dy/dx);
			var bullet:Bullet;
			var bulletSpeed:int=BULLET_SPEED;
			if (dx<0) {
				bulletSpeed=bulletSpeed*-1;
			}

			bullet=new Bullet(15,15,2,2,new fighter_bullet_sheet(30,15),true,angle,shipSprite.x+20,shipSprite.y+35,bulletSpeed,parentIndex,"Bullet");
			bulletList.push(bullet);
			justFired=true;
			if (! coolTimer.running) {
				coolTimer.start();
			}
		}
	}
}