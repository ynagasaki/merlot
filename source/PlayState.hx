package ;

import editor.EditorState;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.util.FlxPoint;
import org.flixel.FlxGroup;
import haxe.io.Input;

class CharacterFrameInfo {
	public var oldY : Float = 0;
	public var distanceLeft : Float = 0;
	public var intersectingBoundary : Boundary = null;

	public function new() : Void {
	}

	public function reset() : Void {
		oldY = 0;
		distanceLeft = 0;
		intersectingBoundary = null;
	}
}

class PlayState extends FlxState {
	public static inline var FALL_PROBE_LENGTH : Float = 5000;

	var mPlayer : Player = null;
	var mActiveLevel : Level = null;
	var mNutCoinGroup : FlxGroup = null;
	var mCharacters : List<Character> = null;
	var mCharacterFrameInfoMap : Map<Character, CharacterFrameInfo> = null;

	var mInitializedFromEditor : Bool = false;

	public function new(initedByEditor : Bool) {
		mInitializedFromEditor = initedByEditor;
		super();
	}

	override public function create() : Void {
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

		FlxG.camera.setBounds(0, 0, mActiveLevel.getWidth(), mActiveLevel.getHeight(), true);
		
		FlxG.camera.follow(mPlayer, org.flixel.FlxCamera.STYLE_PLATFORMER);

		//mPlayer.setDebug(true, this);

		for(lvl in mActiveLevel.getInnerLevels()) {
			lvl.setVisible(false);
		}

		mCharacters = new List();
		mCharacters.add(mPlayer);
		mCharacters.add(new NonPlayable("assets/baddies/b1.png",mPlayer.x + 100, mPlayer.y, 23, 23));

		mCharacterFrameInfoMap = new Map();
		for(character in mCharacters) {
			add(character);
			mCharacterFrameInfoMap.set(character, new CharacterFrameInfo());
		}
	}

	override public function destroy() : Void {
		super.destroy();
	}

	private function nutCoinCallback(player : Dynamic, coin : Dynamic) : Void {
		cast(coin, CollectibleSprite).kill();
	}

	override public function update() : Void {
		for(character in mCharacters) {
			var charframeinfo : CharacterFrameInfo = mCharacterFrameInfoMap[character];

			charframeinfo.reset();
			charframeinfo.oldY = character.y;

			// if the character is falling, check for platforms below
			if(!character.isOnGround() && character.isFalling()) {
				var feetx : Float = character.x + (character.width / 2);
				var feety : Float = character.y + character.height;
				var result : IntersectionCheckResult = mActiveLevel.checkSurfaceCollision(
					new Line(feetx, feety, feetx, FALL_PROBE_LENGTH) // this could be lvl.y + lvl.height
				);

				if(result.intersectionPoint != null) {
					charframeinfo.distanceLeft = result.intersectionPoint.y - character.y - character.height;
					charframeinfo.intersectingBoundary = result.intersectingBoundary;
				}
			}
		}

		FlxG.overlap(mPlayer, mNutCoinGroup, nutCoinCallback);

		super.update();

		for(character in mCharacters) {
			var charframeinfo : CharacterFrameInfo = mCharacterFrameInfoMap[character];

			// if there is a platform below, and the y-distance traveled in this frame exceeds
			// the y-distance that was left before the height was updated...
			var distancetraveled : Float = character.y - charframeinfo.oldY;
			if(charframeinfo.intersectingBoundary != null && charframeinfo.distanceLeft - distancetraveled < 0.005) { //(include a little give)
				// ... then plop the player on the ground.
				character.y = charframeinfo.oldY + charframeinfo.distanceLeft;
				character.velocity.y = character.acceleration.y = 0;
				character.setSurfaceBoundary(charframeinfo.intersectingBoundary);
			}
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
