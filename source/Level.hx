package ;

import sys.io.File;
import org.flixel.FlxSprite;
import org.flixel.util.FlxPoint;
import org.flixel.util.FlxRect;
import org.flixel.FlxGroup;

class Level {
	var mFilename : String = null;
	var mLevelJson : Dynamic = null;
	var mGraphics : FlxGroup = null;
	var mBackground : FlxSprite = null;
	var mStartPoint : FlxPoint = null;

	var mNutCoins : List<CollectibleSprite> = null;
	var mInnerLevels : List<InnerLevel> = null;
	var mPlatformSprites : List<PlatformSprite> = null;
	var mBoundariesGlobal : List<Boundary> = null;
	var mCrossLevelGates : List<CrossLevelGate> = null;

	public function new(filename : String) {
		mNutCoins = new List();
		mPlatformSprites = new List();
		mBoundariesGlobal = new List();
		mCrossLevelGates = new List();
		mInnerLevels = new List();
		mGraphics = new FlxGroup();
		mFilename = filename;
		
		if(filename != null) loadLevel();
	}

	public function getId() : String {
		return mFilename;
	}

	public function getBackground() : FlxSprite {
		return mBackground;
	}

	public function getNutCoins() : List<CollectibleSprite> {
		return mNutCoins;
	}

	public function getPlatformSprites() : List<PlatformSprite> {
		return mPlatformSprites;
	}

	public function getCrossLevelGates() : List<CrossLevelGate> {
		return mCrossLevelGates;
	}

	public function getInnerLevels() : List<InnerLevel> {
		return mInnerLevels;
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

	public function addCrossLevelGate(gate : CrossLevelGate) : Void {
		for(lvl in mInnerLevels) {
			if(gate.isRelevantTo(lvl) && gate.isRelevantTo(this)) {
				mCrossLevelGates.add(gate);
				gate.getDestinationLevelRelativeTo(this).addCrossLevelGate(gate);
				return;
			}
		}
		trace("Gate not added b/c it is irrelevant to this level.");
	}

	public function addInnerLevel(lvl : InnerLevel) : Void {
		if(lvl.parentLevel != this) {
			trace("Inner level not added b/c its parent is not this level.");
			return;
		}

		mInnerLevels.add(lvl);
		mGraphics.add(lvl.getLevelGraphics());
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
			var jsonobj = haxe.Json.parse(contents);
			constructLevel(jsonobj);
		} catch(ex : Dynamic) {
			trace("** error: Parsing level json string failed: " + ex);
		}
	}

	private function constructLevel(jsonobj : Dynamic) {
		mLevelJson = jsonobj;

		prepareBackground(mLevelJson.background);

		try {
			var boundaries : Array<Dynamic> = mLevelJson.boundaries;
			var platforms : Array<Dynamic> = mLevelJson.platforms;
			var nutcoins : Array<Dynamic> = mLevelJson.nutcoins;
			var innerlvls : Array<Dynamic> = mLevelJson.innerlevels;
			var gates : Array<Dynamic> = mLevelJson.gates;

			for(dyn in boundaries) {
				addBoundary(Boundary.fromJson(dyn));
			}

			for(dyn in platforms) {
				addPlatformSprite(PlatformSprite.fromJson(dyn));
			}

			for(dyn in nutcoins) {
				addNutCoin(CollectibleSprite.fromJson(dyn));
			}

			for(dyn in innerlvls) {
				var lvl : InnerLevel = new InnerLevel(this, null);
				lvl.constructLevel(dyn);
				addInnerLevel(lvl);
			}

			for(dyn in gates) {
				var lvl1 : Level = resolveLevelId(dyn.level1_id);
				var lvl2 : Level = resolveLevelId(dyn.level2_id);

				if(lvl1 == null || lvl2 == null) {
					trace(
						"error loading gate: could not find: " +
						(lvl1 == null ? dyn.level1_id : "") + " " +
						(lvl2 == null ? dyn.level2_id : "")
					);
				} else {
					addCrossLevelGate(new CrossLevelGate(dyn.x, dyn.y, lvl1, lvl2));
				}
			}

			findConnectedBoundarySegments();

			for(gate in mCrossLevelGates) {
				gate.determineOverlappingSurfaceBoundaries();
			}

			if(mLevelJson.startpt != null) {
				setStartPoint(mLevelJson.startpt[0], mLevelJson.startpt[1]);
			}
		} catch(ex : Dynamic) {
			trace("construct failed:" + ex);
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

	public function setVisible(visible : Bool) : Void {

	}

	public function applyChanges() : Void {
		var gates : Array<Dynamic> = new Array();
		var boundaries : Array<Dynamic> = new Array();
		var platforms : Array<Dynamic> = new Array();
		var nutcoins : Array<Dynamic> = new Array();
		var innerlvls : Array<Dynamic> = new Array();
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

		for(gate in mCrossLevelGates) {
			gates.push(gate.toJson());
		}

		for(innerlvl in mInnerLevels) {
			innerlvl.applyChanges();
			innerlvls.push(innerlvl.mLevelJson);
		}

		mLevelJson.id = getId();
		mLevelJson.gates = gates;
		mLevelJson.nutcoins = nutcoins;
		mLevelJson.boundaries = boundaries;
		mLevelJson.platforms = platforms;
		mLevelJson.innerlevels = innerlvls;
		
		if(mStartPoint != null) 
			mLevelJson.startpt = [mStartPoint.x, mStartPoint.y];
	}

	public function save() : Void {
		if(mFilename == null) return;

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

	public function resolveLevelId(id : String) : Level {
		if(getId() == id) return this;
		for(lvl in mInnerLevels) {
			if(lvl.getId() == id) return lvl;
		}
		return null;
	}

	public function checkCrossLevelGateEntry(player : Player) : CrossLevelGate {
		var gaterect : FlxRect = new FlxRect(0, 0, CrossLevelGate.WIDTH, CrossLevelGate.HEIGHT);
		var plyrrect : FlxRect = new FlxRect(player.x, player.y, Player.WIDTH, Player.HEIGHT);

		for(g in mCrossLevelGates) {
			gaterect.x = g.position.x;
			gaterect.y = g.position.y;

			//trace("player: " + plyrrect.x + "," + plyrrect.y + "," + plyrrect.width +","+plyrrect.height);
			//trace("gate: " + gaterect.x + "," + gaterect.y + "," + gaterect.width +","+gaterect.height);

			if(Utility.isRectInRect(plyrrect, gaterect)) return g;
		}

		return null;
	}

	public function checkSurfaceCollision(trajectory : Line) : IntersectionCheckResult {
		var checkedCount : Int = 0;
		var intersectionPoint : FlxPoint = null;
		var topmostIntersectionPoint : FlxPoint = null;
		var intersectionBoundary : Boundary = null;

		// maybe do like a BSP tree
		for(boundary in mBoundariesGlobal) {
			var s : Line = boundary.surface;

			// todo: take connected segments into account
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
