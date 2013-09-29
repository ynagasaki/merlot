package ;

import sys.io.File;
import org.flixel.FlxSprite;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxMath;
import org.flixel.util.FlxPoint;

class Level {
	var mBackground : FlxSprite = null;
	var mLevelJson : Dynamic = null;
	var mFilename : String = null;
	var mBoundariesGlobal : List<Boundary> = null;
	var mPlatformSprites : List<PlatformSprite> = null;

	public function new(filename : String, ?debug : Bool = false) {
		mPlatformSprites = new List();
		mBoundariesGlobal = new List();
		mFilename = filename;

		loadLevel(debug);
	}

	public function addPlatformSprite(sprite : PlatformSprite) : Void {
		mPlatformSprites.add(sprite);

	}

	public function pickPlatformSprite(x : Float, y : Float) : PlatformSprite {
		try {
		for(s in mPlatformSprites) {
			var sx : Float = s.x;
			var sw : Float = s.width;
			var sy : Float = s.y;
			var sh : Float = s.height;

			if(x >= sx && x <= sw + sx && y >= sy && y <= sy + sh) return s;
		}
		} catch(ex:Dynamic) {
			trace(ex);
		}
		return null;
	}

	private function loadLevel(debug : Bool) : Void {
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
				//trace(dyn);
				var boundary = new Boundary();
				boundary.surface = new Line(dyn.s[0], dyn.s[1], dyn.s[2], dyn.s[3]);
				boundary.normal = new Line(dyn.n[0], dyn.n[1], dyn.n[2], dyn.n[3]);
				addBoundary(boundary, debug);
			}
		} catch(ex : Dynamic) {
			trace("lol:" + ex);
		}
	}

	public function getWidth() : Int {
		return mLevelJson.width;
	}

	public function getHeight() : Int {
		return mLevelJson.height;
	}

	public function getLevelSprite() : FlxSprite {
		return mBackground;
	}

	public function addBoundary(boundary : Boundary, ?drawBoundary : Bool = false) : Void {
		mBoundariesGlobal.add(boundary);
		if(drawBoundary) {
			mBackground.drawLine(boundary.surface.p1.x, boundary.surface.p1.y, boundary.surface.p2.x, boundary.surface.p2.y, FlxColor.BLACK, 1);
			mBackground.drawLine(boundary.normal.p1.x, boundary.normal.p1.y, boundary.normal.p2.x, boundary.normal.p2.y, FlxColor.RED, 1);
		}
	}

	public function save() : Void {
		var boundaries : Array<Dynamic> = new Array();

		for(boundary in mBoundariesGlobal) {
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

	public function checkSurfaceCollision(trajectory : Line) : IntersectionCheckResult {
		var checkedCount : Int = 0;
		var intersectionPoint : FlxPoint = null;
		var topmostIntersectionPoint : FlxPoint = null;
		var intersectionLine : Line = null;

		// maybe do like a BSP tree
		for(boundary in mBoundariesGlobal) {
			var s : Line = boundary.surface;

			if(trajectory.p1.y > s.bottommostPoint.y) continue;
			if(trajectory.p1.x > s.rightmostPoint.x) continue;
			if(trajectory.p1.x < s.leftmostPoint.x) continue;

			intersectionPoint = Utility.checkLineIntersection(trajectory, s);
			checkedCount ++;

			if(intersectionPoint != null) {
				// we check if topmost > current-intersection b/c larger Y is visually lower
				if(topmostIntersectionPoint == null || topmostIntersectionPoint.y > intersectionPoint.y) {
					topmostIntersectionPoint = intersectionPoint;
					intersectionLine = s;
				}
			}
		}

		//trace("checked: " + checkedCount);
		return new IntersectionCheckResult(topmostIntersectionPoint,  intersectionLine);
	}
}