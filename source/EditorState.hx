package;

import haxe.Json;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.util.FlxPoint;

class EditorState extends FlxState {
	//var linesList : List<Line>;
	var mFirstPoint : FlxPoint = null;
	var mLevel : Level = null;

/*	public function loadLines(spr : FlxSprite):Void {
		// open and read file line by line
		try {
			var fin = sys.io.File.read("assets/lines.txt", false);
			try {
				var lineNum = 0;
				while( true ) {
					var str = fin.readLine();

					if(str.charAt(str.length - 1) == "\n") {
						str = str.substring(0, str.length - 1);
					}

					if(str.length == 0) continue;

					var p = str.split(" ");

					spr.drawLine(Std.parseFloat(p[0]), Std.parseFloat(p[1]), Std.parseFloat(p[2]), Std.parseFloat(p[3]), 1, 1);
				}
			} catch( ex:haxe.io.Eof ) {
				trace("finished reading file");
			}
			fin.close();
		} catch( ex:Dynamic ) {
			trace("File probably not found: " + ex);
		}
	}*/

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.bgColor = 0xFFFF00FF;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		mLevel = new Level();

		mLevel.loadLevel("assets/level-01.json");

		add(mLevel.getLevelSprite());

		FlxG.camera.setBounds(0, 0, 1800, 700, true);

		super.create();
	}

	/*private function onSave():Void
	{
		try {
			trace("writing");
			var fout = sys.io.File.write("assets/lines.txt", false);
			
			for(line in linesList) {
				fout.writeString(line.toStringForFile() + "\n");
			}

			fout.close();
			trace("done");
		} catch(ex : Dynamic) {
			trace(ex);
		}
	}*/
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update() : Void
	{
		figOutMouseDrawingLinesCrap();

		if(FlxG.keys.pressed("SHIFT")) {
			FlxG.camera.focusOn(new FlxPoint(FlxG.mouse.x, FlxG.mouse.y));
		}

		try {
		if(FlxG.keys.justPressed("ONE")) {
			mLevel.save();
		} } catch(ex : Dynamic) {
			trace(ex);
		}

		super.update();
	}

	private function figOutMouseDrawingLinesCrap() : Void {
		if(FlxG.mouse.justReleased()) {
			if(mFirstPoint == null) {
				mFirstPoint = new FlxPoint(FlxG.mouse.x, FlxG.mouse.y);
				trace("assign next point");
			} else {
				var line : Line = new Line(mFirstPoint.x, mFirstPoint.y, FlxG.mouse.x, FlxG.mouse.y);
				mLevel.addLine(line);
				mFirstPoint = null;
				trace("added line: " + line.toString());
			}
		}
	}
}