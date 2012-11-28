package
{
	import flash.display.Sprite;
	import flash.events.*;
	import flash.utils.Timer;
	import flash.net.URLRequest;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	
	public class Challenge extends Sprite
	{
		var screenWidth:int;
		var screenHeight:int;
		
		var score:int = 0;
		var totalScore:int = 0;
		var lives:int = 3;
		var levelCount:uint = 2;
		var currentLevel:Level;
		var exitChallenge:Boolean = false;
		var scoreBox:TextBox;
		var capIn:CaptureInput;
		
		private var mySndCh:SoundChannel; 
		private var gameMusic:Sound = new Sound(new URLRequest("sound/AGO Music Gameplay Loop.mp3"));
		
		public function Challenge(sWidth:int, sHeight:int) {
			screenWidth = sWidth;
			screenHeight = sHeight;
			
			currentLevel = new Level(1, lives, screenWidth, screenHeight);
			addChild(currentLevel);
			scoreBox = new TextBox(score + "", 2);
			addChild(scoreBox);
			addEventListener(Event.ENTER_FRAME, checkQuit);
			playMusic();
		}
		
		private function finalWait(e:Event):void {
			if (capIn.exit == true) {
				exitChallenge = true;
				removeEventListener(Event.ENTER_FRAME, finalWait);
				mySndCh.stop();
			} else
				trace("waiting...");
		}
		
		private function checkQuit(e:Event):void {
			score = totalScore + currentLevel.score;
			removeChild(scoreBox);
			scoreBox = new TextBox(score + "", 2);
			addChild(scoreBox);
			scoreBox.x = 560;
			scoreBox.y = 10;
			
			if(currentLevel.victory == true && levelCount >= 7) {
				totalScore = score;
				capIn = new CaptureInput(totalScore, screenWidth, screenHeight);
				addChild(capIn);
				removeEventListener(Event.ENTER_FRAME, checkQuit);
				addEventListener(Event.ENTER_FRAME, finalWait);
			}
			
			if(currentLevel.exitLevel == true) {
			   exitChallenge = true;
				mySndCh.stop();
			}
			
			if(currentLevel.victory == true && levelCount < 7) {
				lives = currentLevel.thePlayer.playerLives;
				totalScore = score;
				currentLevel.victory = false;
				removeChild(currentLevel);
				currentLevel = new Level(levelCount, lives, screenWidth, screenHeight);
				addChild(currentLevel);
				levelCount++;
			}
		}
		
		private function playMusic():void {     
			mySndCh = gameMusic.play();     
			mySndCh.addEventListener(Event.SOUND_COMPLETE, loopMusic); 
		} 
		
		private function loopMusic(e:Event):void {     
			if (mySndCh != null) {         
				mySndCh.removeEventListener(Event.SOUND_COMPLETE, loopMusic);         
				playMusic();     
			} 
		}
	}
}