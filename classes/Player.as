package {

	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import flash.events.*;
	import com.coreyoneil.collision.CollisionGroup;
	import flash.geom.*;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class Player extends Sprite {

		var playerShip:AnimatedSprite;
		var playerShipBeamOFF:AnimatedSprite;
		var playerShipBeamON:AnimatedSprite;
		var playerShipLaser:AnimatedSprite;
		var playerShipDisguise:AnimatedSprite;

		var shield:Explosion;

		var laserList:Array=new Array  ;
		var justFired:Boolean=false;

		var deathTimer:Timer;
		var beamTimer:Timer;

		var playerLives:int;
		var muzzle:Boolean=true;

		var LEFT_BOUND:uint=0;
		var TOP_BOUND:uint=0;
		//650, 800 - 610, 763 -> need to figure out how to do this 
		var RIGHT_BOUND:uint;
		var BOTTOM_BOUND:uint;

		//keycodes
		var SHIFT:uint=16;
		var RIGHT:uint=39;
		var LEFT:uint=37;
		var UP:uint=38;
		var DOWN:uint=40;
		var SPACE:uint=32;
		var CTRL:uint=17;

		var rightPressed:Boolean=false;
		var leftPressed:Boolean=false;
		var upPressed:Boolean=false;
		var downPressed:Boolean=false;

		var MAX_SPEED:Number=8;
		var SPEED_MODIFIER:Number=.4;
		var accelerationX:Number=0;
		var accelerationY:Number=0;

		var timePressed:Number=.01;
		var quit:Boolean=false;

		var beam:Beam;
		var beamActive:Boolean=false;
		var beamKill:Boolean=false;

		var holderX:Number;
		var holderY:Number;

		var weaponPermissionLevel:int;
		var currentWeapon:int=0;
		var changeWeaponKeyReady:Boolean=true;
		var fireReady:Boolean=true;
		var truceActive:Boolean = false;

		var beamCharge:Number=BEAM_MAX_LIFE;
		var BEAM_MAX_LIFE:Number=1.2;
		var BEAM_MIN_LIFE:Number=.4;
		var BEAM_USE_RATE:Number=.9;
		var BEAM_RECHARGE_RATE:Number=0.1;

		private var laserSound:Sound=new Sound(new URLRequest("sound/AGO Player Ship Laser.mp3"));
		private var playerHitOne:Sound=new Sound(new URLRequest("sound/AGO Player Ship Hit 1.mp3"));
		private var playerHitTwo:Sound=new Sound(new URLRequest("sound/AGO Player Ship Hit 2.mp3"));
		private var playerHitThree:Sound=new Sound(new URLRequest("sound/AGO Player Ship Hit 3.mp3"));

		public function Player(lives:int, sWidth:int, sHeight:int, wp:int) {
			playerLives=lives;
			RIGHT_BOUND=sWidth-40;
			BOTTOM_BOUND=sHeight-37;
			weaponPermissionLevel=wp;

			playerShipBeamOFF=new AnimatedSprite(40,37,3,1,new player_ship_beamoff(120,37),true,1);
			playerShipBeamON=new AnimatedSprite(40,37,3,1,new player_ship_beamon(120,37),true,1);
			playerShipLaser=new AnimatedSprite(40,37,3,1,new player_ship(120,37),true,1);
			playerShipDisguise=new AnimatedSprite(37,41,2,2,new garbage_ship(74,41),true,1);

			if (weaponPermissionLevel==0) {
				playerShip=playerShipLaser;
			} else if (weaponPermissionLevel == 1) {
				playerShip=playerShipBeamOFF;
			} else if (weaponPermissionLevel == 2) {
				playerShip=playerShipBeamOFF;
			}

			playerShip.x=RIGHT_BOUND/2;
			playerShip.y=BOTTOM_BOUND;
			addChild(playerShip);

			beamTimer=new Timer(300);
			beamTimer.addEventListener(TimerEvent.TIMER, beamRecharge);
			beamTimer.start();

			addEventListener(Event.ENTER_FRAME, updatePlayer);

			deathTimer=new Timer(2000);
			deathTimer.addEventListener(TimerEvent.TIMER, deathExit, false, 0, true);
		}

		private function beamRecharge(e:TimerEvent):void {
			if (beamActive==false&&beamCharge<BEAM_MAX_LIFE) {
				beamCharge+=BEAM_RECHARGE_RATE;
			} else if (beamActive == true && beamCharge>0) {
				beamCharge-=BEAM_USE_RATE;
			}
			if (beamCharge<=0) {
				endBeam();
			}
		}

		private function changeSkin(weaponSet:AnimatedSprite):void {
			holderX=playerShip.x;
			holderY=playerShip.y;
			removeChild(playerShip);
			playerShip=weaponSet;
			playerShip.x=holderX;
			playerShip.y=holderY;
			addChild(playerShip);
		}

		public function removeLife():void {
			if (playerLives>0) {
				playerLives--;
				if (playerLives<=0) {
					endBeam();
					var explode:Explosion=new Explosion("Player",playerShip.x,playerShip.y);
					stage.addChild(explode);
					removeChild(playerShip);
					deathTimer.start();
					muzzle=true;
				} else {
					if (playerLives==3) {
						playerHitOne.play();//not used
					} else if ( playerLives==2 ) {
						playerHitTwo.play();
					} else if ( playerLives==1 ) {
						playerHitThree.play();
					}
					shield=new Explosion("PlayerShield",playerShip.x,playerShip.y);
					stage.addChild(shield);
					addEventListener(Event.ENTER_FRAME, trackPosition);
				}
			}
		}

		private function trackPosition(e:Event):void {
			shield.x=playerShip.x;
			shield.y=playerShip.y;
			if (shield.stopTrack==true) {
				removeEventListener(Event.ENTER_FRAME, trackPosition);
			}
		}

		private function fire():void {
			if (muzzle==false) {
				var laser:Laser=new Laser(playerShip.x,playerShip.y);
				laserList.push(laser);
				justFired=true;
				laserSound.play();
			}
		}

		//this function creates the "boosting" effect, is the deriv. of a LOG equation (which would represent the speed)
		public function accelerate(x:Number):Number {
			return (1/(x * Math.LN10)) + 1;
		}

		public function updatePlayer(e:Event):void {
			if (rightPressed) {
				if (accelerationX<MAX_SPEED) {
					timePressed+=SPEED_MODIFIER;
					accelerationX+=accelerate(timePressed);
				}
			}
			if (leftPressed) {
				if ( accelerationX > (-1*MAX_SPEED) ) {
					timePressed+=SPEED_MODIFIER;
					accelerationX-=accelerate(timePressed);
				}
			}
			if (upPressed) {
				if ( accelerationY > (-1*MAX_SPEED) ) {
					timePressed+=SPEED_MODIFIER;
					accelerationY-=accelerate(timePressed);
				}
			}
			if (downPressed) {
				if (accelerationY<MAX_SPEED) {
					timePressed+=SPEED_MODIFIER;
					accelerationY+=accelerate(timePressed);
				}
			}

			if (playerShip.x>=RIGHT_BOUND) {
				playerShip.x=RIGHT_BOUND;
			}
			if (playerShip.x<=LEFT_BOUND) {
				playerShip.x=LEFT_BOUND;
			}
			if (playerShip.y<=TOP_BOUND) {
				playerShip.y=TOP_BOUND;
			}
			if (playerShip.y>=BOTTOM_BOUND) {
				playerShip.y = BOTTOM_BOUND
				;
			}
			playerShip.x+=accelerationX;
			playerShip.y+=accelerationY;
		}

		private function startBeam():void {
			changeSkin(playerShipBeamON);
			beam=new Beam(playerShip.x,playerShip.y,0);
			beamActive=true;
		}

		private function endBeam():void {
			if (beamActive) {
				if (playerLives>0) {
					changeSkin(playerShipBeamOFF);
				}
				beamActive=false;
				beamKill=true;
				beam.kill();
			}
		}

		public function myKeyDown(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case RIGHT :
					if (beamActive) {
						beam.moveLeft=false;
						beam.moveRight=true;
					} else {
						rightPressed=true;
					}
					break;
				case LEFT :
					if (beamActive) {
						beam.moveRight=false;
						beam.moveLeft=true;
					} else {
						leftPressed=true;
					}
					break;
				case UP :
					if (beamActive) {
					} else {
						upPressed=true;
					}
					break;
				case DOWN :
					if (beamActive) {
					} else {
						downPressed=true;
					}
					break;
				case CTRL :
					if (changeWeaponKeyReady) {
						changeWeaponKeyReady=false;
						currentWeapon++;
						if (currentWeapon>weaponPermissionLevel) {
							currentWeapon=0;
						}
						if (weaponPermissionLevel!=0) {
							if (currentWeapon==2) {
								changeSkin(playerShipDisguise);
							} else {
								changeSkin(playerShipBeamOFF);
							}
						}
					}
					break;
				case SPACE :
					if (! truceActive) {
						if (currentWeapon==0) {
							if (fireReady) {
								fireReady=false;
								fire();
							}
						} else if (currentWeapon==1) {
							if (!beamActive && (playerLives > 0) && (beamCharge>BEAM_MIN_LIFE)) {
								startBeam();
							}
						}
					}
					break;
				case SHIFT :
					exit();
					break;
				default :
					trace("not a valid input: " + e.keyCode.toString());
			}
			e.updateAfterEvent();
		}

		public function myKeyUp(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case RIGHT :
					rightPressed=false;
					timePressed=.01;
					break;
				case LEFT :
					leftPressed=false;
					timePressed=.01;
					break;
				case UP :
					upPressed=false;
					timePressed=.01;
					break;
				case DOWN :
					downPressed=false;
					timePressed=.01;
					break;
				case CTRL :
					changeWeaponKeyReady=true;
					break;
				case SPACE :
					if (weaponPermissionLevel>=1) {
						endBeam();
					}
					fireReady=true;
					break;
				default :
					trace(e.keyCode.toString());
			}
			//e.updateAfterEvent();
		}
		private function deathExit(e:TimerEvent):void {
			quit=true;
		}

		private function exit():void {
			endBeam();
			quit=true;
			removeChild(playerShip);
		}
	}
}