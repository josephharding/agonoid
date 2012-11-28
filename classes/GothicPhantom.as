package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class GothicPhantom extends EnemyShip {
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
		var stageOne:Boolean;
		var stageTwo:Boolean;

		var killMe:Boolean=false;

		private var fighterBulletSound:Sound=new Sound(new URLRequest("sound/AGO Enemy Fighter Laser.mp3"));

		public function GothicPhantom(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(60,50,3,1,new gothic_phantom(180,50),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			LIVES=1;
			pointValue=40;

			stageOne=false;
			stageTwo=false;

			//number of times bomber shoots per strafe
			shootTimer=new Timer(200,1);
			shootTimer.addEventListener(TimerEvent.TIMER, shoot, false, 0, true);

			coolTimer=new Timer(3000);
			coolTimer.addEventListener(TimerEvent.TIMER, readyUp, false, 0, true);
			
			teleportTimer=new Timer(1000,3);
			teleportTimer.addEventListener(TimerEvent.TIMER, teleport, false, 0, true);
		}

		public override function readyUp(e:TimerEvent):void {
			shootTimer.stop();
			shootTimer.reset();
			coolTimer.stop();
			coolTimer.reset();
			teleportTimer.stop();
			teleportTimer.reset();
		}

		public function trackPlayer(px:Number, py:Number, pw:int):void {
			playerX=px;
			playerY=py;
			if (pw!=2) {
				hostile=true;
			}
		}

		private function randomArea():Point {
			var endPoint:Point = new Point();
			endPoint.y=Math.round(Math.random()*780)+10;
			endPoint.x=Math.round(Math.random()*600)+10;
			return endPoint;
		}

		public override function teleport(e:TimerEvent):void {
			trace("teleporting now commander");
			if (! stageOne) {
				var teleportOut:Explosion=new Explosion("TeleportOut",shipSprite.x,shipSprite.y);
				//this was causing a null reference error, it seems to be connected to the weak reference listener, b/c without it this doesn't work
				//stage.addChild(teleportOut);
				addChild(teleportOut);
				removeChild(shipSprite);
				stageOne=true;
			} else if (! stageTwo&&stageOne) {
				shipSprite.x=randomArea().x;
				shipSprite.y=randomArea().y;
				var teleportIn:Explosion=new Explosion("TeleportIn",shipSprite.x,shipSprite.y);
				addChild(shipSprite);
				addChild(teleportIn);
				stageTwo=true;
			} else if (stageOne&&stageTwo) {
				shootTimer.start();
				stageOne=false;
				stageTwo=false;
			}
		}

		override public function attack(e:Event):void {
			var flySpeed:int=1;
			var distance:Number=Math.pow(Math.pow(Math.abs(shipSprite.y-playerY),2)+Math.pow(Math.abs(shipSprite.x-playerX),2),.5);

			if (hostile) {
				if (shipSprite.y>=30) {
					if (! coolTimer.running) {
						teleportTimer.start();
					}
				} else {
					shipSprite.y+=flySpeed;
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
			trace("the phantom shoots");

			var dx:Number=playerX-shipSprite.x;
			var dy:Number=playerY-shipSprite.y;
			angle=Math.atan(dy/dx);
			var bullet:Bullet;

			if (dx<0) {
				angle+=Math.PI;
			}

			bullet=new Bullet(10,10,1,1,new phantom_bullet(10,10),true,angle,shipSprite.x+20,shipSprite.y+20,BULLET_SPEED,parentIndex,"Bullet");
			bulletList.push(bullet);
			justFired=true;

			if (! coolTimer.running) {
				coolTimer.start();
			}
		}
	}
}