package {
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import com.coreyoneil.collision.CollisionGroup;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class GothicGunship extends EnemyShip {
		var BULLET_SPEED:int=8;
		var ADVANCE_SPEED:Number=3.5;
		var SCREEN_WIDTH:Number=650;

		var NODE_ONE:int=60;
		var NODE_TWO:int=500;
		var NODE_THREE:int=600;

		var initialX:int;
		var bulletList:Array=new Array  ;
		var gunPos:Array=new Array  ;

		var playerX:Number;
		var playerY:Number;

		var angle:Number;
		var cg_die:CollisionGroup;
		var justFired:Boolean=false;
		var parentIndex:int;
		var moveLeft:Boolean;

		var killMe:Boolean=false;

		private var fighterBulletSound:Sound=new Sound(new URLRequest("sound/AGO Enemy Fighter Laser.mp3"));

		public function GothicGunship(posX:int, posY:int, cg:CollisionGroup, index) {
			shipSprite=new AnimatedSprite(100,100,2,2,new gothic_gunship(200,100),true,1);
			addChild(shipSprite);
			shipSprite.x=posX;
			shipSprite.y=posY;
			initialX=posX;
			cg_die=cg;
			parentIndex=index;
			LIVES=3;
			pointValue=40;

			//number of times bomber shoots per strafe
			shootTimer=new Timer(200,4);
			shootTimer.addEventListener(TimerEvent.TIMER, shoot);

			coolTimer=new Timer(4000);
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
					shipSprite.x += 2 * Math.cos((shipSprite.y)/20);
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
			if (! justFired) {
				fighterBulletSound.play();
				trace("the gunship shoots");
				var denom:Number=1.8;

				gunPos[0]=new Point(shipSprite.x+21,shipSprite.y+77);
				gunPos[1]=new Point(shipSprite.x+31,shipSprite.y+85);
				gunPos[2]=new Point(shipSprite.x+71,shipSprite.y+85);
				gunPos[3]=new Point(shipSprite.x+81,shipSprite.y+77);

				for (var i:uint=0; i<4; i++) {
					angle=Math.PI/denom;
					bulletList.push(new Bullet(4,4,1,1,new gunship_shell(4,4),true,angle,gunPos[i].x,gunPos[i].y,BULLET_SPEED,parentIndex,"Bullet"));
					if (i==2) {
						denom+=.2;
					} else {
						denom+=.1;
					}
				}
				justFired=true;
			}
			if (! coolTimer.running) {
				coolTimer.start();
			}
		}
	}
}