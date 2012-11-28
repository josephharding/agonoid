package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	import flash.events.*;
	import flash.xml.*;
	import com.coreyoneil.collision.CollisionGroup;

	public class Level extends Sprite {
		var myXML:XML;
		var theBackground:Background;
		var truceFlag:AnimatedSprite;
		var tweenScreen:TweenScreen;
		var thePlayer:Player;
		var beamNotAdded:Boolean=true;
		var playerLives:int;
		var levelNumber:int;
		var enemies:Array=new Array  ;
		var playerLaserList:Array=new Array  ;
		var propArray:Array=new Array  ;
		var transmissionsArray:Array=new Array  ;
		var scriptArray:Array=new Array  ;

		var cg_score:CollisionGroup = new CollisionGroup();//includes player laser, enemy ships
		var cg_die:CollisionGroup = new CollisionGroup();//includes enemy laser, player ship
		var scoreCollisions:Array;
		var dieCollisions:Array;

		var victoryTimer:Timer;
		var spawnTimer:Timer;
		var fadeTimer:Timer;
		var invulTimer:Timer;
		var gameCheck:Timer;
		var propTimer:Timer;
		//var checkGameEasy:Timer;

		var time:int=0;
		var nextSquad:Boolean=true;
		var gameActive:Boolean=false;
		var squadCount:int=0;
		var waitTime:int;

		var exitLevel:Boolean=false;
		var possibleEarlyQuit:Boolean=true;
		var victory:Boolean=false;
		var bigNum:int=2;
		var waitNum:int=300;
		var score:int=0;
		var propTimeCounter:int=0;

		//add in the lives counter image
		var loader:Array=new Array  ;
		var req:URLRequest;
		var loopExit:Boolean=false;
		var allEnemiesDead:Boolean;

		var freezeSpawn:Boolean=false;
		var freezeSpawnScript:Boolean=false;

		var SCREEN_WIDTH:int;
		var SCREEN_HEIGHT:int;

		var currentWeaponString:String=" ";
		var weaponDisplayActive:Boolean=false;
		var weaponDisplay:TextBox;

		var currentLivesString:String=" ";
		var livesDisplayActive:Boolean=false;
		var livesDisplay:TextBox;

		var hostileOverride:Boolean=false;
		var currentTransmission:int=0;
		var currentScript:int=0;
		var transmitting:Boolean=false;
		var scriptRunning:Boolean=false;
		var truce:Boolean=false;
		
		var winTick:int = 0;

		public function Level(levelNum:int, pLives:int, sWidth:int, sHeight:int) {
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(new URLRequest("../agonoid/levels/level" + levelNum + ".xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);

			playerLives=pLives;
			levelNumber=levelNum;
			SCREEN_WIDTH=sWidth;
			SCREEN_HEIGHT=sHeight;
		}

		private function processXML(e:Event):void {
			myXML=new XML(e.target.data);
			initialize();
		}

		private function fadeController(e:TimerEvent):void {
			bigNum=bigNum+20;
			if (bigNum>waitNum) {
				tweenScreen.alpha = 1 - ((bigNum-waitNum)/100);
			}
			if (bigNum>waitNum+100) {
				fadeTimer.removeEventListener(TimerEvent.TIMER, fadeController);
				removeChild(tweenScreen);
				beginLevel();
			}
		}

		private function beginLevel():void {
			addChildAt(theBackground, 0);
			gameActive=true;
			spawnTimer.start();
			thePlayer.muzzle=false;
			possibleEarlyQuit=false;
			if (myXML.PROP.length()>0) {
				initializeProps();
			}
			if (myXML.TRANSMISSION.length()>0) {
				initializeTrans();
			}
			if (myXML.SCRIPT.length()>0) {
				initializeScripts();
			}
			addChild(thePlayer);
		}

		private function initializeProps():void {
			propTimer=new Timer(1000);
			propTimer.addEventListener(TimerEvent.TIMER, propController);
			propTimer.start();
			addEventListener(Event.ENTER_FRAME, propChecker);
		}

		private function initializeTrans():void {
			for (var k:int = 0; k < myXML.TRANSMISSION.length(); k++) {
				transmissionsArray[k] = new Transmission(myXML.TRANSMISSION[k].@AVATAR, 
				myXML.TRANSMISSION[k].@HEADER, (myXML.TRANSMISSION[k].@BODY + " "));
			}
		}

		private function initializeScripts():void {
			for (var k:int = 0; k < myXML.SCRIPT.length(); k++) {
				scriptArray[k]=new Script(myXML.SCRIPT[k].@NAME,levelNumber);
			}
		}

		private function propChecker(e:Event):void {
			for (var i:int = 0; i < propArray.length; i++) {
				if (propArray[i].done==true) {
					//trace("at: " + i + ", removing " + propArray[i].fileName + " length: " +  propArray.length);
					removeLevelProp(propArray[i]);
					i--;
					//trace("at: " + i + ", length now: " +  propArray.length);
				}
			}
		}

		private function propController(e:TimerEvent):void {
			propTimeCounter++;
			for (var i:uint = 0; i < myXML.PROP.length(); i++) {
				if (myXML.PROP[i].@WAIT==propTimeCounter) {
					propArray.push(new LevelProp(myXML.PROP[i].@NAME, myXML.PROP[i].@SPEED, myXML.PROP[i].@STARTX, 
					myXML.PROP[i].@REPEAT, myXML.PROP[i].@WAIT, myXML.PROP[i].@ROTATION, myXML.PROP[i].@DANGEROUS, 
					SCREEN_WIDTH, SCREEN_HEIGHT));
					addChildAt(propArray[propArray.length-1], 1);
					propArray[propArray.length-1].startProp();
					//trace("a prop has spawned");
					if (propArray[propArray.length-1].dangerous) {
						cg_die.addItem(propArray[propArray.length-1]);
						cg_score.addItem(propArray[propArray.length-1]);
					}
				}
			}
		}

		private function initialize():void {
			tweenScreen=new TweenScreen(levelNumber);
			addChild(tweenScreen);

			// was 250, changed to 25 for debug
			fadeTimer=new Timer(25);
			fadeTimer.addEventListener(TimerEvent.TIMER, fadeController);
			fadeTimer.start();

			invulTimer=new Timer(2000);
			invulTimer.addEventListener(TimerEvent.TIMER, invulEnd);

			theBackground=new Background("./images/backgrounds/"+myXML.BACKGROUND[0],SCREEN_WIDTH,SCREEN_HEIGHT);
			truceFlag=new AnimatedSprite(20,20,1,3,new truce_flag(20,20),true,1);

			spawnTimer=new Timer(1000);
			spawnTimer.addEventListener(TimerEvent.TIMER, spawnSquads, false, 0, true);
			
			victoryTimer=new Timer(1000, 3);
			victoryTimer.addEventListener(TimerEvent.TIMER, victoryWin, false, 0, true);

			thePlayer=new Player(playerLives,SCREEN_WIDTH,SCREEN_HEIGHT,2);
			cg_die.addItem(thePlayer);
			cg_score.addItem(thePlayer);

			stage.addEventListener(KeyboardEvent.KEY_DOWN, thePlayer.myKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, thePlayer.myKeyUp);
			addEventListener(Event.ENTER_FRAME, checkGame, false, 0, true);
			addEventListener(Event.ENTER_FRAME, checkLasers, false, 0, true);

			//checkGameEasy=new Timer(500);
			//checkGameEasy.addEventListener(TimerEvent.TIMER, checkGame);
			//checkGameEasy.start();

			//gameCheck=new Timer(2000);
			//gameCheck.addEventListener(TimerEvent.TIMER, gameCheckTimer);
			//gameCheck.start();

			//beginLevel();
		}

		private function gameCheckTimer(e:TimerEvent):void {
			for each (var i:int in enemies) {
				trace("Number of enemies in squad " + i + ": " + enemies[i].enemyList.length + ", " + enemies[i].masterBulletList.length);
			}
			trace("Number cg_score objects: " + cg_score.numChildren);
			trace("Number cg_die objects: " + cg_die.numChildren);
			trace("Number of lasers: " + thePlayer.laserList.length);
		}

		private function beginTransmission(k:int):void {
			transmissionsArray[k].beginTransmission("non script");
			addChild(transmissionsArray[k]);
			transmissionsArray[k].transmissionActive=true;
		}

		private function beginScript(k:int):void {
			scriptArray[k].beginScript();
			addChild(scriptArray[k]);
			scriptArray[k].scriptActive=true;
		}

		/*
		private function checkScriptTransmission(e:Event):void {
		for(var i:int = 0; i < scriptArray.length; i++) {
		if(scriptArray.actor[j].wayPointArray[counter].waitTime
		}
		}
		*/

		private function spawnSquads(e:TimerEvent):void {
			var allClear:Boolean=true;
			for(var h:uint = 0; h < squadCount; h++) {;
			if (! enemies[h].wipedOut) {
				allClear=false;
			}
		}

		if (myXML.SCRIPT.length()>0) {
			for (var j:int = 0; j < myXML.SCRIPT.length(); j++) {
				if (scriptArray[currentScript].done) {
					scriptRunning=false;
				}
				if ((myXML.SCRIPT[j].@SQUAD==squadCount) && (scriptArray[j].done==false) && !scriptRunning) {
					if (freezeSpawnScript==false) {
						freezeSpawnScript=true;
					}
					if (allClear && (!scriptArray[j].scriptActive)) {
						currentScript=j;
						beginScript(currentScript);
						scriptRunning = true;
						truce=true;
					}
				}
				if ((scriptArray[j].done==true) && (freezeSpawnScript==true)  && !scriptRunning) {
					freezeSpawnScript=false;
					truce=false;
				}
			}
		}

		//transmissions come before a specified squad, that squad will not spawn until after the transmission is complete
		//transmissions don't begin until allClear is true

		if (myXML.TRANSMISSION.length()>0) {
			if ((!transmitting) && (freezeSpawn==true)) {
				freezeSpawn=false;
			}
			for (var k:int = 0; k < myXML.TRANSMISSION.length(); k++) {
				if (transmissionsArray[currentTransmission].transmissionDone) {
					transmitting=false;
				}
				if ((myXML.TRANSMISSION[k].@SQUAD==squadCount) && (transmissionsArray[k].transmissionDone==false) && !transmitting) {
					if (freezeSpawn==false) {
						freezeSpawn=true;
					}
					if (allClear && (!transmissionsArray[k].transmissionActive)) {
						currentTransmission=k;
						beginTransmission(currentTransmission);
						transmitting=true;
					}
				}
			}
		}

		//wait times can be + or -, if + then after spawn of previous squad timer starts
		//if - then after death of entire previous squad timer starts

		if (squadCount<myXML.SQUAD.length()) {
			waitTime=myXML.SQUAD[squadCount].@WAIT;
		}

		if ((nextSquad==true) && (freezeSpawn==false) && (freezeSpawnScript==false)) {
			if ((waitTime >= 0) && (time >= waitTime) && squadCount<myXML.SQUAD.length()) {
				trace("Spawning: " + myXML.SQUAD[squadCount].@TITLE);
				enemies[squadCount]=new EnemySquad(myXML.SQUAD[squadCount].@TITLE,myXML.SQUAD[squadCount].@NUMBER,
				myXML.SQUAD[squadCount].@STARTX,cg_score,cg_die,squadCount, hostileOverride);
				addChildAt(enemies[squadCount], 2);
				time=0;
				nextSquad=false;
				squadCount++;
			} else if ((waitTime < 0) && (waitTime >= (time * -1)) && squadCount<myXML.SQUAD.length()) {
				trace("Spawning: " + myXML.SQUAD[squadCount].@TITLE);
				enemies[squadCount]=new EnemySquad(myXML.SQUAD[squadCount].@TITLE,myXML.SQUAD[squadCount].@NUMBER,
				myXML.SQUAD[squadCount].@STARTX,cg_score,cg_die,squadCount, hostileOverride);
				addChildAt(enemies[squadCount], 2);
				time=0;
				nextSquad=false;
				squadCount++;
			} else {
				time++;
			}
			if (squadCount<myXML.SQUAD.length()) {
				waitTime=myXML.SQUAD[squadCount].@WAIT;
			}
		}

		if ( (waitTime < 0 && (enemies[squadCount-1].wipedOut)) || waitTime >= 0) {
			nextSquad=true;
		}

		if (squadCount>=myXML.SQUAD.length()) {
			allEnemiesDead=true;
			for (var i:uint = 0; i < enemies.length; i++) {
				if (enemies[i].wipedOut==false)
					allEnemiesDead=false;
				if (enemies[i].masterBulletList.length != 0)
					allEnemiesDead=false;
			}
			if (allEnemiesDead==true) {
				spawnTimer.stop();
				spawnTimer.removeEventListener(TimerEvent.TIMER, spawnSquads, false);
				victoryTimer.start();
				trace("victory, three seconds");
			}
		}
	}

	private function victoryWin(e:TimerEvent):void {
		winTick++;
		trace(winTick);
		if(winTick>=3) {
			victoryTimer.stop();
			victoryTimer.removeEventListener(TimerEvent.TIMER, victoryWin, false);
			quit(true);
		}
	}

	private function removeLaser(laser:Laser, explode:Boolean):void {
		if (explode) {
			var theExplosion:Explosion=new Explosion("Laser",laser.laserSprite.x,laser.laserSprite.y);
			stage.addChild(theExplosion);
		}
		cg_score.removeItem(laser);
		laser.setDead();
		removeChild(laser);

		for (var i:int = 0; i < playerLaserList.length; i++) {
			if (playerLaserList[i].isDead()==true) {
				playerLaserList.splice(i, 1);
			}
		}
	}

	private function removeLevelProp(prop:LevelProp):void {
		if (prop.dangerous) {
			cg_score.removeItem(prop);
			cg_die.removeItem(prop);
		}
		removeChild(prop);

		for (var i:int = 0; i < propArray.length; i++) {
			if (propArray[i].done==true) {
				//trace("at: " + i + ", removing " + propArray[i].fileName + " length: " +  propArray.length);
				propArray.splice(i, 1);
			}
		}
	}

	private function removeScript(scr:Script):void {
		if (scr.scriptActive) {
			removeChild(scr);
		}
		for (var i:int = 0; i < scriptArray.length; i++) {
			if (scriptArray[i].done==true) {
				scriptArray.splice(i, 1);
			}
		}
	}

	private function removeTransmission(trans:Transmission):void {
		if (trans.transmissionActive) {
			removeChild(trans);
		}
		for (var i:int = 0; i < transmissionsArray.length; i++) {
			if (transmissionsArray[i].transmissionDone==true) {
				transmissionsArray.splice(i, 1);
			}
		}
	}

	private function checkLasers(e:Event):void {
		//add player lasers to list
		if (thePlayer.justFired==true) {
			addChild(thePlayer.laserList[thePlayer.laserList.length-1]);
			playerLaserList.push(thePlayer.laserList[thePlayer.laserList.length-1]);
			cg_score.addItem(playerLaserList[playerLaserList.length-1]);
			thePlayer.justFired=false;
			thePlayer.laserList.pop();
		}

		for (var t:uint = 0; t < playerLaserList.length; t++) {
			if (playerLaserList[t].laserSprite.y<0) {
				removeLaser(playerLaserList[t], false);
			}
		}

		//player beam weapon logic
		if (thePlayer.beamActive&&beamNotAdded) {
			addChild(thePlayer.beam);
			beamNotAdded=false;
		}

		if (thePlayer.beamActive) {
			thePlayer.beam.updateOrigin(thePlayer.playerShip.x + (thePlayer.playerShip.width/2), thePlayer.playerShip.y);
		}

		if (thePlayer.beamKill) {
			removeChild(thePlayer.beam);
			thePlayer.beamKill=false;
			beamNotAdded=true;
		}
	}

	private function quit(win:Boolean):void {
		if (possibleEarlyQuit==false) {

			for (var r:uint = 0; r < enemies.length; r++) {//remove enemies
				for (var s:uint = 0; s < enemies[r].enemyList.length; s++) {
					enemies[r].removeEnemy(enemies[r].enemyList[s], false);
					s--;//this took forever to figure out, at 11:39pm :)
				}
				enemies[r].removeEventListener(Event.ENTER_FRAME, enemies[r].checkChildren);
				removeChild(enemies[r]);
			}

			if (myXML.PROP.length()>0) {//remove level props
				propTimer.stop();
				propTimer.removeEventListener(TimerEvent.TIMER, propController);
				removeEventListener(Event.ENTER_FRAME, propChecker);
				for (var p:uint = 0; p < propArray.length; p++) {
					trace("at: " + p + ", removing " + propArray[p].fileName + " length: " +  propArray.length);
					removeLevelProp(propArray[p]);
				}
			}

			if (myXML.TRANSMISSION.length()>0) {
				for (var q:uint = 0; q < transmissionsArray.length; q++) {
					removeTransmission(transmissionsArray[q]);
				}
			}

			if (myXML.SCRIPT.length()>0) {
				for (var w:uint = 0; w < scriptArray.length; w++) {
					removeScript(scriptArray[w]);
				}
			}

			removeChild(theBackground);
			thePlayer.quit=false;
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, thePlayer.myKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, thePlayer.myKeyUp);

			//gameCheck.removeEventListener(TimerEvent.TIMER, gameCheckTimer);
			removeEventListener(Event.ENTER_FRAME, checkGame, false);

			//checkGameEasy.stop();
			//checkGameEasy.removeEventListener(TimerEvent.TIMER, checkGame);

			removeEventListener(Event.ENTER_FRAME, checkLasers, false);

			if (victoryTimer.running) {
				victoryTimer.stop();
				victoryTimer.removeEventListener(TimerEvent.TIMER, victoryWin);
			}

			if (win==false) {
				spawnTimer.stop();
				spawnTimer.removeEventListener(TimerEvent.TIMER, spawnSquads);
				trace("you quit");
				exitLevel=true;
			} else {
				trace("you win");
				removeChild(thePlayer);
				victory=win;
			}
		} else {//if the player quits during the "story" screen
			fadeTimer.removeEventListener(TimerEvent.TIMER, fadeController);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, thePlayer.myKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, thePlayer.myKeyUp);
			removeEventListener(Event.ENTER_FRAME, checkGame);

			//checkGameEasy.stop();
			//checkGameEasy.removeEventListener(TimerEvent.TIMER, checkGame);

			removeEventListener(Event.ENTER_FRAME, checkLasers);
			removeChild(tweenScreen);
			trace("you quit");
			exitLevel=true;
		}
	}

	private function playerHit():void {
		if (! invulTimer.running) {
			thePlayer.removeLife();
		}//removeChild(livesImages[thePlayer.playerLives]);
	}

	private function enemyDistanceExplosion(enemy:EnemyShip, bullet:Bullet):Number {
		var dist:Number=0;
		dist = Math.pow((Math.pow((enemy.shipSprite.x - bullet.bulletSprite.x),2) + 
		Math.pow((enemy.shipSprite.y - bullet.bulletSprite.y),2)),.5);
		return dist;
	}

	private function playerDistanceBomb(bullet:Bullet):Number {
		var dist:Number=0;
		dist = Math.pow((Math.pow((thePlayer.playerShip.x - bullet.bulletSprite.x),2) + 
		Math.pow((thePlayer.playerShip.y - bullet.bulletSprite.y),2)),.5);
		return dist;
	}

	private function distanceFromBeam(enemy:EnemyShip):int {
		/*
		For a line with
		equation  Ax + By + C = 0  and a point (r,s) the distance from the point to
		the line is given by abs(Ar + Bs + C)/sqrt(A^2 + B^2).  Here abs denotes
		absolute value and sqrt denotes square root.
		*/

		var distance:int;
		var r:int=enemy.shipSprite.x;
		var s:int=enemy.shipSprite.y;
		var A:Number = (-1 * thePlayer.beam.slope);
		var B:Number=1;
		var C:Number = (thePlayer.beam.slope * thePlayer.beam.originX) - thePlayer.beam.originY;

		distance = Math.abs((A * r) + (B * s) + (C)) / Math.pow((A * A) + (B * B),0.5);
		return distance;
	}

	private function invulEnd(e:TimerEvent):void {
		if (thePlayer.playerLives>0) {
			cg_die.addItem(thePlayer);
			invulTimer.stop();
			invulTimer.reset();
			trace("vulnerable again");
		}
	}

	private function updateHUD():void {
		if (thePlayer.quit) {
			removeChild(weaponDisplay);
			removeChild(livesDisplay);
		} else {
			if (weaponDisplayActive) {
				removeChild(weaponDisplay);
			}
			if (livesDisplayActive) {
				removeChild(livesDisplay);
			}
			if (thePlayer.currentWeapon==0) {
				currentWeaponString="Equipped Weapon: Laser";
			} else if (thePlayer.currentWeapon == 1) {
				currentWeaponString="Equipped Weapon: Beam";
			} else if (thePlayer.currentWeapon == 2) {
				currentWeaponString="Equipped Weapon: Holofield";
			}

			weaponDisplay=new TextBox(currentWeaponString,9);
			weaponDisplay.x=SCREEN_WIDTH-weaponDisplay.width-10;
			weaponDisplay.y=SCREEN_HEIGHT-weaponDisplay.height-10;


			currentLivesString="Lives: "+thePlayer.playerLives+" - ";
			livesDisplay=new TextBox(currentLivesString,9);
			livesDisplay.x=SCREEN_WIDTH-weaponDisplay.width-livesDisplay.width-10;
			livesDisplay.y=SCREEN_HEIGHT-livesDisplay.height-10;

			addChild(weaponDisplay);
			addChild(livesDisplay);

			weaponDisplayActive=true;
			livesDisplayActive=true;
		}
	}

	private function checkGame(e:Event):void {
		scoreCollisions=cg_score.checkCollisions();
		dieCollisions=cg_die.checkCollisions();
		loopExit=false;//hacked together to stop one laser from causing multiple collisions

		for (var c:uint = 0; c < scoreCollisions.length; c++) {
			if (scoreCollisions[c]) {
				//trace(c + ", " + scoreCollisions[c].object1 + ", " + scoreCollisions[c].object2);
				if ( (scoreCollisions[c].object1 is Laser) && (scoreCollisions[c].object2 is EnemyShip) && loopExit == false) {
					//create small explosion for non-fatal hit on Gunship
					if (scoreCollisions[c].object2 is GothicGunship) {
						removeLaser(scoreCollisions[c].object1, true);
					} else {
						removeLaser(scoreCollisions[c].object1, false);
					}
					enemies[scoreCollisions[c].object2.parentIndex].removeEnemyLife(scoreCollisions[c].object2);
					if (scoreCollisions[c].object2.isDead()) {
						trace("You killed an enemy.");
						score=score+scoreCollisions[c].object2.pointValue;
					}
					loopExit=true;
				}

				if ( (scoreCollisions[c].object1 is EnemyShip) && (scoreCollisions[c].object2 is LevelProp) ) {
					enemies[scoreCollisions[c].object1.parentIndex].removeEnemyLife(scoreCollisions[c].object1);
					if (scoreCollisions[c].object1.isDead()) {
						trace("LevelProp killed an enemy.");
					}
				}

				if ( (scoreCollisions[c].object1 is Player) && (scoreCollisions[c].object2 is EnemyShip) ) {
					enemies[scoreCollisions[c].object2.parentIndex].removeEnemyLife(scoreCollisions[c].object2);
					if (scoreCollisions[c].object2.isDead()) {
						trace("You killed an enemy.");
						score=score+scoreCollisions[c].object2.pointValue;
					}
					playerHit();
				}

				if ( (scoreCollisions[c].object1 is EnemyShip) && (scoreCollisions[c].object2 is Player) ) {
					enemies[scoreCollisions[c].object1.parentIndex].removeEnemyLife(scoreCollisions[c].object1);
					if (scoreCollisions[c].object1.isDead()) {
						trace("You killed an enemy.");
						score=score+scoreCollisions[c].object1.pointValue;
					}
					playerHit();
				}
			}
		}

		for (var v:uint = 0; v < dieCollisions.length; v++) {
			if (dieCollisions[v]) {

				if ( (dieCollisions[v].object1 is Bullet) && (dieCollisions[v].object2 is Player) ) {
					dieCollisions[v].object1.setDead();
					playerHit();
					trace("An enemy shot you.");
				}

				if ( (dieCollisions[v].object1 is Player) && (dieCollisions[v].object2 is LevelProp) ) {
					playerHit();
					trace("You hit a LevelProp.");
				}

			}
		}

		for (var j:int = 0; j < enemies.length; j++) {
			/*
			thePlayer.playerShip.x + (playerShip.width/2) -> important to have the point in the middle for torpedo,
			really best aiming practice anyway to shoot for the middle
			*/
			enemies[j].trackPlayer(thePlayer.playerShip.x + (thePlayer.playerShip.width/2), 
			thePlayer.playerShip.y + (thePlayer.playerShip.height/2), thePlayer.currentWeapon);
			if (enemies[j].hostileOverride) {
				hostileOverride=true;
			}
			for (var p:int = 0; p < enemies[j].enemyList.length; p++) {
				if (thePlayer.beamActive) {
					if (distanceFromBeam(enemies[j].enemyList[p])<thePlayer.beam.range) {
						enemies[j].removeEnemy(enemies[j].enemyList[p], true);
					}
				}
				for (var q:uint = 0; q < enemies[j].masterBulletList.length; q++) {
					if (enemies[j].masterBulletList[q].weaponType=="Bomb") {
						if (playerDistanceBomb(enemies[j].masterBulletList[q])<enemies[j].masterBulletList[q].BOMB_RADIUS) {
							var bombExplosion:Explosion=new Explosion(enemies[j].masterBulletList[q].weaponType,
							enemies[j].masterBulletList[q].bulletSprite.x,
							enemies[j].masterBulletList[q].bulletSprite.y);
							addChild(bombExplosion);

							playerHit();
							trace("You hit an explosion.");

							invulTimer.start();
							trace("invulnerable");

							//this is probably prety expensive, could be remove to improve performance
							if (enemyDistanceExplosion(enemies[j].enemyList[p],
							enemies[j].masterBulletList[q])<(50 + enemies[j].masterBulletList[q].BOMB_RADIUS)) {
								enemies[j].removeEnemyLife(enemies[j].enemyList[p]);
							}

							enemies[j].masterBulletList[q].setDead();
						}
					}
				}
			}
		}

		if (truce&&! thePlayer.truceActive) {
			thePlayer.truceActive=true;
			removeChild(weaponDisplay);
			removeChild(livesDisplay);
			addChild(truceFlag);
			truceFlag.x=620;
			truceFlag.y=778;
		}
		if (! truce&&thePlayer.truceActive) {
			thePlayer.truceActive=false;
			addChild(weaponDisplay);
			addChild(livesDisplay);
			removeChild(truceFlag);
		}
		if (gameActive&&! truce) {
			updateHUD();
		}
		if (thePlayer.quit) {
			quit(false);
		}
	}
}
}