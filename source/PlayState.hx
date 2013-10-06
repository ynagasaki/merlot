package ;

import openfl.Assets;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.util.FlxMath;
import org.flixel.util.FlxPoint;
import org.flixel.FlxObject;
import haxe.io.Input;

class PlayState extends FlxState
{
	var mPlayer : Player = null;
	var mLevel : Level = null;
	var mInitializedFromEditor : Bool = false;

	public function new(initedByEditor : Bool) {
		mInitializedFromEditor = initedByEditor;
		super();
	}

	override public function create():Void
	{
		// Set a background color
		FlxG.bgColor = 0xFFFF00FF;

		mLevel = new Level("assets/lvls/level-template.json");

		add(mLevel.getLevelGraphics());

		var startpt : FlxPoint = mLevel.getStartPoint();

		mPlayer = new Player(startpt.x, startpt.y);

		add(mPlayer);

		FlxG.camera.setBounds(0, 0, mLevel.getWidth(), mLevel.getHeight(), true);
		
		FlxG.camera.follow(mPlayer, org.flixel.FlxCamera.STYLE_PLATFORMER);

		mPlayer.setDebug(true, this);
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		var oldy : Float = mPlayer.y;
		var distanceleft : Float = 0;
		var intersectingBoundary : Boundary = null;

		// if the player is falling, check for platforms below
		if(!mPlayer.isOnGround() && mPlayer.isFalling()) {
			var result : IntersectionCheckResult = mLevel.checkSurfaceCollision(
				new Line(mPlayer.x, mPlayer.y + mPlayer.offset.y, mPlayer.x, mLevel.getHeight())
			);

			if(result.intersectionPoint != null) {
				distanceleft = result.intersectionPoint.y - mPlayer.y - mPlayer.offset.y;
				intersectingBoundary = result.intersectingBoundary;
			}
		}
		
		super.update();

		// if there is a platform below, and the y-distance traveled in this frame exceeds
		// the y-distance that was left before the height was updated...
		var distancetraveled : Float = (mPlayer.y - oldy);
		if(intersectingBoundary != null && distanceleft - distancetraveled < 0.005) { //(include a little give)
			// ... then plop the player on the ground.
			mPlayer.y = oldy + distanceleft;
			mPlayer.velocity.y = mPlayer.acceleration.y = 0;
			mPlayer.setSurfaceBoundary(intersectingBoundary);
		}

		if(FlxG.keys.justPressed("ESCAPE") && mInitializedFromEditor) {
			FlxG.switchState(new EditorState());
		}
	}
}
