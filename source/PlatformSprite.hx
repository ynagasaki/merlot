
package ;

import org.flixel.FlxSprite;

class PlatformSprite extends FlxSprite {
	private var mBoundaries : List<Boundary> = null;

	public function new(filename : String) {
		super();

		loadGraphic(filename, false, false);

		mBoundaries = new List();
	}

	public function addBoundary(boundary : Boundary) : Void {
		mBoundaries.add(boundary);
	}

	public function getBoundaries() : List<Boundary> {
		return mBoundaries;
	}
}