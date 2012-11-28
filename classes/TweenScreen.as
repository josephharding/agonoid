package {
	import flash.display.*;
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.xml.*;

	public class TweenScreen extends Sprite {
		var textXML:XML;
		var highScores:XML;
		var levelNumber:int;
		var credits:Array=new Array  ;
		var myLoaderScores:URLLoader;
		var myRequestScores:URLRequest;

		var highest:int=0;
		var highestIndex:int=0;
		var topThreeIndex:Array=new Array  ;
		var newArray:Array=new Array  ;
		var holderArray:Array=new Array  ;
		var highNum:int=0;
		var highIndex:int=0;
		
		var galaxySprite:AnimatedSprite;

		public function TweenScreen(levelNum:int) {
			levelNumber=levelNum;
			if (levelNum==7) {
				myLoaderScores = new URLLoader();
				myRequestScores=new URLRequest("../agonoid/highScores.xml?"+Math.random());//this '?<?=rand()?>' addition should handle Chrome not refreshing cache
				myLoaderScores.load(myRequestScores);
				myLoaderScores.addEventListener(Event.COMPLETE, processScoreXML);
			} else {
				var myLoader:URLLoader = new URLLoader();
				myLoader.load(new URLRequest("../agonoid/text.xml"));
				myLoader.addEventListener(Event.COMPLETE, processXML);
				galaxySprite = new AnimatedSprite(516,515,1,3,new galaxy(516,515),true,1);
			}
		}

		private function processScoreXML(e:Event):void {
			highScores=new XML(e.target.data);

			var myLoader:URLLoader = new URLLoader();
			myLoader.load(new URLRequest("../agonoid/text.xml"));
			myLoader.addEventListener(Event.COMPLETE, processXML);
		}

		private function processXML(e:Event):void {
			textXML=new XML(e.target.data);
			initialize();
		}

		private function findHighest(theArray:Array):Array {
			for (var i:uint = 0; i < 3; i++) {
				highNum=0;
				highIndex=0;
				for (var j:uint = 0; j < theArray.length; j++) {
					//trace("Index: " + j + " Value: " + theArray[j]);
					if (theArray[j]>highNum) {
						highNum=theArray[j];
						highIndex=j;
					}
				}
				topThreeIndex[i]=highIndex;
				//trace("High Index: " + highIndex + " High Value: " + theArray[highIndex]);
				theArray[highIndex]=0;
			}
			return topThreeIndex;
		}

		private function initialize():void {
			if (levelNumber==7) {
				for (var k:uint = 0; k < highScores.HIGHSCORE.length(); k++) {
					holderArray[k]=highScores.HIGHSCORE[k].@NUMBER;
				}

				topThreeIndex=findHighest(holderArray);

				for (var i:uint = 0; i < 3; i++) {
					var credBoxName:TextBox=new TextBox(highScores.HIGHSCORE[topThreeIndex[i]].@NAME,3);
					var credBoxNum:TextBox=new TextBox(highScores.HIGHSCORE[topThreeIndex[i]].@NUMBER,4);
					credBoxName.x=0;
					credBoxName.y=50*i;
					credBoxNum.x=100;
					credBoxNum.y=50*i;
					addChild(credBoxName);
					addChild(credBoxNum);
				}
			} else {

				var titleBox:TextBox=new TextBox(textXML.LEVEL[levelNumber-1].@TITLE,0);
				var descBox:TextBox=new TextBox(textXML.LEVEL[levelNumber-1].@DESC,1);
				titleBox.x=500;
				titleBox.y=700;
				descBox.x=500;
				descBox.y=730;
				galaxySprite.x=67;
				galaxySprite.y=60;
				addChild(titleBox);
				addChild(descBox);
				addChild(galaxySprite);
			}
		}
	}
}