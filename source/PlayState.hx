package;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.util.FlxMath;
import org.flixel.FlxGroup;

import haxe.io.Input;

class PlayState extends FlxState
{
	var player : Player;
	var duck : NonPlayable;
	var platformsGroup : FlxGroup;
	var statusText : FlxText;
	var bg : FlxSprite;

	var linesList : List<Line>;
	var currentLine : Line;

	var editorState : EditorState = null;

	public function loadLines(spr : FlxSprite):Void {
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
	}

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.bgColor = 0xFF77D1F7;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end

		linesList = new List();
		currentLine = new Line(-1, -1, -1, -1);

		{
			bg = new FlxSprite(0, 0);
			bg.loadGraphic("assets/bg-test.png",false,false,1800,700,true);
			add(bg);
			loadLines(bg);
		}

		this.player = new Player(10, 400);
		this.add(this.player);

		FlxG.camera.setBounds(0, 0, 1800, 700, true);
		FlxG.camera.follow(player, org.flixel.FlxCamera.STYLE_PLATFORMER);

		platformsGroup = new FlxGroup(); {
			var platform : FlxSprite = new FlxSprite(0, 500-10).makeGraphic(200, 10, 0xff233e58);
			platform.immovable = true;
			platformsGroup.add(platform);

			platform = new FlxSprite(250, 500 - 50).makeGraphic(750, 50, 0xff233e58);
			platform.immovable = true;
			platformsGroup.add(platform);

			platform = new FlxSprite(990, 500 - 60).makeGraphic(10, 10, 0xff00ff00);
			platform.immovable = true;
			platformsGroup.add(platform);
		}

		add(platformsGroup);

		statusText = new FlxText(10,10,200);
		statusText.scrollFactor.x = statusText.scrollFactor.y = 0;
		add(statusText);

		super.create();

		duck = new NonPlayable(500, 60, 19, 19);
		this.add(duck);
	}

	private function onSave():Void
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
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	var elapsedTime : Float = 0.0;
	var seconds : Int = 10;
	override public function update():Void
	{
		FlxG.collide(this.player, this.platformsGroup);
		FlxG.collide(this.duck, this.platformsGroup);
		FlxG.collide(this.player, this.duck, playerCollidesWithDuck );

		elapsedTime += FlxG.elapsed;
		if(elapsedTime >= 1.0) {
			elapsedTime = 0.0;
			seconds --;
			statusText.text = seconds + "";
		}

		try {
		if(FlxG.keys.justPressed("ONE")) {
			if(editorState == null) editorState = new EditorState();
			FlxG.switchState(editorState);
		}
		} catch(ex:Dynamic) {
			trace(ex);
		}

		figOutMouseDrawingLinesCrap();

		super.update();
	}



	private function figOutMouseDrawingLinesCrap():Void {
		var mouseX:Float = FlxG.mouse.x;		//Get the X position of the mouse in the game world
		//var screenX:Number = FlxG.mouse.screenX;	//Get the X position of the mouse in screen space
		//var pressed:Boolean = FlxG.mouse.pressed();	//Check whether the mouse is currently pressed
		//var justPressed:Boolean = FlxG.mouse.justPressed();
		var justReleased:Bool = FlxG.mouse.justReleased();

		if(justReleased) {
			if(currentLine.p1.x == -1) {
				currentLine.p1.x = mouseX;
				currentLine.p1.y = FlxG.mouse.y;
				trace("assign next point");
			} else {
				currentLine.p2.x = mouseX;
				currentLine.p2.y = FlxG.mouse.y;

				bg.drawLine(currentLine.p1.x, currentLine.p1.y, currentLine.p2.x, currentLine.p2.y, 1, 1);

				linesList.add(currentLine);
				trace("added line: " + currentLine.toString());
				currentLine = new Line(-1, -1, -1, -1);
			}
		}
	}

	public function playerCollidesWithDuck(player : Player, duck : NonPlayable) : Void {
		statusText.text = "lol";
		player.velocity.x = -100;
		player.velocity.y = -100;
		duck.velocity.x = 100;
		duck.velocity.y = -100;
	}
}