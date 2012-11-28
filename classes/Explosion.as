package
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.net.URLRequest;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Explosion extends Sprite
	{
		var explodeSprite:AnimatedSprite;
		var pPosX:int;
		var pPosY:int;
		var stopTrack:Boolean = false;
		var explosionType:String;
		
		private var playerDeath:Sound = new Sound(new URLRequest("sound/AGO Player Ship Death.mp3"));
		private var droneDeathSound:Sound = new Sound(new URLRequest("sound/AGO Enemy Drone Death.mp3"));
		private var fighterDeathSound:Sound = new Sound(new URLRequest("sound/AGO Enemy Fighter Death.mp3"));
		
		public function Explosion(type:String, x:int, y:int) {
			stopTrack = false;
			explosionType = type;
			
			if( type=="Drone" ) {
				droneDeathSound.play();
				explodeSprite = new AnimatedSprite(60, 60, 8, 1, new drone_explosion_sheet(480, 60), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x -  15;
				explodeSprite.y = y - 18;
			}
			
			else if( type=="Fighter" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(114, 114, 10, 2, new fighter_explosion_sheet(570, 228), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 30;
				explodeSprite.y = y - 31;
			}
			
			else if( type=="Bomber" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(60, 48, 10, 2, new bomber_explosion_sheet(570, 228), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 6;
				explodeSprite.y = y - 10;
			}
			
			else if( type=="Defender" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(60, 60, 14, 1, new defender_explosion_sheet(420, 120), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 15;
				explodeSprite.y = y - 16;
			}
			
			else if( type=="Guardian" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(60, 60, 10, 2, new guardian_explosion_sheet(300, 120), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 10;
				explodeSprite.y = y - 10;
			}
			
			else if( type=="GothicGunship" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(160, 160, 12, 2, new gothic_gunship_explosion_sheet(960, 320), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 30;
				explodeSprite.y = y - 30;
			}
			
			else if( type=="GothicFighter" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(60, 60, 8, 2, new gothic_fighter_explosion_sheet(240, 120), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 15;
				explodeSprite.y = y - 16;
			}
			
			else if( type=="GothicPhantom" ) {
				fighterDeathSound.play();
				explodeSprite = new AnimatedSprite(60, 60, 8, 2, new gothic_phantom_explosion_sheet(240, 120), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 5;
				explodeSprite.y = y;
			}
			
			else if( type=="Player" ) {
				playerDeath.play();
				explodeSprite = new AnimatedSprite(256, 256, 8, 2, new player_ship_explosion(2048, 256), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 100;
				explodeSprite.y = y - 100;
			}
			
			else if( type=="Bomb" ) {
				playerDeath.play();
				explodeSprite = new AnimatedSprite(150, 150, 14, 1, new bomb_explosion(1050, 300), false, 2);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 75;
				explodeSprite.y = y - 75;
			}
			
			else if( type=="Torpedo" ) {
				playerDeath.play();
				explodeSprite = new AnimatedSprite(50, 50, 7, 1, new torpedo_explosion(350, 50), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 25;
				explodeSprite.y = y - 25;
			}
			
			else if( type=="Laser" ) {
				playerDeath.play();
				explodeSprite = new AnimatedSprite(20, 20, 5, 1, new laser_explosion(100, 20), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				//offsets for the difference in size between explosion and ship sprite
				explodeSprite.x = x - 10;
				explodeSprite.y = y - 10;
			}
			
			else if( type=="PlayerShield" ) {
				explodeSprite = new AnimatedSprite(40, 40, 5, 2, new player_shield(2048, 256), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
			}
			
			else if( type=="TeleportIn" ) {
				explodeSprite = new AnimatedSprite(40, 40, 7, 2, new phantom_teleport_in(280, 40), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				explodeSprite.x = x+8;
				explodeSprite.y = y+6;
			}
			
			else if( type=="TeleportOut" ) {
				explodeSprite = new AnimatedSprite(40, 40, 7, 2, new phantom_teleport_out(280, 40), false, 1);
				addEventListener(Event.ENTER_FRAME, checkDone);
				addChild(explodeSprite);
				explodeSprite.x = x+10;
				explodeSprite.y = y+6;
			}
		}
		
		private function checkDone(e:Event):void {
			//make sure the shield follows the player, regular explosions doen't need to do this
			if( explosionType=="PlayerShield") {
				explodeSprite.x = pPosX;
				explodeSprite.y = pPosY;
			}
			if( explodeSprite.done == true ) {
				removeChild(explodeSprite);
				removeEventListener(Event.ENTER_FRAME, checkDone);
				stopTrack = true;
			}
		}
	}
}