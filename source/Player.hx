package;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;


class Player extends FlxSprite
{
	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		loadGraphic("assets/pino-run.png", true, true, 40, 35);
		maxVelocity.x = 100;			//walking speed
		acceleration.y = 400;			//gravity
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = 10;
		height = 30;
		offset.x = 15;
		offset.y = 5;

		frames = 5;
		frameHeight = 35;
		frameWidth = 40;
		
		addAnimation("idle",[0],0,false);
		addAnimation("walk",[1,2,3,4],10,true);
		addAnimation("walk_back",[1,2,3,4],10,true);
		addAnimation("flail",[0],18,false);
		addAnimation("jump",[1],0,false);
	}
	
	override public function update():Void
	{
		//Smooth slidey walking controls
		acceleration.x = 0;

		if(FlxG.keys.LEFT)
			acceleration.x -= drag.x;
		if(FlxG.keys.RIGHT)
			acceleration.x += drag.x;
		
		if(isTouching(FlxObject.FLOOR)) {
			//Jump controls
			if(FlxG.keys.justPressed("SPACE")) {
				velocity.y = -acceleration.y*0.51;
				play("jump");
			} else if(velocity.x > 0) {
				play("walk");
				facing = FlxObject.RIGHT;
			} else if(velocity.x < 0) {
				play("walk_back");
				facing = FlxObject.LEFT;
			} else {
				play("idle");
			}
		}
		else if(velocity.y < 0)
			play("jump");
		else
			play("flail");

        super.update();
	}
}