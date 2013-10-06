package ;

import haxe.Json;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.util.FlxPoint;

enum EditorCommand {
	LineMode;
	MakePlatform;
	SaveLevel;
}

class EditorState extends FlxState {
	var mFirstPoint : FlxPoint = null;
	var mLevel : Level = null;
	var mMenu : EditorMenu = null;
	
	var mMenuActionIssued : Bool = false;
	var mCommand : EditorCommand = null;

	var mStartPoint : FlxSprite = null;
	var mSelectedPlatform : PlatformSprite = null;
	var mLastMousePos : FlxPoint = null;
	var mLastBoundary : Boundary = null;

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

		mLevel = new Level("assets/lvls/level-template.json", true);

		add(mLevel.getLevelGraphics());

		FlxG.camera.setBounds(0, 0, mLevel.getWidth(), mLevel.getHeight(), true);

		mMenu = new EditorMenu(this);

		mLastMousePos = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);

		var startpt : FlxPoint = mLevel.getStartPoint();
		if(startpt != null) {
			mStartPoint = new FlxSprite(startpt.x, startpt.y).makeGraphic(5,5,0xFF00FF00);
			add(mStartPoint);
		}

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
		if(!mMenuActionIssued) {
			if(mCommand == EditorCommand.LineMode) {
				// Editor is in special line drawing mode
				figOutMouseDrawingLinesCrap(mSelectedPlatform);

				if(FlxG.keys.pressed("ESCAPE")) {
					trace("Exiting " + mCommand);
					mCommand = null;
					mFirstPoint = null;
					mMenu.hide(false);
				}
			}

			if(mCommand == null) {
				// Editor is in normal mode
				if(FlxG.mouse.justReleased()) {
					selectPlatformSprite(mLevel.pickPlatformSprite(FlxG.mouse.x, FlxG.mouse.y));

					if(FlxG.keys.pressed("S")) {
						mLevel.setStartPoint(FlxG.mouse.x, FlxG.mouse.y);
						mStartPoint.x = FlxG.mouse.x;
						mStartPoint.y = FlxG.mouse.y;
					}
				}

				if(FlxG.mouse.pressed() && mSelectedPlatform != null) {
					var offsetx : Float = mLastMousePos.x - mSelectedPlatform.x;
					var offsety : Float = mLastMousePos.y - mSelectedPlatform.y;

					mSelectedPlatform.move(FlxG.mouse.x - offsetx, FlxG.mouse.y - offsety);
				}

				if(FlxG.keys.justReleased("DELETE") && mSelectedPlatform != null) {
					mLevel.removePlatformSprite(mSelectedPlatform);
					selectPlatformSprite(null);
				}

				if(FlxG.keys.pressed("CONTROL")) {
					FlxG.camera.focusOn(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
				}

				if(FlxG.keys.justReleased("ENTER") && FlxG.keys.pressed("SHIFT")) {
					FlxG.switchState(new PlayState(true));
				}
			}
		} else {
			mMenuActionIssued = false;
		}

		super.update();

		mLastMousePos.x = FlxG.mouse.x;
		mLastMousePos.y = FlxG.mouse.y;
	}

	private function figOutMouseDrawingLinesCrap(sprite : PlatformSprite) : Void {
		if(FlxG.mouse.justReleased()) {
			if(mFirstPoint == null) {
				mFirstPoint = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
				trace("assign next point");
			} else {
				var boundary : Boundary = new Boundary();
				
				boundary.surface = new Line(mFirstPoint.x, mFirstPoint.y, FlxG.mouse.x, FlxG.mouse.y);
				boundary.normal = calculateNormal(boundary.surface);

				if(mSelectedPlatform == null) {
					mLevel.addBoundary(boundary, true);
				} else {
					mSelectedPlatform.addBoundary(boundary, true);
				}

				mFirstPoint = null;
				trace("added boundary: " + boundary.surface);

				// do "chaining"
				if(FlxG.keys.pressed("C")) {
					if(mLastBoundary != null) {
						// "next" and "prev" only make sense for LTR segments
						mLastBoundary.next = boundary;
						boundary.prev = mLastBoundary;
					}

					mLastBoundary = boundary;
					mFirstPoint = new FlxPoint(boundary.surface.p2.x, boundary.surface.p2.y);

					trace("   +chaining: next line pt 1 set: " + mFirstPoint.x + ", " + mFirstPoint.y);
				}
			}
		}
	}

	private function calculateNormal(line : Line) : Line {
		var v1 = new Vector3(line.p2.x - line.p1.x, line.p2.y - line.p1.y, 0);
		var n = Vector3.cross(v1, new Vector3(0, 0, 1));
		return new Line(line.p1.x, line.p1.y, line.p1.x + n.x, line.p1.y + n.y);
	}

	public function startLineMode() : Void {
		mMenuActionIssued = true;
		mCommand = EditorCommand.LineMode;
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

	public function selectPlatformSprite(sprite : PlatformSprite) : Void {
		if(sprite != mSelectedPlatform && mSelectedPlatform != null) mSelectedPlatform.color = 0xFFFFFFFF;
		mSelectedPlatform = sprite;
		if(mSelectedPlatform != null) mSelectedPlatform.color = 0xFF7777FF;
	}

	public function createPlatformSprite(filename : String) : Void {
		var sprite : PlatformSprite = new PlatformSprite(filename);

		sprite.move(50, 200);

		mLevel.addPlatformSprite(sprite);
	}
}