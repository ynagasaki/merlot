package ;

import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

class NonPlayable extends Character {
	public var loadedByEditor : Bool = false;

	var mFilename : String = null;

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
		
		addAnimation("idle",[0],0,false);
		addAnimation("walk",[0,1],20,true);
	}
	
	override public function update() : Void {
		if(!loadedByEditor) {
			facing = (velocity.x < 0) ? FlxObject.LEFT : FlxObject.RIGHT;
			super.update();
		}
	}

	public function toJson() : Dynamic {
		return { f: mFilename, x: this.x, y: this.y, w: this.width, h: this.height };
	}
}