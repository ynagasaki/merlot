package;

import org.flixel.util.FlxPoint;

class Line {
	public var p1 : FlxPoint;
	public var p2 : FlxPoint;

	public function new(x1 : Float, y1 : Float, x2 : Float, y2 : Float) {
		p1 = new FlxPoint(x1, y1);
		p2 = new FlxPoint(x2, y2);
	}

	public function toStringForFile() : String {
		return p1.x + " " + p1.y + " " + p2.x + " " + p2.y;
	}

	public function toString() : String {
		return "(" + p1.x + ", " + p1.y + ") (" + p2.x + ", " + p2.y + ")";
	}
}