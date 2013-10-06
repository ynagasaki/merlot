package ;

import sys.io.File;
import org.flixel.FlxSprite;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxMath;
import org.flixel.util.FlxPoint;
import org.flixel.FlxGroup;

class Level {
	var mGraphics : FlxGroup = null;
	var mBackground : FlxSprite = null;
	var mLevelJson : Dynamic = null;
	var mFilename : String = null;
	var mBoundariesGlobal : List<Boundary> = null;
	var mPlatformSprites : List<PlatformSprite> = null;
	var mStartPoint : FlxPoint = null;

	public function new(filename : String, ?debug : Bool = false) {
		mPlatformSprites = new List();
		mBoundariesGlobal = new List();
		mGraphics = new FlxGroup();
		mFilename = filename;

		loadLevel(debug);
	}

	public function addPlatformSprite(sprite : PlatformSprite) : Void {
		mPlatformSprites.add(sprite);
		for(boundary in sprite.getBoundaries()) {
			mBoundariesGlobal.add(boundary);
		}
		mGraphics.add(sprite);
	}

	public function removePlatformSprite(sprite : PlatformSprite) : Void {
		mPlatformSprites.remove(sprite);
		for(boundary in sprite.getBoundaries()) {
			mBoundariesGlobal.remove(boundary);
		}
		mGraphics.remove(sprite, true);
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

		mGraphics.add(mBackground);

		try {
			var boundaries : Array<Dynamic> = mLevelJson.boundaries;
			var platforms : Array<Dynamic> = mLevelJson.platforms;

			if(boundaries != null) {
				for(dyn in boundaries) {
					addBoundary(Boundary.fromJson(dyn), debug);
				}
			}

			if(platforms != null) {
				for(dyn in platforms) {
					addPlatformSprite(PlatformSprite.fromJson(dyn, debug));
				}
			}

			findConnectedBoundarySegments();

			try {
				setStartPoint(mLevelJson.startpt[0], mLevelJson.startpt[1]);
			} catch(ex : Dynamic) {
				trace(ex);
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

	public function getLevelGraphics() : FlxGroup {
		return mGraphics;
	}

	public function findConnectedBoundarySegments() : Void {
		for(boundary in mBoundariesGlobal) {
			// "next" and "prev" only make sense for LTR segments
			for(existingBoundary in mBoundariesGlobal) {
				if(Utility.sameLoc(existingBoundary.surface.rightmostPoint, boundary.surface.leftmostPoint)) {
					if(boundary.prev != null && boundary.prev != existingBoundary) {
						trace("somethin wrong with this chain segment. #1");
					}

					existingBoundary.next = boundary;
					boundary.prev = existingBoundary;
				}

				if(Utility.sameLoc(existingBoundary.surface.leftmostPoint, boundary.surface.rightmostPoint)) {
					if(boundary.next != null && boundary.next != existingBoundary) {
						trace("somethin wrong with this chain segment. #2");
					}

					existingBoundary.prev = boundary;
					boundary.next = existingBoundary;
				}
			}
		}
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
		var platforms : Array<Dynamic> = new Array();
		var savedBoundaries : List<Boundary> = new List();

		for(platform in mPlatformSprites) {
			var dyn : Dynamic = platform.toJson();
			platforms.push(dyn);

			// so we don't double-save the same boundaries
			for(platformBoundary in platform.getBoundaries())
				savedBoundaries.add(platformBoundary);
		}

		for(boundary in mBoundariesGlobal) {
			// this is not very efficient, but it's only during save AND it doesn't affect play time
			if(Lambda.exists(savedBoundaries, boundary.is)) continue;

			boundaries.push(boundary.toJson());
		}

		mLevelJson.boundaries = boundaries;
		mLevelJson.platforms = platforms;
		mLevelJson.startpt = [mStartPoint.x, mStartPoint.y];

		var fout = File.write(mFilename, false);
		fout.writeString(haxe.Json.stringify(mLevelJson));
		fout.close();

		trace("saved: " + mFilename);
	}

	public function setStartPoint(x : Float, y : Float) : Void {
		if(mStartPoint == null) mStartPoint = new FlxPoint(x, y);
		mStartPoint.x = x;
		mStartPoint.y = y;
	}

	public function getStartPoint() : FlxPoint {
		return mStartPoint;
	}

	public function checkSurfaceCollision(trajectory : Line) : IntersectionCheckResult {
		var checkedCount : Int = 0;
		var intersectionPoint : FlxPoint = null;
		var topmostIntersectionPoint : FlxPoint = null;
		var intersectionBoundary : Boundary = null;

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
					intersectionBoundary = boundary;
				}
			}
		}

		//trace("checked: " + checkedCount);
		return new IntersectionCheckResult(topmostIntersectionPoint,  intersectionBoundary);
	}
}