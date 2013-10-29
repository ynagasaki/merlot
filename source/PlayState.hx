package ;

import editor.EditorState;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.util.FlxPoint;
import org.flixel.FlxGroup;
import haxe.io.Input;

class PlayState extends FlxState {
	public static inline var FALL_PROBE_LENGTH : Float = 5000;

	var mPlayer : Player = null;
	var mActiveLevel : Level = null;
	var mNutCoinGroup : FlxGroup = null;
	var mInitializedFromEditor : Bool = false;

	public function new(initedByEditor : Bool) {
		mInitializedFromEditor = initedByEditor;
		super();
	}

	override public function create():Void
	{
		// Set a background color
		FlxG.bgColor = 0xFFFF00FF;

		mActiveLevel = new Level("assets/lvls/level-template.json");

		add(mActiveLevel.getLevelGraphics());

		mNutCoinGroup = new FlxGroup();
		prepareActiveLevelNutCoinGroup();

		var startpt : FlxPoint = mActiveLevel.getStartPoint();
		if(startpt != null) {
			mPlayer = new Player(startpt.x, startpt.y);
		} else {
			mPlayer = new Player(0, 0);
		}

		add(mPlayer);

		FlxG.camera.setBounds(0, 0, mActiveLevel.getWidth(), mActiveLevel.getHeight(), true);
		
		FlxG.camera.follow(mPlayer, org.flixel.FlxCamera.STYLE_PLATFORMER);

		//mPlayer.setDebug(true, this);

		//add(new NonPlayable("assets/baddies/b1.png",mPlayer.x + 100, mPlayer.y, 23, 23));

		for(lvl in mActiveLevel.getInnerLevels()) {
			lvl.setVisible(false);
		}
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	private function nutCoinCallback(player : Dynamic, coin : Dynamic) : Void {
		cast(coin, CollectibleSprite).kill();
	}

	override public function update():Void
	{
		var oldy : Float = mPlayer.y;
		var distanceleft : Float = 0;
		var intersectingBoundary : Boundary = null;

		// if the player is falling, check for platforms below
		if(!mPlayer.isOnGround() && mPlayer.isFalling()) {
			var feetx : Float = mPlayer.x + Player.WIDTH_HALF;
			var feety : Float = mPlayer.y + Player.HEIGHT;
			var result : IntersectionCheckResult = mActiveLevel.checkSurfaceCollision(
				new Line(feetx, feety, feetx, FALL_PROBE_LENGTH) // this could be lvl.y + lvl.height
			);

			if(result.intersectionPoint != null) {
				distanceleft = result.intersectionPoint.y - mPlayer.y - mPlayer.height;
				intersectingBoundary = result.intersectingBoundary;
			}
		}

		FlxG.overlap(mPlayer, mNutCoinGroup, nutCoinCallback);

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

		if(FlxG.keys.justPressed("UP")) {
			var gate : CrossLevelGate = mActiveLevel.checkCrossLevelGateEntry(mPlayer);
			if(gate != null) {
				switchLevel(gate, gate.getDestinationLevelRelativeTo(mActiveLevel));
			}
		}
	}

	private function prepareActiveLevelNutCoinGroup() : Void {
		var nutcoins : List<CollectibleSprite> = mActiveLevel.getNutCoins();
		for(nutcoin in nutcoins) {
			if(nutcoin.alive)
				mNutCoinGroup.add(nutcoin);
		}
	}

	private function switchLevel(gate : CrossLevelGate, target : Level) : Void {
		mActiveLevel.setVisible(false);
		target.setVisible(true);
		mActiveLevel = target;
		mNutCoinGroup.clear();
		prepareActiveLevelNutCoinGroup();

		var otherLevelRelevantSurfaceBoundaries : List<Boundary> = gate.getLinkedBoundaries(target);
		if(otherLevelRelevantSurfaceBoundaries.length > 0) {
			for(b in otherLevelRelevantSurfaceBoundaries) {
				if(mPlayer.x >= b.surface.leftmostPoint.x && mPlayer.x <= b.surface.rightmostPoint.x) {
					mPlayer.setSurfaceBoundary(b);
					break;
				}
			}
		} else {
			mPlayer.startNotBeingOnTheGround();
		}
	}
}
