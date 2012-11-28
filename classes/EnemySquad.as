package {
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.display.Shape;
	import com.coreyoneil.collision.CollisionGroup;
	import flash.events.*;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;


	public class EnemySquad extends Sprite {
		var masterBulletList:Array=new Array  ;
		var enemyList:Array=new Array  ;

		var newDroneList:Array=new Array  ;
		var newFighterList:Array=new Array  ;

		var startX:int;
		var cg_score:CollisionGroup;
		var cg_die:CollisionGroup;
		var wipedOut:Boolean=false;
		var parentIndex:int;

		var explosionRadius:Array=new Array  ;
		var radiusTimer:Array=new Array  ;
		
		var playerX:int;
		var playerY:int;
		var playerWeapon:int;
		var hostileOverride:Boolean = false;
		
		var BOMB_RADIUS:int = 100;
		var checkingBullets:Boolean = false;

		public function EnemySquad(type:String, numMembers:int, sPosX:int, cg1:CollisionGroup, cg2:CollisionGroup, index, hostile:Boolean) {
			cg_score=cg1;
			cg_die=cg2;
			parentIndex=index;
			startX=sPosX;
			hostileOverride = hostile;
			makeMembers(type, numMembers);
			addEventListener(Event.ENTER_FRAME, checkChildren, false, 0, true);
		}

		public function checkChildren(e:Event):void {
			for (var q:uint = 0; q < enemyList.length; q++) {
				enemyList[q].trackPlayer(playerX, playerY, playerWeapon);
			}
			for (var j:uint = 0; j < enemyList.length; j++) {
				if (enemyList[j].justFired) {
					//trace(getClass(enemyList[j]));
					//trace("bulletList length before: " + enemyList[j].bulletList.length);
					for(var k:uint=0; k < enemyList[j].bulletList.length; k++) {
						masterBulletList.push(enemyList[j].bulletList[k]);
						addChild(masterBulletList[masterBulletList.length-1]);
						cg_die.addItem(masterBulletList[masterBulletList.length-1]);
					}
					enemyList[j].bulletList.splice(0,enemyList[j].bulletList.length);
					enemyList[j].justFired=false;
					//trace("bulletList length after: " + enemyList[j].bulletList.length);
				}
				if (enemyList[j].killMe==true) {
					removeEnemy(enemyList[j], false);
				}
				
			}

			for (var i:uint = 0; i < masterBulletList.length; i++) {
		
				if(masterBulletList[i].weaponType == "Torpedo") {
					masterBulletList[i].updateAngle(playerX, playerY);
				}
				
				if (masterBulletList[i].isDead()) {
					removeBullet(masterBulletList[i]);
					masterBulletList.splice(i,1);
				}
			}

			if (enemyList.length==0) {
				wipedOut=true;
			}
		}
		
		public function trackPlayer(posX:Number, posY:Number, cw:int):void {
			playerX = posX;
			playerY = posY;
			playerWeapon = cw;
		}

		public function makeMembers(type:String, numToMake:int):void {
			for (var i:uint = 0; i < numToMake; i++) {
				if (type=="DRONE") {
					enemyList.push(new Drone(80*i+startX,-40,cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="FIGHTER" ) {
					//to cause an enemy to always know you're hostile, even if in disguise
					//hostileOverride = true;
					enemyList.push(new Fighter((100*i)+startX,-40 - (30*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="BOMBER" ) {
					enemyList.push(new Bomber((100*i)+startX,-40,cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="DEFENDER" ) {
					enemyList.push(new Defender((100*i)+startX,-100 - (10*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="GUARDIAN" ) {
					enemyList.push(new Guardian((100*i)+startX,-40 - (10*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="GOTHICGUNSHIP" ) {
					enemyList.push(new GothicGunship((100*i)+startX,-80 - (10*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="GOTHICFIGHTER" ) {
					enemyList.push(new GothicFighter((50*i)+startX,-40 - (10*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				} else if ( type=="GOTHICPHANTOM" ) {
					enemyList.push(new GothicPhantom((50*i)+startX,-40 - (10*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				}
				/*
				else if ( type=="GOTHIC_TARGET" ) {
					hostileOverride = true;
					enemyList.push(new Guardian((100*i)+startX,-40 - (10*i),cg_die,parentIndex));
					addChild(enemyList[enemyList.length-1]);
					cg_score.addItem(enemyList[enemyList.length-1]);
				}
				*/
				if(hostileOverride) {
					enemyList[i].hostile = true;
				}
			}
		}

		public function removeBullet(bullet:Bullet):void {
			if (bullet.weaponType=="Torpedo") {
				var bombExplosion:Explosion=new Explosion(bullet.weaponType,bullet.bulletSprite.x,bullet.bulletSprite.y);
				addChild(bombExplosion);
			}
			removeChild(bullet);
			cg_die.removeItem(bullet);
		}

		public function removeEnemyLife(enemy:EnemyShip):void {
			enemy.LIVES--;
			if (enemy.LIVES<=0) {
				removeEnemy(enemy, true);
			}
		}

		public function removeEnemy(enemy:EnemyShip, explode:Boolean):void {
			cg_score.removeItem(enemy);
			enemy.setDead(getClass(enemy), enemy.shipSprite, explode);
			removeChild(enemy);

			for (var i:int = 0; i < enemyList.length; i++) {
				if (enemyList[i].isDead()==true) {
					enemyList.splice(i, 1);
				}
			}
		}

		static function getClass(obj:Object):String {
			var theString:String=getQualifiedClassName(obj);
			return theString;
		}
	}
}