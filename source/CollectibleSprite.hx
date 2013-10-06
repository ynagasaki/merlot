
package ;

import org.flixel.FlxSprite;

class CollectibleSprite extends FlxSprite {
	var mFilename : String = null;

	public function new(filename : String, x : Float, y : Float, ?center : Bool = true) : Void {
		super();
		mFilename = filename;
		loadGraphic(filename, false, false);
		this.x = center ? x - this.width / 2 : x;
		this.y = center ? y - this.height / 2 : y;
	}

	public function toJson() : Dynamic {
		return {"f":mFilename,"p":[this.x, this.y]};
	}

	public static function fromJson(dyn : Dynamic) : CollectibleSprite {
		return new CollectibleSprite(dyn.f, dyn.p[0], dyn.p[1], false);
	}
}