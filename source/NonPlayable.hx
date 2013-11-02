package ;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

class NonPlayable extends Character {
	public function new(filename : String, X:Float, Y:Float, w:Int, h:Int) {
		super(X, Y);
		loadGraphic(filename, true, true);
		maxVelocity.x = 100;			//walking speed
		acceleration.y = 400;			//gravity
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = w;
		height = h;

		frames = 2;
		frameHeight = w;
		frameWidth = h;
		
		addAnimation("idle",[0],0,false);
		addAnimation("walk",[0,1],20,true);
	}
	
	override public function update():Void {
		facing = (velocity.x < 0) ? FlxObject.LEFT : FlxObject.RIGHT;
		super.update();
	}
}