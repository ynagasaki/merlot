package ;

import haxe.Json;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.util.FlxPoint;

enum EditorCommand {
	EnterLineMode;
	MakePlatform;
	SaveLevel;
}

enum EditorMode {
	LineMode;
}

class EditorState extends FlxState {

	var mFirstPoint : FlxPoint = null;
	var mLevel : Level = null;
	var mMenu : EditorMenu = null;

	var mCommand : EditorCommand = null;
	var mMode : EditorMode = null;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create() : Void {
		// Set a background color
		FlxG.bgColor = 0xFFFF00FF;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		mLevel = new Level("assets/level-01.json");

		add(mLevel.getLevelSprite());

		FlxG.camera.setBounds(0, 0, mLevel.getWidth(), mLevel.getHeight(), true);

		mMenu = new EditorMenu(this);

		add(mMenu);

		super.create();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy() : Void {
		super.destroy();
	}

	override public function update() : Void {
		if(mMode == EditorMode.LineMode) {
			figOutMouseDrawingLinesCrap();
		}

		if(FlxG.keys.pressed("CONTROL")) {
			FlxG.camera.focusOn(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
		}

		if(FlxG.keys.pressed("ESCAPE")) {
			if(mMode != null) {
				trace("Exiting " + mMode);
				mMode = null;
				mMenu.hide(false);
			}
		}

		if(mMode == null) {
			if(FlxG.keys.justPressed("ENTER") && FlxG.keys.pressed("SHIFT")) {
				FlxG.switchState(new PlayState(true));
			}

			if(mCommand == EditorCommand.EnterLineMode) {
				mMode = EditorMode.LineMode;
			}

			mCommand = null;
		}

		super.update();
	}

	private function figOutMouseDrawingLinesCrap() : Void {
		if(FlxG.mouse.justReleased()) {
			if(mFirstPoint == null) {
				mFirstPoint = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
				trace("assign next point");
			} else {
				var boundary : Boundary = new Boundary();
				
				boundary.surface = new Line(mFirstPoint.x, mFirstPoint.y, FlxG.mouse.x, FlxG.mouse.y);
				boundary.normal = calculateNormal(boundary.surface);

				mLevel.addBoundary(boundary);

				mFirstPoint = null;
				trace("added boundary: " + boundary.surface);
			}
		}
	}

	private function calculateNormal(line : Line) : Line {
		var v1 = new Vector3(line.p2.x - line.p1.x, line.p2.y - line.p1.y, 0);
		var n = Vector3.cross(v1, new Vector3(0, 0, 1));
		return new Line(line.p1.x, line.p1.y, line.p1.x + n.x, line.p1.y + n.y);
	}

	public function startLineMode() {
		mCommand = EditorCommand.EnterLineMode;
		mMenu.hide(true);
		trace("Started line mode: press escape when finished.");
	}

	public function saveLevel() {
		try {
			mLevel.save();
			trace("Successfully saved level.");
		} catch(ex : Dynamic) {
			trace("saveLevel: " + ex);
		}
	}
}