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
	public var oldX : Float = 0;
	public var checkIntersection : Bool = false;

	public function new() : Void {
	}

	public function reset() : Void {
		oldX = oldY = 0;
		checkIntersection = false;
	}
}

class PlayState extends FlxState {
	public static inline var CHAR_FRAME_INFO_KEY : String = "ExtraData:PlayState:CharacterFrameInfo";

	var mPlayer : Player = null;
	var mActiveLevel : Level = null;
	var mNutCoinGroup : FlxGroup = null;
	var mCharacters : List<Character> = null;

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

		// set start point
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

		for(lvl in mActiveLevel.getInnerLevels()) {
			lvl.setVisible(false);
		}

		mNutCoinGroup = new FlxGroup();
		prepareActiveLevelNutCoinGroup();

		mCharacters = new List();
		prepareActiveLevelCharacters();
	}

	override public function destroy() : Void {
		super.destroy();
	}

	private function nutCoinCallback(player : Dynamic, coin : Dynamic) : Void {
		cast(coin, CollectibleSprite).kill();
	}

	override public function update() : Void {
		for(character in mCharacters) {
			var charframeinfo : CharacterFrameInfo = character.extraData.get(CHAR_FRAME_INFO_KEY);

			charframeinfo.reset();

			if(charframeinfo.checkIntersection = !character.isOnGround() && character.isFalling()) {
				charframeinfo.oldX = character.x + (character.width / 2);
				charframeinfo.oldY = character.y + character.height;
			}
		}

		FlxG.overlap(mPlayer, mNutCoinGroup, nutCoinCallback);

		super.update();

		for(character in mCharacters) {
			var charframeinfo : CharacterFrameInfo = character.extraData.get(CHAR_FRAME_INFO_KEY);

			if(charframeinfo.checkIntersection) {
				var feetx : Float = character.x + (character.width / 2);
				var feety : Float = character.y + character.height;

				var result : IntersectionCheckResult = mActiveLevel.checkSurfaceCollision(
					new Line(charframeinfo.oldX, charframeinfo.oldY, feetx, feety)
				);

				if(result.intersectionPoint != null) {
					character.x = result.intersectionPoint.x - (character.width / 2);
					character.y = result.intersectionPoint.y - character.height;
					if(character.isFalling()) {
						character.acceleration.y = 0;
						character.setSurfaceBoundary(result.intersectingBoundary);
					}
					character.velocity.y = 0;
				}
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
		
		mNutCoinGroup.clear();

		for(nutcoin in nutcoins) {
			if(nutcoin.alive)
				mNutCoinGroup.add(nutcoin);
		}
	}

	private function prepareActiveLevelCharacters() : Void {
		mCharacters.clear();

		var npcs : List<NonPlayable> = mActiveLevel.getNonPlayables();
		for(npc in npcs) {
			if(npc.alive)
				mCharacters.add(npc);
		}

		mCharacters.add(mPlayer);

		for(character in mCharacters) {
			if(character.extraData.get(CHAR_FRAME_INFO_KEY) == null) {
				character.extraData.set(CHAR_FRAME_INFO_KEY, new CharacterFrameInfo());
			}
		}
	}

	private function switchLevel(gate : CrossLevelGate, target : Level) : Void {
		mActiveLevel.setVisible(false);
		target.setVisible(true);
		mActiveLevel = target;

		prepareActiveLevelNutCoinGroup();
		prepareActiveLevelCharacters();

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
