package {
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.ui.Keyboard;

	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class MenuScreen extends Sprite {

		var screenWidth:int;
		var screenHeight:int;

		var requestArray:Array=new Array  ;
		var loaderArray:Array=new Array  ;

		var titleLoader:Array=new Array  ;
		var mainLoader:Array=new Array  ;
		var levelLoader:Array=new Array  ;

		var titleImageList:Array=new Array  ;
		var mainImageList:Array=new Array  ;
		var levelImageList:Array=new Array  ;

		var titleImage:Array=new Array  ;
		var menuImage:Array=new Array  ;
		var levelImage:Array=new Array  ;
		var namesArray:Array=new Array  ;

		var SHIFT:uint=16;
		var SPACE:uint=32;
		var UP:uint=38;
		var DOWN:uint=40;
		var RIGHT:uint=39;
		var LEFT:uint=37;

		var PLAY_SELECTED:uint=0;
		var WORLDS_SELECTED:uint=1;
		var CREDITS_SELECTED:uint=2;
		var EXIT_SELECTED:uint=3;

		var buttonSelected:int=0;
		var vertButtonSelected:int=0;
		var horButtonSelected:int=2;

		var mainMenuVisible:Boolean=true;
		var titleMenuVisible:Boolean=true;
		var levelMenuVisible:Boolean=false;

		var currentLevel:Level;
		var theChallenge:Challenge;
		var menuBackground:Background;
		var highScores:TweenScreen;
		var credits:TextBox;
		var creditsTitle:TextBox;
		var platform:Sprite;

		private var mySndCh:SoundChannel;
		private var introMusic:Sound=new Sound(new URLRequest("sound/AGO Music Title Loop.mp3"));
		private var uiSelect:Sound=new Sound(new URLRequest("sound/AGO UI Beep.mp3"));
		private var uiMove:Sound=new Sound(new URLRequest("sound/AGO UI Chime.mp3"));

		public function MenuScreen(sWidth:int, sHeight:int) {
			screenWidth=sWidth;
			screenHeight=sHeight;

			namesArray=["Alchemic Studio","","Chris Barklow","Conor Brace","Melissa Garza","Joey Harding","Chris Martinez","Ruben Rangel"];

			menuBackground=new Background("images/backgrounds/stars.png", screenWidth, screenHeight);
			addChild(menuBackground);

			titleImageList=["images/title/main_title.png"];
			mainImageList = ["images/title/play.png", "images/title/play_selected.png", "images/title/worlds.png", "images/title/worlds_selected.png",
			"images/title/credits.png",  "images/title/credits_selected.png"];
			levelImageList = ["images/title/levelbuttons/troy.png", "images/title/levelbuttons/troy_d.png", "images/title/levelbuttons/cyclops.png", 
			"images/title/levelbuttons/cyclops_d.png",  "images/title/levelbuttons/circe.png", "images/title/levelbuttons/circe_d.png", 
			"images/title/levelbuttons/scylla.png", "images/title/levelbuttons/scylla_d.png", "images/title/levelbuttons/calypso.png", 
			"images/title/levelbuttons/calypso_d.png", "images/title/levelbuttons/home.png", "images/title/levelbuttons/home_d.png"];

			prepareImages(titleImageList, titleLoader);
			titleLoader[titleLoader.length-1].contentLoaderInfo.addEventListener(Event.COMPLETE, loadTitle);

			prepareImages(mainImageList, mainLoader);
			mainLoader[mainLoader.length-1].contentLoaderInfo.addEventListener(Event.COMPLETE, loadMain);

			prepareImages(levelImageList, levelLoader);
			levelLoader[levelLoader.length-1].contentLoaderInfo.addEventListener(Event.COMPLETE, loadLevel);

			playMusic();
		}

		private function makeCredits(theNames:Array):void {
			var textBoxArray:Array=new Array  ;
			platform = new Sprite();
			platform.y=-200;
			for (var i:uint = 0; i < theNames.length; i++) {
				textBoxArray[i]=new TextBox(theNames[i],6);
				platform.addChild(textBoxArray[i]);
				textBoxArray[i].x = (screenWidth/2) - (textBoxArray[i].width/2);
				textBoxArray[i].y=-120+20*i;
			}
			addEventListener(Event.ENTER_FRAME, rollCredits);
		}

		private function rollCredits(e:Event):void {
			if (platform.y<=500) {
				platform.y+=2;
			} else if (platform.y > 500) {
				platform.y+=0;
			}
		}

		private function prepareImages(imageList:Array, loaderArray:Array):void {
			for (var i:int = 0; i < imageList.length; i++) {
				requestArray[i]=new URLRequest(imageList[i]);
				loaderArray[i] = new Loader();
				loaderArray[i].load(requestArray[i]);
			}
		}

		private function drawTitle():void {//high scores tag along with the title "Agonoid"
			titleImage[0].x=(screenWidth/2) - (597/2);
			titleImage[0].y=100;
			addChild(titleImage[0]);
			/*
			highScores=new TweenScreen(7);
			addChild(highScores);
			highScores.x = (screenWidth/2) - 100;
			highScores.y = (screenHeight/2) - 80;
			*/
		}

		private function drawLevels():void {
			var initialY:int=550;
			var initialX:int=(screenWidth/2) - 245;

			var yIncrement=initialY;
			var xIncrement=initialX;

			for (var j:int = 0; j < levelImage.length; j++) {
				for (var i:int = 0; i < levelImage[j].length; i++) {
					levelImage[j][i].x=xIncrement;
					levelImage[j][i].y=yIncrement;
					addChild(levelImage[j][i]);
				}
				xIncrement+=170;
				if (j==2) {
					yIncrement+=100;
					xIncrement=initialX;
				}
			}
			checkHighlight();
		}

		private function drawMain():void {
			var yIncrement=500;

			for (var j:int = 0; j < menuImage.length; j++) {
				for (var i:int = 0; i < menuImage[j].length; i++) {
					menuImage[j][i].x=(screenWidth/2) - 75;
					menuImage[j][i].y=yIncrement;
					addChild(menuImage[j][i]);
				}
				yIncrement+=75;
			}
			updateMenu();
		}

		private function loadTitle(e:Event):void {
			titleImage[0]=titleLoader[0];
			drawTitle();
		}

		private function loadLevel(e:Event):void {
			for (var i:int = 0; i < levelLoader.length; i++) {
				var half:int=i/2;
				if (i%2==0) {
					levelImage[half]=new Array  ;
					levelImage[half][0]=levelLoader[i];
				} else {
					levelImage[half][1]=levelLoader[i];
				}
			}
		}

		private function loadMain(e:Event):void {

			for (var i:int = 0; i < mainLoader.length; i++) {
				var half:int=i/2;
				if (i%2==0) {
					menuImage[half]=new Array  ;
					menuImage[half][0]=mainLoader[i];
				} else {
					menuImage[half][1]=mainLoader[i];
				}
			}
			drawMain();
		}

		private function removeMenu(buttonArray:Array):void {
			if (buttonArray.length==1) {
				removeChild(buttonArray[0]);
			} else {
				for (var j:int = 0; j < buttonArray.length; j++) {
					for (var i:int = 0; i < buttonArray[j].length; i++) {
						removeChild(buttonArray[j][i]);
					}
				}
			}
		}

		public function myKeyDown(e:KeyboardEvent):void {
			if (mainMenuVisible) {
				switch (e.keyCode) {
					case UP :
						if (titleMenuVisible) {
							if (buttonSelected>0) {
								buttonSelected--;
								updateMenu();
							}
						}
						break;
					case DOWN :
						if (titleMenuVisible) {
							if (buttonSelected<2) {
								buttonSelected++;
								updateMenu();
							}
						}
						break;
					case SPACE :
						if (buttonSelected==PLAY_SELECTED) {
							mainMenuVisible=false;
							levelMenuVisible=false;
							titleMenuVisible=false;

							removeMenu(menuImage);
							removeMenu(titleImage);
							loadNewChallenge();

						} else if (buttonSelected==WORLDS_SELECTED) {
							mainMenuVisible=false;
							levelMenuVisible=true;
							titleMenuVisible=false;

							uiSelect.play();
							removeMenu(menuImage);
							drawLevels();

						} else if (buttonSelected==CREDITS_SELECTED) {
							if (titleMenuVisible) {
								mainMenuVisible=true;
								levelMenuVisible=false;
								titleMenuVisible=false;

								uiSelect.play();
								removeMenu(menuImage);
								removeMenu(titleImage);
								//removeChild(highScores);

								makeCredits(namesArray);
								addChild(platform);
							}
						}
						break;
					case SHIFT :
						if (! titleMenuVisible) {
							removeChild(platform);
							removeEventListener(Event.ENTER_FRAME, rollCredits);
							drawMain();
							drawTitle();
							titleMenuVisible=true;
						}

						trace("exit");
						break;
					default :
						trace("not a valid input, " + e.keyCode);
				}
			} else if (levelMenuVisible) {
				switch (e.keyCode) {
					case UP :
						if (vertButtonSelected>0) {
							vertButtonSelected--;
							checkHighlight();
						}
						break;
					case DOWN :
						if (vertButtonSelected<1) {
							vertButtonSelected++;
							checkHighlight();
						}
						break;
					case RIGHT :
						if (horButtonSelected>0) {
							horButtonSelected--;
							checkHighlight();
						}
						break;
					case LEFT :
						if (horButtonSelected<2) {
							horButtonSelected++;
							checkHighlight();
						}
						break;
					case SPACE :
						if (horButtonSelected==2&&vertButtonSelected==0) {
							loadNewLevel(1);
						} else if (horButtonSelected==1 && vertButtonSelected==0) {
							loadNewLevel(2);
						} else if (horButtonSelected==0 && vertButtonSelected==0) {
							loadNewLevel(3);
						} else if (horButtonSelected==2 && vertButtonSelected==1) {
							loadNewLevel(4);
						} else if (horButtonSelected==1 && vertButtonSelected==1) {
							loadNewLevel(5);
						} else if (horButtonSelected==0 && vertButtonSelected==1) {
							loadNewLevel(6);
						}
						break;
					case SHIFT :
						levelMenuVisible=false;
						mainMenuVisible=true;
						titleMenuVisible=true;
						removeMenu(levelImage);
						drawMain();
						break;
					default :
						trace("not a valid input, " + e.keyCode);
				}
			}
		}

		private function loadNewChallenge():void {
			uiSelect.play();
			mySndCh.stop();

			removeChild(menuBackground);
			//removeChild(highScores);

			theChallenge=new Challenge(screenWidth,screenHeight);
			addChild(theChallenge);
			theChallenge.addEventListener(Event.ENTER_FRAME, checkChallengeQuit);
		}

		private function loadNewLevel(levelToLoad:int):void {
			uiSelect.play();
			mySndCh.stop();

			mainMenuVisible=false;
			levelMenuVisible=false;
			removeMenu(levelImage);
			removeMenu(titleImage);
			removeChild(menuBackground);
			//removeChild(highScores);

			currentLevel=new Level(levelToLoad,3,screenWidth,screenHeight);
			addChild(currentLevel);
			currentLevel.addEventListener(Event.ENTER_FRAME, checkLevelQuit);
		}

		private function checkLevelQuit(e:Event):void {
			if (currentLevel.exitLevel==true||currentLevel.victory==true) {
				levelMenuVisible=false;
				mainMenuVisible=true;
				titleMenuVisible=true;
				addChild(menuBackground);
				currentLevel.removeEventListener(Event.ENTER_FRAME, checkLevelQuit);
				removeChild(currentLevel);
				drawTitle();
				drawMain();
				playMusic();
			}
		}

		private function checkChallengeQuit(e:Event):void {
			if (theChallenge.exitChallenge==true) {
				levelMenuVisible=false;
				mainMenuVisible=true;
				titleMenuVisible=true;
				addChild(menuBackground);
				theChallenge.removeEventListener(Event.ENTER_FRAME, checkChallengeQuit);
				removeChild(theChallenge);
				drawTitle();
				drawMain();
				playMusic();
			}
		}

		private function checkHighlight():void {
			for (var j:int = 0; j < levelImage.length; j++) {
				setChildIndex(levelImage[j][0], 2);
			}
			switch (horButtonSelected) {
				case 0 :
					if (vertButtonSelected==0) {
						setChildIndex(levelImage[2][1], 2);
					} else {
						setChildIndex(levelImage[5][1], 2);
					}
					break;
				case 1 :
					if (vertButtonSelected==0) {
						setChildIndex(levelImage[1][1], 2);
					} else {
						setChildIndex(levelImage[4][1], 2);
					}
					break;
				case 2 :
					if (vertButtonSelected==0) {
						setChildIndex(levelImage[0][1], 2);
					} else {
						setChildIndex(levelImage[3][1], 2);
					}
					break;
				default :
					trace("not a valid input");
			}
		}

		private function updateMenu():void {

			for (var j:int = 0; j < menuImage.length; j++) {
				setChildIndex(menuImage[j][0], 2);
				setChildIndex(menuImage[j][1], 1);
			}

			if (buttonSelected==0) {
				setChildIndex(menuImage[0][0], 1);
				setChildIndex(menuImage[0][1], 2);
			} else if (buttonSelected == 1) {
				setChildIndex(menuImage[1][0], 1);
				setChildIndex(menuImage[1][1], 2);
			} else if (buttonSelected == 2) {
				setChildIndex(menuImage[2][0], 1);
				setChildIndex(menuImage[2][1], 2);
			} else if (buttonSelected == 3) {
				setChildIndex(menuImage[3][0], 1);
				setChildIndex(menuImage[3][1], 2);
			}
		}

		private function playMusic():void {
			mySndCh=introMusic.play();
			mySndCh.addEventListener(Event.SOUND_COMPLETE, loopMusic);
		}

		private function loopMusic(e:Event):void {
			if (mySndCh!=null) {
				mySndCh.removeEventListener(Event.SOUND_COMPLETE, loopMusic);
				playMusic();
			}
		}
	}
}