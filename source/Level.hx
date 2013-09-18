
import sys.io.File;
import org.flixel.FlxSprite;

class Level {
	var mBackground : FlxSprite = null;
	var mBoundaries : List<Boundary> = null;
	var mLevelJson : Dynamic = null;
	var mFilename : String = null;

	public function new(filename : String) {
		mBoundaries = new List();
		mFilename = filename;

		loadLevel();
	}

	private function loadLevel() : Void {
		var contents :  String = null;

		try {
			contents = File.getContent(mFilename);
		} catch(ex : Dynamic) {
			trace("** error: File probably not found: " + ex);
		}

		try {
			mLevelJson = haxe.Json.parse(contents);
		} catch(ex : Dynamic) {
			trace("** error: Parsing level json string failed: " + ex);
		}

		mBackground = new FlxSprite(0, 0);

		mBackground.loadGraphic(
			mLevelJson.background, 
			false, 
			false, 
			mLevelJson.width,
			mLevelJson.height,
			true
		);

		try {
		var boundaries : Array<Dynamic> = mLevelJson.boundaries;
		for(dyn in boundaries) {
			trace(dyn);
			var boundary = new Boundary();
			boundary.surface = new Line(dyn.s[0], dyn.s[1], dyn.s[2], dyn.s[3]);
			boundary.normal = new Line(dyn.n[0], dyn.n[1], dyn.n[2], dyn.n[3]);
			addBoundary(boundary);
		}
		} catch(ex : Dynamic) {
			trace(ex);
		}
	}

	public function getLevelSprite() : FlxSprite {
		return mBackground;
	}

	public function addBoundary(boundary : Boundary) : Void {
		mBoundaries.add(boundary);
		mBackground.drawLine(boundary.surface.p1.x, boundary.surface.p1.y, boundary.surface.p2.x, boundary.surface.p2.y, 1, 1);
		mBackground.drawLine(boundary.normal.p1.x, boundary.normal.p1.y, boundary.normal.p2.x, boundary.normal.p2.y, 52, 1);
	}

	public function save() : Void {
		var boundaries : Array<Dynamic> = new Array();

		for(boundary in mBoundaries) {
			var s : Line = boundary.surface;
			var n : Line = boundary.normal;
			var dynboundary : Dynamic = {"s":[s.p1.x, s.p1.y, s.p2.x, s.p2.y], "n":[n.p1.x, n.p1.y, n.p2.x, n.p2.y]};
			boundaries.push(dynboundary);
		}

		mLevelJson.boundaries = boundaries;

		var fout = File.write(mFilename, false);
		fout.writeString(haxe.Json.stringify(mLevelJson));
		fout.close();

		trace("saved: " + mFilename);
	}
}