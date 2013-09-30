
package ;

import org.flixel.util.FlxPoint;
import org.flixel.FlxGroup;
import org.flixel.FlxButton;

class EditorButton {
	var mButton : FlxButton = null;
	var mCallback : (FlxButton -> Void) = null;

	public function new(x : Int, y : Int, label : String, callback : (FlxButton -> Void)) {
		mButton = new FlxButton(x, y, label, clickCallback);
		mCallback = callback;
	}

	public function getButton() : FlxButton {
		return mButton;
	}

	public function clickCallback() : Void {
		if(mCallback != null) mCallback(mButton);
	}
}

class EditorMenu extends FlxGroup {
	var mEditorStateHandle : EditorState = null;
	var mDirStack : Array<String> = null;
	var mCurrentDirButts : Array<FlxButton> = null;

	public function new(editorHandle : EditorState) {
		super();

		mDirStack = new Array();
		mEditorStateHandle = editorHandle;

		var buttons : Array<FlxButton> = [
			new FlxButton(5,5,"LineMode", editorHandle.startLineMode),
			new FlxButton(0,0,"Platform", platformButtonCallback),
			new FlxButton(0,0,"SaveLvl", editorHandle.saveLevel)
		];

		layoutTheButts(buttons);
	}

	public function addFixed(item : org.flixel.FlxObject) : Void {
		item.scrollFactor = new FlxPoint(0, 0);
		add(item);
	}

	public function hide(hide : Bool) : Void {
		for(i in 0...members.length) {
			members[i].visible = !hide;
		}
	}

	private function layoutTheButts(butts : Array<FlxButton>, ?isdir : Bool = false) : Void {
		for(i in 0 ... butts.length) {
			butts[i].y = (isdir) ? 30 : 5 ;
			if(i > 0) {
				butts[i].x = butts[i - 1].x + butts[i - 1].width + 5;
			}
			addFixed(butts[i]);
		}

		if(isdir) mCurrentDirButts = butts;
	}

	private function platformButtonCallback() : Void {
		if(mDirStack.length == 0) {
			mDirStack.push("assets");
			displayFileSelector("assets");
		} else {
			dismissFileSelector();
		}
	}

	private function removeDirectoryButtons() {
		for(j in 0...mCurrentDirButts.length) {
			remove(mCurrentDirButts[j], true);
		}
	}

	private function editorButtonCallback(butt : FlxButton) : Void {
		if(butt.label.text == "..") {
			mDirStack.pop();
		} else {
			mDirStack.push(butt.label.text);
		}

		removeDirectoryButtons();

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
		mEditorStateHandle.createPlatformSprite(getCurrentPath() + "/" + butt.label.text + ".png");
		dismissFileSelector();
	}

	private function dismissFileSelector() : Void {
		removeDirectoryButtons();
		while(mDirStack.length > 0) mDirStack.pop();
	}

	private function displayFileSelector(currDir : String) : Void {
		var entries : Array<String> = sys.FileSystem.readDirectory(currDir);
		var buttons : Array<FlxButton> = new Array();
		var displayEntries : Int = 0;

		trace("reading directory: " + currDir);

		if(mDirStack.length > 1) {
			var up : FlxButton = new EditorButton(5,0,"..",editorButtonCallback).getButton();
			up.color = 0xFF3366FF;
			up.label.color = 0xFFFFFFFF;
			buttons.push(up);
		}

		for(i in 0...entries.length) {
			var entry : String = entries[i];
			if(entry.length >= 4 && entry.substring(entry.length - 4) == ".png") {
				var item : FlxButton = new EditorButton(5, 0, entry.substring(0, entry.length-4), imageButtonCallback).getButton();
				item.color = 0xFF6FFF47;
				buttons.push(item);
			} else if(sys.FileSystem.isDirectory(currDir + "/" + entry)) {
				var item : FlxButton = new EditorButton(5, 0, entry, editorButtonCallback).getButton();
				item.color = 0xFF3366FF;
				item.label.color = 0xFFFFFFFF;
				buttons.push(item);
			}
		}

		layoutTheButts(buttons, true);
	}
}