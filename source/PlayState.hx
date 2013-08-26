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

class PlayState extends FlxState
{
	var player : Player;
	var platformsGroup : FlxGroup;
	var statusText : FlxText;

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
		
		this.player = new Player(10, 400);
		this.add(this.player);

		FlxG.camera.setBounds(0, 0, 1000, 500, true);
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

		elapsedTime += FlxG.elapsed;
		if(elapsedTime >= 1.0) {
			elapsedTime = 0.0;
			seconds --;
			statusText.text = seconds + "";
		}

		super.update();
	}	
}