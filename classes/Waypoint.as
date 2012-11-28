package {

	public class Waypoint {
		
		var xPos:int;
		var yPos:int;
		var waitTime:int;
		var currentAngle:Number;
		var maxSpeed:Number;
		var acceleration:Number;
		var transmission:Transmission;
		var transmissionPoint:int;

		public function Waypoint(x:int, y:int, wait:int, angle:Number, maxS:int, accel:Number, trans:Transmission, transPoint:int) {
			xPos = x;
			yPos = y;
			waitTime = wait;
			currentAngle = angle;
			maxSpeed = maxS;
			acceleration = accel;
			transmission = trans;
			transmissionPoint = transPoint;
		}
	}
}

		