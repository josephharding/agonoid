
package
{
	
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLVariables;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.events.*;
	
	public class DataEntryScreen extends Sprite {
		
		var variables:URLVariables = new URLVariables();
		var loader:URLLoader;
		var request:URLRequest;
		
		public function DataEntryScreen(playerName:String, score:int) {
			variables.name = playerName;
			variables.score = score;
			
			request = new URLRequest();
			request.url = "../agonoid/writeScores.php";
			request.data = variables;
			
			loader = new URLLoader();
			loader.load(request);
			loader.addEventListener(Event.COMPLETE, completeWriting);
		}

		public function completeWriting(event:Event):void {
			var writingCompleted:TextBox = new TextBox(event.target.data, 1);
			addChild(writingCompleted);
			writingCompleted.x = 300;
		}
	}
}

