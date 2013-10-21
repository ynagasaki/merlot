
package ;

import org.flixel.util.FlxPoint;

class CrossLevelGate {
	public static inline var WIDTH : Float = Player.WIDTH + 10;
	public static inline var HEIGHT : Float = Player.HEIGHT + 10;
	public static inline var WIDTH_HALF : Float = WIDTH / 2;
	public static inline var HEIGHT_HALF : Float = HEIGHT / 2;

	public var position : FlxPoint = null;

	var mLevel1 : Level = null;
	var mLevel2 : Level = null;

	public function new(x : Float, y : Float, lvl1 : Level, lvl2 : Level) {
		position = new FlxPoint(x, y);
		mLevel1 = lvl1;
		mLevel2 = lvl2;
	}

	public function getDestinationLevelRelativeTo(me : Level) : Level {
		return (me == mLevel1) ? mLevel2 : mLevel1; 
	}

	public function isRelevantTo(lvl : Level) : Bool {
		return (lvl == mLevel1 || lvl == mLevel2);
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