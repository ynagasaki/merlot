
package ;

import org.flixel.FlxSprite;
import org.flixel.util.FlxColor;

class PlatformSprite extends FlxSprite {
	private var mBoundaries : List<Boundary> = null;

	public function new(filename : String) {
		super();

		loadGraphic(filename, false, false);

		mBoundaries = new List();
	}

	public function addBoundary(boundary : Boundary, drawBoundary : Bool) : Void {
		mBoundaries.add(boundary);
		if(drawBoundary) {
			drawLine(boundary.surface.p1.x, boundary.surface.p1.y, boundary.surface.p2.x, boundary.surface.p2.y, FlxColor.BLACK, 1);
			drawLine(boundary.normal.p1.x, boundary.normal.p1.y, boundary.normal.p2.x, boundary.normal.p2.y, FlxColor.RED, 1);
		}
	}

	public function getBoundaries() : List<Boundary> {
		return mBoundaries;
	}
}