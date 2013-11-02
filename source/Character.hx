package ;

import org.flixel.FlxState;
import org.flixel.FlxSprite;

class Character extends FlxSprite {
	public static inline var GRAVITY : Float = 400;

	var mSurfaceBoundary : Boundary = null;
	var mDebugBoundarySprite : FlxSprite = null;
	var mDebugOn : Bool = false;

	public function new(X : Float, Y : Float) : Void {
		super(X, Y);
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

	public function setSurfaceBoundary(boundary : Boundary) : Void {
		mSurfaceBoundary = boundary;
	}

	public function isOnGround() : Bool {
		return mSurfaceBoundary != null;
	}

	public function jump() : Void {
		startNotBeingOnTheGround();
		
		velocity.y = -acceleration.y * 0.51;
		play("jump");
	}

	public function isFalling() : Bool {
		return velocity.y > 0;
	}

	public function startNotBeingOnTheGround() : Void {
		acceleration.y = GRAVITY;
		mSurfaceBoundary = null;
	}

	override public function update() : Void {
		var oldx : Float = this.x + this.width;

		super.update();

		if(mDebugOn) {
			mDebugBoundarySprite.x = this.x;
			mDebugBoundarySprite.y = this.y;
		}

		if(isOnGround()) {
			var surfaceline : Line = mSurfaceBoundary.surface;
			var newx : Float = this.x + (this.width / 2);

			// "next" and "prev" only make sense for LTR segments
			if(newx > surfaceline.rightmostPoint.x) {
				if(mSurfaceBoundary.hasNext()) {
					setSurfaceBoundary(mSurfaceBoundary.next);
				} else {
					startNotBeingOnTheGround();
				}
			} else if(newx < surfaceline.leftmostPoint.x) {
				if(mSurfaceBoundary.hasPrev()) {
					setSurfaceBoundary(mSurfaceBoundary.prev);
				} else {
					startNotBeingOnTheGround();
				}
			} else if(newx != oldx) {
				this.y = surfaceline.getY(newx) - this.height;
			}
		}
	}
}