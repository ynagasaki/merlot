package;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;


class NonPlayable extends FlxSprite
{
	public function new(X:Float, Y:Float, w:Int, h:Int)
	{
		super(X, Y);
		loadGraphic("assets/duck-thing-sm.png", true, true, w, h);
		maxVelocity.x = 100;			//walking speed
		acceleration.y = 400;			//gravity
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = w;
		height = h;
		mass = 30;
		//offset.x = 0;
		//offset.y = 0;

		frames = 1;
		frameHeight = w;
		frameWidth = h;
		
		addAnimation("idle",[0],0,false);
		addAnimation("walk",[0],0,false);
		addAnimation("walk_back",[0],0,false);
	}
	
	override public function update():Void
	{
		acceleration.x = -0.5;

		facing = (velocity.x < 0) ? FlxObject.LEFT : FlxObject.RIGHT;

        super.update();
	}
}