
package ;

import org.flixel.util.FlxPoint;

class CrossLevelGate {
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
		return lvl == mLevel1 || lvl == mLevel2;
	}
}