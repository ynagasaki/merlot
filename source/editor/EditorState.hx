package editor;

import haxe.Json;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxBasic;
import org.flixel.FlxButton;
import org.flixel.util.FlxPoint;
import org.flixel.FlxText;

class EditorState extends FlxState {
	var mFirstPoint : FlxPoint = null;
	var mLevel : Level = null;
	var mMenu : EditorMenu = null;
	
	var mMenuActionIssued : Bool = false;
	var mCommand : EditorCommand = null;
	var mInnerCommand : EditorCommand = null;
	var mStatus : FlxText = null;

	var mSelectedItem : SelectableItem = null;
	var mStartPoint : FlxSprite = null;
	var mLastMousePos : FlxPoint = null;
	var mLastBoundary : Boundary = null;
	var mActiveInnerLevel : InnerLevel = null;

	var mBoundarySprites : List<BoundarySprite> = null;
	var mGateSprites : List<CrossLevelGateSprite> = null;

	override public function create() : Void {
		// Set a background color
		FlxG.bgColor = 0xFFFF00FF;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		mLevel = new Level("assets/lvls/level-template.json");

		add(mLevel.getLevelGraphics());

		mGateSprites = new List();
		for(g in mLevel.getCrossLevelGates()) {
			addGateSprite(g);
		}

		mBoundarySprites = new List();
		for(b in mLevel.getGlobalBoundariesList()) {
			addBoundarySprite(b);
		}

		FlxG.camera.setBounds(0, 0, mLevel.getWidth(), mLevel.getHeight(), true);

		mMenu = new EditorMenu(this);

		mLastMousePos = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);

		var startpt : FlxPoint = mLevel.getStartPoint();
		if(startpt != null) {
			mStartPoint = new FlxSprite(startpt.x, startpt.y).makeGraphic(Player.WIDTH, Player.HEIGHT, 0xFF00FF00);
			add(mStartPoint);
		}

		add(mMenu);

		mStatus = new FlxText(2, FlxG.height - 20, FlxG.width);
		mStatus.shadow = 0xffffffff;
		mStatus.useShadow = true;
		mStatus.color = 0xff000000;
		mStatus.scrollFactor = new FlxPoint(0,0);
		setStatus("Super Merlot Editor 0.1.0");
		add(mStatus);

		super.create();
	}

	private function setactivecmd(cmd : EditorCommand) {
		if(mCommand == EditorCommand.InnerEditMode) mInnerCommand = cmd;
		else mCommand = cmd;
	}

	private function activecmd() : EditorCommand {
		return (mCommand == EditorCommand.InnerEditMode) ? mInnerCommand : mCommand;
	}

	private function activelvl() : Level {
		return (mActiveInnerLevel==null) ? mLevel : mActiveInnerLevel;
	}

	private function selectedItemIsNull() : Bool {
		return mSelectedItem == null || mSelectedItem.getItem() == null;
	}

	public function setStatus(txt : String) : Void {
		mStatus.text = txt;
	}

	override public function destroy() : Void {
		super.destroy();
	}

	override public function update() : Void {
		if(!mMenuActionIssued) {
			if(mCommand != null) {
				if(FlxG.keys.justPressed("ESCAPE")) {
					if(mCommand == EditorCommand.InnerEditMode && mInnerCommand != null) {
						setStatus("Exiting " + mInnerCommand);
						mInnerCommand = null;
					} else {
						setStatus("Exiting " + mCommand);
						mCommand = null;
						mActiveInnerLevel = null;
						enterInnerEditMode(false);
					}
					mFirstPoint = null;
					mMenu.hide(false);
				}
			}

			if(activecmd() == EditorCommand.LineMode) {
				performLineMode();
			} else if(activecmd() == EditorCommand.NutCoinMode) {
				placeNutCoins();
			} else if(activecmd() == EditorCommand.GateMode) {
				performGateMode();
			}

			if(activecmd() == null) {
				// Editor is in normal mode
				if(FlxG.mouse.justReleased()) {
					pickSelectableItem();
				}

				if(FlxG.mouse.pressed() && !selectedItemIsNull()) {
					var offsetx : Float = mLastMousePos.x - mSelectedItem.getX();
					var offsety : Float = mLastMousePos.y - mSelectedItem.getY();

					mSelectedItem.move(FlxG.mouse.x - offsetx, FlxG.mouse.y - offsety);
				}

				if(FlxG.keys.justReleased("ENTER") && FlxG.keys.pressed("SHIFT")) {
					FlxG.switchState(new PlayState(true));
				}
			}
		} else {
			mMenuActionIssued = false;
			if(mCommand == EditorCommand.InnerEditMode) {
				enterInnerEditMode(true);
			}
		}

		// Allow camera movement regardless of mode
		if(FlxG.keys.pressed("CONTROL")) {
			FlxG.camera.focusOn(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
		}
		// Allow selected sprite deletion regardless of mode
		if(FlxG.keys.justReleased("DELETE") && !selectedItemIsNull()) {
			deleteSelectedItem();
		}

		super.update();

		mLastMousePos.x = FlxG.mouse.x;
		mLastMousePos.y = FlxG.mouse.y;
	}

	private function enterInnerEditMode(entering : Bool) : Void {
		for(bspr in mBoundarySprites) {
			bspr.visible = !entering;
		}

		for(gspr in mGateSprites) {
			if(entering) {
				gspr.fill(0x55FF0000);
			} else {
				gspr.fill(0xFFFF0000);
			}
		}

		for(pspr in mLevel.getPlatformSprites()) {
			pspr.visible = !entering;
		}

		for(cspr in mLevel.getNutCoins()) {
			cspr.visible = !entering;
		}

		select(null);


		for(bs in mBoundarySprites) {
			remove(bs, true);
		}

		mBoundarySprites.clear();

		if(entering) {
			mMenu.displayInnerLevelMenu();

			for(b in mActiveInnerLevel.getGlobalBoundariesList()) {
				addBoundarySprite(b);
			}
		} else {
			mMenu.displayOuterLevelMenu();

			for(b in mLevel.getGlobalBoundariesList()) {
				addBoundarySprite(b);
			}
		}
	}

	private function deleteSelectedItem() : Void {
		if(mSelectedItem.isPlatformSprite()) {
			activelvl().removePlatformSprite(cast(mSelectedItem.getItem(), PlatformSprite));
		} else if(mSelectedItem.isCollectibleSprite()) {
			activelvl().removeNutCoin(cast(mSelectedItem.getItem(), CollectibleSprite));
		} else if(mSelectedItem.isBoundarySprite()) {
			var boundarysprite : BoundarySprite = cast(mSelectedItem.getItem(), BoundarySprite);
			if(boundarysprite.boundary.hasNext() || boundarysprite.boundary.hasPrev()) {
				setStatus("* Warning: boundary part of chain; SHIFT-DELETE to delete chain; not yet impl, lol.");
			} else {
				activelvl().removeBoundary(boundarysprite.boundary);
				mBoundarySprites.remove(boundarysprite);
				remove(mSelectedItem.getItem(), true);
			}
		}

		select(null);
	}

	private function pickSelectableItem() : Void {
		var x : Float = FlxG.mouse.x;
		var y : Float = FlxG.mouse.y;

		var item : SelectableItem = null;
		var plats : List<PlatformSprite> = activelvl().getPlatformSprites();
		var coins : List<CollectibleSprite> = activelvl().getNutCoins();
		var lvls : List<InnerLevel> = activelvl().getInnerLevels();

		// Because I suck, the order in which we check for picked items matters:
		// Generally speaking, it's smallest --> largest

		// check nut coins
		if(item == null) for(c in coins) {
			if(Utility.isPointInSpriteBounds(x, y, c)) {
				item = new SelectableSpriteWrapper(c);
				break;
			}
		}

		// check start pt
		if(item == null && Utility.isPointInSpriteBounds(x, y, mStartPoint)) {
			item = new SelectableSpriteWrapper(mStartPoint);
		}

		// check cross gates
		if(item == null) for(g in mGateSprites) {
			if(Utility.isPointInSpriteBounds(x, y, g)) {
				item = g;
				break;
			}
		}

		// check inner levels
		if(item == null) for(l in lvls) {
			if(x >= l.x && y >= l.y && x <= l.x + l.getWidth() && y <= l.y + l.getHeight()) {
				item = new SelectableLevelWrapper(l);
				break;
			}
		}

		// check plats
		if(item == null) for(p in plats) {
			if(Utility.isPointInSpriteBounds(x, y, p)) { 
				item = new SelectableSpriteWrapper(p);
				break; 
			}
		}

		select(item);
	}

	private function performGateMode() : Void {
		if(FlxG.mouse.justReleased()) {
			var gate : CrossLevelGate = new CrossLevelGate(FlxG.mouse.x, FlxG.mouse.y, mLevel, mActiveInnerLevel);
			mLevel.addCrossLevelGate(gate);
			addGateSprite(gate);
		}
	}

	private function placeNutCoins() : Void {
		if(FlxG.mouse.justReleased()) {
			activelvl().addNutCoin(new CollectibleSprite("assets/items/nut-coin.png", FlxG.mouse.x, FlxG.mouse.y));
		}
	}

	private function performLineMode() : Void {
		if(FlxG.mouse.justReleased()) {
			if(!FlxG.keys.pressed("SHIFT")) {
				var selected : BoundarySprite = null;
				for(bsprite in mBoundarySprites) {
					if(Utility.isPointInSpriteBounds(FlxG.mouse.x, FlxG.mouse.y, bsprite)) {
						selected = bsprite;
						break;
					}
				}
				select(selected);
				return;
			}

			if(mFirstPoint == null) {
				mFirstPoint = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
				setStatus("assign next point");
			} else {
				var message : String = "Added boundary";
				var boundary : Boundary = new Boundary();

				boundary.surface = new Line(mFirstPoint.x, mFirstPoint.y, FlxG.mouse.x, FlxG.mouse.y);
				boundary.normal = calculateNormal(boundary.surface);

				if(!selectedItemIsNull() && mSelectedItem.isPlatformSprite()) {
					cast(mSelectedItem.getItem(), PlatformSprite).addBoundary(boundary);
					message += " to platform";
				}

				activelvl().addBoundary(boundary);
				addBoundarySprite(boundary);
				//linespr.drawLine(boundary.normal.p1.x, boundary.normal.p1.y, boundary.normal.p2.x, boundary.normal.p2.y, FlxColor.RED, 1);

				mFirstPoint = null;

				// do "chaining"
				if(FlxG.keys.pressed("C")) {
					if(mLastBoundary != null) {
						// "next" and "prev" only make sense for LTR segments
						mLastBoundary.next = boundary;
						boundary.prev = mLastBoundary;
					}

					mLastBoundary = boundary;
					mFirstPoint = new FlxPoint(boundary.surface.p2.x, boundary.surface.p2.y);

					message += " with chaining: first pt: " + mFirstPoint.x + ", " + mFirstPoint.y;
				}

				setStatus(message);
			}
		}
	}

	private function addBoundarySprite(boundary : Boundary) : Void {
		var boundarysprite : BoundarySprite = new BoundarySprite(boundary);
		mBoundarySprites.add(boundarysprite);
		add(boundarysprite);
	}

	private function addGateSprite(gate : CrossLevelGate) : Void {
		var spr : CrossLevelGateSprite = new CrossLevelGateSprite(gate);
		mGateSprites.add(spr);
		add(spr);
	}

	private function calculateNormal(line : Line) : Line {
		var v1 = new Vector3(line.p2.x - line.p1.x, line.p2.y - line.p1.y, 0);
		var n = Vector3.cross(v1, new Vector3(0, 0, 1));
		return new Line(line.p1.x, line.p1.y, line.p1.x + n.x, line.p1.y + n.y);
	}

	public function startMode(button : FlxButton) : Void {
		var cmd : EditorCommand = EditorCommand.createByName(button.label.text);

		mMenuActionIssued = true;

		if(cmd.equals(EditorCommand.GateMode) || cmd.equals(EditorCommand.InnerEditMode)) {
			if(mSelectedItem == null || (Type.getClass(mSelectedItem) != SelectableLevelWrapper)) {
				setStatus("Must select an inner level to start " + cmd);
				return;
			} else {
				mActiveInnerLevel = cast(mSelectedItem, SelectableLevelWrapper).level;
			}
		}

		mMenu.hide(!cmd.equals(EditorCommand.InnerEditMode));
		setactivecmd(cmd);
		setStatus("Started " + cmd + ": press escape when finished.");
	}

	public function saveLevel() {
		try {
			if(mStartPoint != null) {
				mLevel.setStartPoint(mStartPoint.x, mStartPoint.y);
			}
			mLevel.applyChanges();
			mLevel.save();
			setStatus("Successfully saved level.");
		} catch(ex : Dynamic) {
			setStatus("Error saving level; check console.");
			trace("saveLevel error: " + ex);
		}
	}

	public function select(item : SelectableItem) : Void {
		var itemobj : FlxBasic = (item == null ? null : item.getItem());
		if(!selectedItemIsNull() && itemobj != mSelectedItem.getItem()) {
			mSelectedItem.deselect();
			if(mSelectedItem.isInnerLevel()) {
				mMenu.displayInnerLevelModeButton(false);
			} else if(mSelectedItem.isGateSprite()) {
				var gs : CrossLevelGateSprite = cast(mSelectedItem, CrossLevelGateSprite);
				gs.highlightRelatedBoundarySprites(activelvl(), mBoundarySprites, false);
			}
		}
		mSelectedItem = item;
		if(!selectedItemIsNull()) { 
			mSelectedItem.select();
			if(mSelectedItem.isInnerLevel()) {
				mMenu.displayInnerLevelModeButton(true);
			} else if(mSelectedItem.isGateSprite()) {
				var gs : CrossLevelGateSprite = cast(mSelectedItem, CrossLevelGateSprite);
				gs.highlightRelatedBoundarySprites(activelvl(), mBoundarySprites, true);
			}
		}
	}

	public function createPlatformSprite(filename : String) : Void {
		var sprite : PlatformSprite = new PlatformSprite(filename);
		sprite.move(50, 200);
		activelvl().addPlatformSprite(sprite);
	}

	public function createInnerLevel(filename : String) : Void {
		var level : InnerLevel = new InnerLevel(mLevel, filename);
		level.setPosition(50, 200);
		mLevel.addInnerLevel(level);
	}
}
