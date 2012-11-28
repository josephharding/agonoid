package {
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class TextBox extends Sprite {

		var theText:TextField;
		
		var scoreFormat:TextFormat;
		var bigFormat:TextFormat;
		var smallFormat:TextFormat;

		public function TextBox(myText:String, type:int) {
			theText = new TextField();
			theText.text=myText;
			configureText(theText, type);
			addChild(theText);
		}

		private function configureText(theText, type):void {
			if (type==0) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				bigFormat = new TextFormat();
				bigFormat.font="Agency FB";
				bigFormat.color=0xFFFFFF;
				bigFormat.size=24;
				theText.setTextFormat(bigFormat);
			} else if (type == 1) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				smallFormat = new TextFormat();
				smallFormat.font="Agency FB";
				smallFormat.color=0xFFFFFF;
				smallFormat.size=18;
				theText.setTextFormat(smallFormat);
			} else if (type == 2) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				scoreFormat = new TextFormat();
				scoreFormat.font="Agency FB";
				scoreFormat.color=0xFFFFFF;
				scoreFormat.size=36;
				theText.autoSize=TextFieldAutoSize.CENTER;
				theText.setTextFormat(scoreFormat);
			} else if (type == 3) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				scoreFormat = new TextFormat();
				scoreFormat.font="Agency FB";
				scoreFormat.color=0xFFFFFF;
				scoreFormat.size=36;
				theText.autoSize=TextFieldAutoSize.LEFT;
				theText.setTextFormat(scoreFormat);
			} else if (type == 4) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				scoreFormat = new TextFormat();
				scoreFormat.font="Agency FB";
				scoreFormat.color=0xFFFFFF;
				scoreFormat.size=36;
				theText.autoSize=TextFieldAutoSize.RIGHT;
				theText.setTextFormat(scoreFormat);
			} else if (type == 5) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				smallFormat = new TextFormat();
				smallFormat.font="Agency FB";
				smallFormat.color=0xFFFFFF;
				smallFormat.size=18;
				theText.autoSize=TextFieldAutoSize.LEFT;
				theText.setTextFormat(smallFormat);
			} else if (type == 6) {
				theText.autoSize=TextFieldAutoSize.RIGHT;
				smallFormat = new TextFormat();
				smallFormat.font="Agency FB";
				smallFormat.color=0xFFFFFF;
				smallFormat.size=18;
				theText.autoSize=TextFieldAutoSize.LEFT;
				theText.setTextFormat(smallFormat);
			} else if (type == 7) {
				var smallTransmissionFormat:TextFormat = new TextFormat();
				smallTransmissionFormat.font="OCR A Std";
				smallTransmissionFormat.color=0xFFFFFF;
				smallTransmissionFormat.size=10;
				theText.autoSize=TextFieldAutoSize.LEFT;
				theText.setTextFormat(smallTransmissionFormat);
			} else if (type == 8) {
				var largeTransmissionFormat:TextFormat = new TextFormat();
				largeTransmissionFormat.font="OCR A Std";
				largeTransmissionFormat.color=0xFFFFFF;
				largeTransmissionFormat.size=12;
				theText.autoSize=TextFieldAutoSize.LEFT;
				theText.setTextFormat(largeTransmissionFormat);
				theText.wordWrap=true;
				theText.width=277;
			} else if (type == 9) {
				var weaponFormat:TextFormat = new TextFormat();
				weaponFormat.font="Agency FB";
				weaponFormat.color=0xFFFFFF;
				weaponFormat.size=14;
				theText.autoSize=TextFieldAutoSize.LEFT;
				theText.setTextFormat(weaponFormat);
			}
		}
	}
}