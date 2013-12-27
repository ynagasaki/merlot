
package ;

import flixel.util.FlxPoint;

class CrossLevelGate {
	public static inline var WIDTH : Float = Player.WIDTH + 10;
	public static inline var HEIGHT : Float = Player.HEIGHT + 10;
	public static inline var WIDTH_HALF : Float = WIDTH / 2;
	public static inline var HEIGHT_HALF : Float = HEIGHT / 2;

	public var position : FlxPoint = null;

	var mLevel1 : Level = null;
	var mLevel2 : Level = null;

	var mLinkedBoundariesLevel1 : List<Boundary> = null;
	var mLinkedBoundariesLevel2 : List<Boundary> = null;

	public function new(x : Float, y : Float, lvl1 : Level, lvl2 : Level) {
		position = new FlxPoint(x, y);
		mLevel1 = lvl1;
		mLevel2 = lvl2;
		mLinkedBoundariesLevel1 = new List();
		mLinkedBoundariesLevel2 = new List();
	}

	public function addLinkedBoundaryToLevel(lvl : Level, boundary : Boundary) : Void {
		if(lvl == mLevel1) mLinkedBoundariesLevel1.add(boundary);
		else if(lvl == mLevel2) mLinkedBoundariesLevel2.add(boundary);
		else trace("* add: warning: level (" + lvl.getId() + ") is not part of this gate.");
	}

	public function getLinkedBoundaries(lvl : Level) : List<Boundary> {
		if(lvl == mLevel1) return mLinkedBoundariesLevel1;
		else if(lvl == mLevel2) return mLinkedBoundariesLevel2;
		else trace("* get: warning: level (" + lvl.getId() + ") is not part of this gate.");
		return null;
	}

	public function getDestinationLevelRelativeTo(me : Level) : Level {
		return (me == mLevel1) ? mLevel2 : mLevel1; 
	}

	public function isRelevantTo(lvl : Level) : Bool {
		return (lvl == mLevel1 || lvl == mLevel2);
	}

	public function determineOverlappingSurfaceBoundaries() : Void {
		var p2 : FlxPoint = new FlxPoint(position.x + WIDTH, position.y + HEIGHT);
		var p3 : FlxPoint = new FlxPoint(0, 0);
		var p4 : FlxPoint = new FlxPoint(0, 0);

		for(b in mLevel1.getGlobalBoundariesList()) {
			p3.x = b.surface.leftmostPoint.x;
			p3.y = b.surface.topmostPoint.y;
			p4.x = b.surface.rightmostPoint.x;
			p4.y = b.surface.bottommostPoint.y;

			if(Utility.overlaps(position, p2, p3, p4)) {
				addLinkedBoundaryToLevel(mLevel1, b);
			}
		}

		for(b in mLevel2.getGlobalBoundariesList()) {
			p3.x = b.surface.leftmostPoint.x;
			p3.y = b.surface.topmostPoint.y;
			p4.x = b.surface.rightmostPoint.x;
			p4.y = b.surface.bottommostPoint.y;

			if(Utility.overlaps(position, p2, p3, p4)) {
				addLinkedBoundaryToLevel(mLevel2, b);
			}
		}
	}

	public function toJson() : Dynamic {
		return {
			x: position.x, 
			y: position.y, 
			level1_id: mLevel1.getId(), 
			level2_id: mLevel2.getId()
		};
	}
}