package ;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

class Player extends Character {
	public static inline var WIDTH : Float = 14;
	public static inline var WIDTH_HALF : Float = WIDTH / 2;
	public static inline var HEIGHT : Float = 29;

	public function new(X:Float, Y:Float) : Void {
		super(X, Y);
		loadGraphic("assets/pino-run.png", true, true, 40, 35);
		maxVelocity.x = 100;			//walking speed
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = WIDTH;
		height = HEIGHT;

		frames = 5;
		frameWidth = 40;
		frameHeight = 35;

		offset.x = frameWidth / 2 - WIDTH_HALF - 1;
		offset.y = frameHeight - HEIGHT; // as long as frameheight > height

		addAnimation("idle",[0],0,false);
		addAnimation("walk",[1,2,3,4],10,true);
		addAnimation("walk_back",[1,2,3,4],10,true);
		addAnimation("flail",[0],18,false);
		addAnimation("jump",[1],0,false);
	}

	public function jump() : Void {
		startNotBeingOnTheGround();
		
		velocity.y = -acceleration.y * 0.51;
	}

	public function isJumping() : Bool {
		return velocity.y < 0; // this is < b/c the origin is top-left
	}

	override public function update() : Void {
		//Smooth slidey walking controls
		acceleration.x = 0;

		if(FlxG.keys.LEFT)
			acceleration.x -= drag.x;
		if(FlxG.keys.RIGHT)
			acceleration.x += drag.x;
		
		if(isOnGround()) {
			//Jump controls
			if(FlxG.keys.justPressed("SPACE")) {
				jump();
			} else if(velocity.x > 0) {
				play("walk");
				facing = FlxObject.RIGHT;
			} else if(velocity.x < 0) {
				play("walk_back");
				facing = FlxObject.LEFT;
			} else {
				play("idle");
			}
		} else if(isJumping()) {
			play("jump");
			if(FlxG.keys.justReleased("SPACE")) {
				if(velocity.y < -acceleration.y * 0.25)
				velocity.y = -acceleration.y * 0.25;
			}
		} else {
			play("flail");
		}

		super.update();
	}
}