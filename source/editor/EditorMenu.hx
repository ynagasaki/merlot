package editor;

import org.flixel.FlxG;
import org.flixel.util.FlxPoint;
import org.flixel.FlxGroup;
import org.flixel.FlxButton;

class EditorButton extends FlxButton {
	var mCallback : (FlxButton -> Void) = null;

	public function new(x : Int, y : Int, label : String, callback : (FlxButton -> Void)) {
		super(x, y, label, clickCallback);
		mCallback = callback;
	}

	public function clickCallback() : Void {
		if(mCallback != null) mCallback(this);
	}
}

class EditorMenu extends FlxGroup {
	var mFileSelectorOpener : FlxButton = null;
	var mInnerEditButton : EditorButton = null;
	var mInnerLevelButton : EditorButton = null;
	var mEditorStateHandle : EditorState = null;

	var mDirStack : Array<String> = null;
	var mCurrentDirButts : Array<FlxButton> = null;
	var mOuterLevelMenu : Array<FlxButton> = null;
	var mInnerLevelMenu : Array<FlxButton> = null;
	var mActiveLevelMenu : Array<FlxButton> = null;

	public function new(editorHandle : EditorState) {
		super();

		mDirStack = new Array();
		mEditorStateHandle = editorHandle;

		mInnerLevelButton = new EditorButton(0, 0, "InnerLvl", openFileSelector);
		mInnerEditButton = new EditorButton(0, 0, EditorCommand.InnerEditMode.getName(), editorHandle.startMode);

		mOuterLevelMenu = [
			new EditorButton(5, 5, EditorCommand.LineMode.getName(), editorHandle.startMode),
			new EditorButton(0, 0, EditorCommand.NutCoinMode.getName(), editorHandle.startMode),
			new EditorButton(0, 0, "Platform", openFileSelector),
			mInnerLevelButton,
			new EditorButton(0, 0, EditorCommand.GateMode.getName(), editorHandle.startMode),
			new FlxButton(0,0,"SaveLvl", editorHandle.saveLevel)
		];

		mInnerLevelMenu = [
			mOuterLevelMenu[0],
			mOuterLevelMenu[1],
			mOuterLevelMenu[2]
		];

		mActiveLevelMenu = mOuterLevelMenu;

		layoutTheButts(mActiveLevelMenu);
	}

	public function displayInnerLevelMenu() : Void {
		removeButtons(mActiveLevelMenu);
		mActiveLevelMenu = mInnerLevelMenu;
		layoutTheButts(mActiveLevelMenu);
	}

	public function displayOuterLevelMenu() : Void {
		removeButtons(mActiveLevelMenu);
		mActiveLevelMenu = mOuterLevelMenu;
		layoutTheButts(mActiveLevelMenu);
	}

	public function displayInnerLevelModeButton(show : Bool) : Void {
		if(mActiveLevelMenu != mOuterLevelMenu) {
			trace("active menu is not outer menu. fixit foo.");
			return;
		}

		removeButtons(mActiveLevelMenu);
		mActiveLevelMenu[3] = (show) ? mInnerEditButton : mInnerLevelButton;
		layoutTheButts(mActiveLevelMenu);
	}

	public function addFixed(item : org.flixel.FlxObject) : Void {
		item.scrollFactor = new FlxPoint(0, 0);
		add(item);
	}

	public function hide(hide : Bool) : Void {
		for(i in 0...members.length) {
			members[i].visible = !hide;
		}
		mInnerLevelButton.visible = mInnerEditButton.visible = !hide;
	}

	private function layoutTheButts(butts : Array<FlxButton>, ?isdir : Bool = false) : Void {
		var highesty : Float = 0;
		var nextx : Float = 5;
		var nexty : Float = (isdir) ? 30 : 5;

		for(i in 0 ... butts.length) {
			var buttwidth : Float = butts[i].width;
			var buttheight : Float = butts[i].height;

			butts[i].x = nextx;
			butts[i].y = nexty;

			nextx = nextx + buttwidth + 5;

			if(nextx + buttwidth > FlxG.width) {
				nextx = 5;
				nexty = highesty + buttheight + 5;
			}

			if(nexty > highesty) highesty = nexty;

			addFixed(butts[i]);
		}

		if(isdir) mCurrentDirButts = butts;
	}

	private function openFileSelector(button : FlxButton) : Void {
		if(mDirStack.length > 0 && button != mFileSelectorOpener) {
			dismissFileSelector();
		}

		if(mDirStack.length == 0) {
			mFileSelectorOpener = button;

			mDirStack.push("assets");

			var subdir : String = switch(button.label.text) {
					case "Platform": "plats";
					case "InnerLvl": "bgs";
					default: null;
				};

			if(subdir != null) mDirStack.push(subdir);

			displayFileSelector(getCurrentPath());
		} else {
			dismissFileSelector();
		}
	}

	private function removeButtons(butts : Array<FlxButton>) {
		for(j in 0...butts.length) {
			remove(butts[j], true);
		}
	}

	private function editorButtonCallback(butt : FlxButton) : Void {
		if(butt.label.text == "..") {
			mDirStack.pop();
		} else {
			mDirStack.push(butt.label.text);
		}

		removeButtons(mCurrentDirButts);

		displayFileSelector(getCurrentPath());
	}

	private function getCurrentPath() : String {
		var path : String = "";
		var len : Int =  mDirStack.length;

		for(i in 0...len) {
			path += mDirStack[i] + (i == len - 1 ? "" : "/");
		}

		return path;
	}

	private function imageButtonCallback(butt : FlxButton) : Void {
		var filename : String = getCurrentPath() + "/" + butt.label.text + ".png";
		if(mFileSelectorOpener.label.text == "Platform") {
			mEditorStateHandle.createPlatformSprite(filename);
		} else if(mFileSelectorOpener.label.text == "InnerLvl") {
			mEditorStateHandle.createInnerLevel(filename);
		}
		dismissFileSelector();
	}

	private function dismissFileSelector() : Void {
		removeButtons(mCurrentDirButts);
		while(mDirStack.length > 0) mDirStack.pop();
	}

	private function displayFileSelector(currDir : String) : Void {
		var entries : Array<String> = sys.FileSystem.readDirectory(currDir);
		var buttons : Array<FlxButton> = new Array();
		var displayEntries : Int = 0;

		//trace("reading directory: " + currDir);

		if(mDirStack.length > 1) {
			var up : FlxButton = new EditorButton(5,0,"..",editorButtonCallback);
			up.color = 0xFF3366FF;
			up.label.color = 0xFFFFFFFF;
			buttons.push(up);
		}

		for(i in 0...entries.length) {
			var entry : String = entries[i];
			if(entry.length >= 4 && entry.substring(entry.length - 4) == ".png") {
				var item : FlxButton = new EditorButton(5, 0, entry.substring(0, entry.length-4), imageButtonCallback);
				item.color = 0xFF6FFF47;
				buttons.push(item);
			} else if(sys.FileSystem.isDirectory(currDir + "/" + entry)) {
				var item : FlxButton = new EditorButton(5, 0, entry, editorButtonCallback);
				item.color = 0xFF3366FF;
				item.label.color = 0xFFFFFFFF;
				buttons.push(item);
			}
		}

		layoutTheButts(buttons, true);
	}
}