package ;

import flixel.FlxObject;

class NonPlayable extends Character implements ICarryable {
	public var loadedByEditor : Bool = false;

	var mFilename : String = null;
	var mBeingCarried : Bool = false;

	public static function fromJson(dyn : Dynamic) : NonPlayable {
		return new NonPlayable(dyn.f, dyn.x, dyn.y, dyn.w, dyn.h);
	}

	public function new(filename : String, X:Float, Y:Float, w:Int, h:Int) {
		super(X, Y);

		mFilename = filename;

		loadGraphic(filename, true, true);
		maxVelocity.x = 100;			//walking speed
		drag.x = maxVelocity.x*4;		//deceleration (sliding to a stop)
		
		//tweak the bounding box for better feel
		width = w;
		height = h;

		frames = 2;
		frameHeight = w;
		frameWidth = h;
		
		this.animation.add("idle",[0],0,false);
		this.animation.add("walk",[0,1],20,true);
	}
	
	public function onPickedUp() : Void {
		mBeingCarried = true;
		//this.startNotBeingOnTheGround();
		//this.acceleration.y = this.velocity.y = 0; // not falling
	}

	public function onDropped() : Void {
		mBeingCarried = false;
		this.startNotBeingOnTheGround();
	}

	public function onBeingCarried(held_x : Float, held_y : Float, facing : Int) : Void {
		this.y = held_y;
		this.x = (facing == FlxObject.RIGHT) ? held_x : held_x - this.width;
		this.facing = facing;
	}

	override public function update() : Void {
		if(!loadedByEditor && this.visible && !mBeingCarried) {
			facing = (velocity.x < 0) ? FlxObject.LEFT : FlxObject.RIGHT;
			super.update();
		}
	}

	public function toJson() : Dynamic {
		return { f: mFilename, x: this.x, y: this.y, w: this.width, h: this.height };
	}
}