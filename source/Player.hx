package ;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends Character {
	public static inline var WIDTH : Float = 40;//14;
	public static inline var WIDTH_HALF : Float = WIDTH / 2;
	public static inline var HEIGHT : Float = 75;//29;

	public function new(X:Float, Y:Float) : Void {
		super(X, Y);
		loadGraphic("assets/pino-run.png", true, true, 100, 94);//40, 35);
		maxVelocity.x = 160;			//walking speed
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = WIDTH;
		height = HEIGHT;

		frames = 10;//5;
		frameWidth = 100;//40;
		frameHeight = 94;//35;

		offset.x = frameWidth / 2 - WIDTH_HALF - 1;
		offset.y = frameHeight - HEIGHT; // as long as frameheight > height

		/*addAnimation("idle",[0],0,false);
		addAnimation("walk",[1,2,3,4],10,true);
		addAnimation("walk_back",[1,2,3,4],10,true);
		addAnimation("flail",[0],18,false);
		addAnimation("jump",[1],0,false);*/
		this.animation.add("idle",[0],0,false);
		this.animation.add("walk",[0,1,2,3,4,5,6,7,8,9],14,true);
		this.animation.add("walk_back",[0,1,2,3,4,5,6,7,8,9],14,true);
		this.animation.add("flail",[0],18,false);
		this.animation.add("jump",[0],0,false);
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

		if(FlxG.keys.pressed.LEFT)
			acceleration.x -= drag.x;
		if(FlxG.keys.pressed.RIGHT)
			acceleration.x += drag.x;
		
		if(isOnGround()) {
			//Jump controls
			if(FlxG.keys.justPressed.SPACE) {
				jump();
			} else if(velocity.x > 0) {
				this.animation.play("walk");
				facing = FlxObject.RIGHT;
			} else if(velocity.x < 0) {
				this.animation.play("walk_back");
				facing = FlxObject.LEFT;
			} else {
				this.animation.play("idle");
			}
		} else if(isJumping()) {
			this.animation.play("jump");
			if(FlxG.keys.justReleased.SPACE) {
				if(velocity.y < -acceleration.y * 0.25)
				velocity.y = -acceleration.y * 0.25;
			}
		} else {
			this.animation.play("flail");
		}

		super.update();
	}
}