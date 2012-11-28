package {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.Timer;

	public class CaptureInput extends Sprite {

		var screenWidth:int;
		var screenHeight:int;

		var gameOverScreen:DataEntryScreen;
		var gameOverTimer:Timer;
		var totalScore:int;

		var inputBox:TextField = new TextField();
		var enteredName:String="_ _ _";
		var exit:Boolean=false;
		var doneTyping:Boolean=false;
		var SPACE:uint=32;

		public function CaptureInput(score:int, sWidth:int, sHeight:int) {
			screenWidth=sWidth;
			screenHeight=sHeight;

			gameOverTimer=new Timer(2000);
			gameOverTimer.addEventListener(TimerEvent.TIMER, quit);
			totalScore=score;
			captureText();
		}

		public function captureText():void {
			var bigFormat:TextFormat = new TextFormat();
			bigFormat.font="Agency FB";
			bigFormat.color=0xFFFFFF;
			bigFormat.size=24;

			var instructionBox:TextBox=new TextBox("Enter name (3 char max): ",5);
			addChild(instructionBox);
			instructionBox.x = (screenWidth/2) - (instructionBox.width/2);
			instructionBox.y=250;

			inputBox.type=TextFieldType.INPUT;
			addChild(inputBox);
			inputBox.text=enteredName;
			inputBox.x = (screenWidth/2) - (inputBox.width/2);
			inputBox.y=300;

			var instructionBox2:TextBox=new TextBox("press space to continue...",5);
			addChild(instructionBox2);
			instructionBox2.x = (screenWidth/2) - (instructionBox2.width/2);
			instructionBox2.y=350;

			inputBox.addEventListener(MouseEvent.CLICK, clearBox);
			inputBox.addEventListener(KeyboardEvent.KEY_DOWN, inputEventCapture);
			inputBox.autoSize=TextFieldAutoSize.CENTER;
			inputBox.setTextFormat(bigFormat);
		}

		public function clearBox(e:MouseEvent):void {
			removeChild(inputBox);
			enteredName="";
			inputBox.text=enteredName;
			addChild(inputBox);
		}

		public function inputEventCapture(e:KeyboardEvent):void {
			var myString:String=inputBox.text.toString();

			if (doneTyping==false) {
				if (e.keyCode==SPACE||myString.length>2) {
					doneTyping=true;
					enteredName=inputBox.text;
					gameOverScreen=new DataEntryScreen(enteredName,totalScore);
					gameOverTimer.start();
				}
			}
		}

		public function quit(e:TimerEvent):void {
			exit=true;
		}
	}
}