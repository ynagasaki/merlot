
import sys.io.File;
import org.flixel.FlxSprite;

class Level {
	var mBackground : FlxSprite = null;
	var mLinesList : List<Line> = null;
	var mLevelJson : Dynamic = null;

	public function new() {
		mLinesList = new List();
	}

	public function loadLevel(levelfile : String) : Void {
		var contents :  String = null;

		try {
			contents = File.getContent(levelfile);
		} catch(ex : Dynamic) {
			trace("** error: File probably not found: " + ex);
		}

		try {
			mLevelJson = haxe.Json.parse(contents);
		} catch(ex : Dynamic) {
			trace("** error: Parsing level json string failed: " + ex);
		}

		mBackground = new FlxSprite(0, 0);

		trace(mLevelJson.background);

		mBackground.loadGraphic(
			mLevelJson.background, 
			false, 
			false, 
			mLevelJson.width,
			mLevelJson.height,
			true
		);
	}

	public function getLevelSprite() : FlxSprite {
		return mBackground;
	}

	public function addLine(line : Line) : Void {
		mLinesList.add(line);
		mBackground.drawLine(line.p1.x, line.p1.y, line.p2.x, line.p2.y, 1, 1);
	}

	public function save() : Void {
		mLevelJson.lines = [[0,0,0,0]];
		trace(haxe.Json.stringify(mLevelJson));
	}
}