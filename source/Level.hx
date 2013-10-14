package ;

import sys.io.File;
import org.flixel.FlxSprite;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxMath;
import org.flixel.util.FlxPoint;
import org.flixel.FlxGroup;

class Level {
	var mFilename : String = null;
	var mLevelJson : Dynamic = null;
	var mGraphics : FlxGroup = null;
	var mBackground : FlxSprite = null;
	var mStartPoint : FlxPoint = null;
	var mNutCoins : List<CollectibleSprite> = null;
	var mBoundariesGlobal : List<Boundary> = null;
	var mPlatformSprites : List<PlatformSprite> = null;
	var mInnerLevels : List<InnerLevel> = null;

	public function new(filename : String) {
		mNutCoins = new List();
		mPlatformSprites = new List();
		mBoundariesGlobal = new List();
		mInnerLevels = new List();
		mGraphics = new FlxGroup();
		mFilename = filename;
		
		if(filename != null) loadLevel();
	}

	public function getNutCoins() : List<CollectibleSprite> {
		return mNutCoins;
	}

	public function addNutCoin(sprite : CollectibleSprite) : Void {
		mNutCoins.add(sprite);
		mGraphics.add(sprite);
	}

	public function addPlatformSprite(sprite : PlatformSprite) : Void {
		mPlatformSprites.add(sprite);
		mGraphics.add(sprite);
		for(boundary in sprite.getBoundaries()) {
			addBoundary(boundary);
		}
	}

	public function removeNutCoin(sprite : CollectibleSprite) : Void {
		mNutCoins.remove(sprite);
		mGraphics.remove(sprite, true);
	}

	public function removePlatformSprite(sprite : PlatformSprite) : Void {
		mPlatformSprites.remove(sprite);
		mGraphics.remove(sprite, true);
		for(boundary in sprite.getBoundaries()) {
			mBoundariesGlobal.remove(boundary);
		}
	}

	public function pickSprite(x : Float, y : Float) : FlxSprite {
		try {
			for(s in mPlatformSprites) {
				if(Utility.isPointInSpriteBounds(x, y, s)) return s;
			}

			for(s in mNutCoins) {
				if(Utility.isPointInSpriteBounds(x, y, s)) return s;
			}
		} catch(ex:Dynamic) {
			trace(ex);
		}
		return null;
	}

	private function prepareBackground(filename : String) : Void {
		mBackground = new FlxSprite(0, 0);
		mBackground.loadGraphic(filename, false, false);
		mGraphics.add(mBackground);
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

		prepareBackground(mLevelJson.background);

		try {
			var boundaries : Array<Dynamic> = mLevelJson.boundaries;
			var platforms : Array<Dynamic> = mLevelJson.platforms;
			var nutcoins : Array<Dynamic> = mLevelJson.nutcoins;

			for(dyn in boundaries) {
				addBoundary(Boundary.fromJson(dyn));
			}

			for(dyn in platforms) {
				addPlatformSprite(PlatformSprite.fromJson(dyn));
			}

			for(dyn in nutcoins) {
				addNutCoin(CollectibleSprite.fromJson(dyn));
			}

			findConnectedBoundarySegments();

			try {
				setStartPoint(mLevelJson.startpt[0], mLevelJson.startpt[1]);
			} catch(ex : Dynamic) {
				trace("lol, startpt troubles: " + ex);
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

	public function addBoundary(boundary : Boundary) : Void {
		mBoundariesGlobal.add(boundary);
	}

	public function getGlobalBoundariesList() : List<Boundary> {
		return mBoundariesGlobal;
	}

	public function removeBoundary(boundary : Boundary) : Void {
		mBoundariesGlobal.remove(boundary);
		for(platformsprite in mPlatformSprites) {
			if(platformsprite.removeBoundary(boundary)) break;
		}
	}

	public function save() : Void {
		if(mFilename == null) return;

		var boundaries : Array<Dynamic> = new Array();
		var platforms : Array<Dynamic> = new Array();
		var nutcoins : Array<Dynamic> = new Array();
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

		for(nutcoin in mNutCoins) {
			nutcoins.push(nutcoin.toJson());
		}

		mLevelJson.nutcoins = nutcoins;
		mLevelJson.boundaries = boundaries;
		mLevelJson.platforms = platforms;
		mLevelJson.startpt = [mStartPoint.x, mStartPoint.y];

		var fout = File.write(mFilename, false);
		fout.writeString(haxe.Json.stringify(mLevelJson));
		fout.close();
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
