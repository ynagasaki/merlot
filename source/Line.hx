package ;

import org.flixel.util.FlxPoint;

class Line {
	public var p1 : FlxPoint;
	public var p2 : FlxPoint;
	public var rightmostPoint : FlxPoint;
	public var leftmostPoint : FlxPoint;
	public var topmostPoint : FlxPoint;
	public var bottommostPoint : FlxPoint;
	public var slope : Float;
	public var yintercept : Float;

	public function new(x1 : Float, y1 : Float, x2 : Float, y2 : Float) {
		p1 = new FlxPoint(x1, y1);
		p2 = new FlxPoint(x2, y2);

		if(x1 > x2) {
			rightmostPoint = p1;
			leftmostPoint = p2;
		} else {
			rightmostPoint = p2;
			leftmostPoint = p1;
		}

		if(y1 < y2) {
			topmostPoint = p1;
			bottommostPoint = p2;
		} else {
			topmostPoint = p2;
			bottommostPoint = p1;
		}

		slope = (y2 - y1) / (x2 - x1);
		//if((x2 - x1) == 0) trace("DIVIDE BY ZERO??? " + slope);
		yintercept = slope * (-x1) + y1; // y = m (x-x1) + y1
	}

	// y = mx + b
	public function getY(x : Float) : Float {
		return slope * x + yintercept;
	}

	public function toStringForFile() : String {
		return p1.x + " " + p1.y + " " + p2.x + " " + p2.y;
	}

	public function toString() : String {
		return "(" + p1.x + ", " + p1.y + ") (" + p2.x + ", " + p2.y + ")";
	}
}