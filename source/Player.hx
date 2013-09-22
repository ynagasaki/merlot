package ;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;

class Player extends FlxSprite
{
	public static inline var GRAVITY : Float = 400;

	var mSurfaceLine : Line = null;
	var mDebugBoundarySprite : FlxSprite = null;
	var mDebugOn : Bool = false;

	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		loadGraphic("assets/pino-run.png", true, true, 40, 35);
		maxVelocity.x = 100;			//walking speed
		acceleration.y = GRAVITY;
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = 10;
		height = 30;

		frames = 5;
		frameWidth = 40;
		frameHeight = 35;

		offset.x = frameWidth / 2;
		offset.y = frameHeight / 2;
		
		addAnimation("idle",[0],0,false);
		addAnimation("walk",[1,2,3,4],10,true);
		addAnimation("walk_back",[1,2,3,4],10,true);
		addAnimation("flail",[0],18,false);
		addAnimation("jump",[1],0,false);
	}

	public function setDebug(on : Bool, state : FlxState) : Void {
		mDebugOn = on;

		if(mDebugBoundarySprite == null) {
			mDebugBoundarySprite = new FlxSprite(this.x, this.y);
			mDebugBoundarySprite.makeGraphic(5,5, 0xFFFF0000);
		}
		
		if(mDebugOn) {
			state.add(mDebugBoundarySprite);
		} else {
			state.remove(mDebugBoundarySprite);
		}
	}

	public function setSurfaceLine(surface : Line) : Void {
		mSurfaceLine = surface;
	}

	public function isOnGround() : Bool {
		return mSurfaceLine != null;
	}

	public function jump() : Void {
		startNotBeingOnTheGround();
		
		velocity.y = -acceleration.y * 0.51;
		play("jump");
	}

	public function isFalling() : Bool {
		return velocity.y > 0;
	}

	override public function update() : Void
	{
		var oldx : Float = this.x;

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
		} else if(velocity.y < 0) {
			play("jump");
		} else {
			play("flail");
		}

		super.update();

		if(mDebugOn) {
			mDebugBoundarySprite.x = this.x;
			mDebugBoundarySprite.y = this.y;
		}

		if(isOnGround()) {
			if(this.x > mSurfaceLine.rightmostPoint.x || this.x < mSurfaceLine.leftmostPoint.x) {
				startNotBeingOnTheGround();
			} else if(this.x != oldx) {
				this.y = mSurfaceLine.getY(this.x) - offset.y;
			}
		}
	}

	private function startNotBeingOnTheGround() {
		acceleration.y = GRAVITY;
		mSurfaceLine = null;
	}
}