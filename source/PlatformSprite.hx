package ;

import org.flixel.FlxSprite;
import org.flixel.util.FlxColor;

class PlatformSprite extends FlxSprite {
	private var mBoundaries : List<Boundary> = null;
	private var mFilename : String = null;

	public function new(filename : String) : Void {
		super();

		mFilename = filename;
		loadGraphic(filename, false, false);

		mBoundaries = new List();
	}

	override public function move(X : Float, Y : Float) : Void {
		if(X == x && Y == y) return;

		var deltax : Float = this.x;
		var deltay : Float = this.y;

		super.move(X, Y);

		deltax = this.x - deltax;
		deltay = this.y - deltay;

		// make this more efficient
		for(boundary in mBoundaries) {
			boundary.surface.p1.x += deltax;
			boundary.surface.p1.y += deltay;
			boundary.surface.p2.x += deltax;
			boundary.surface.p2.y += deltay;

			boundary.normal.p1.x += deltax;
			boundary.normal.p1.y += deltay;
			boundary.normal.p2.x += deltax;
			boundary.normal.p2.y += deltay;
		}
	}

	public function addBoundary(boundary : Boundary) : Void {
		// boundary will be stored in world coords
		mBoundaries.add(boundary);
	}

	public function getBoundaries() : List<Boundary> {
		return mBoundaries;
	}

	public function toJson() : Dynamic {
		var boundaries : Array<Dynamic> = new Array();

		for(boundary in mBoundaries) {
			boundaries.push(boundary.toJson());
		}

		return {"f":mFilename,"b":boundaries,"p":[x,y]};
	}

	public static function fromJson(jsonobj : Dynamic) : PlatformSprite {
		var retval : PlatformSprite = null;

		try {
			retval = new PlatformSprite(jsonobj.f);

			retval.x = jsonobj.p[0];
			retval.y = jsonobj.p[1];

			var boundaries : Array<Dynamic> = jsonobj.b;
			for(dyn in boundaries) {
				retval.addBoundary(Boundary.fromJson(dyn));
			}
		} catch(ex : Dynamic) {
			trace("PlatformSprite.fromJson: " + ex);
			retval = null;
		}

		return retval;
	}
}