
package ;

import flixel.FlxSprite;

class CollectibleSprite extends FlxSprite {
	var mFilename : String = null;

	public function new(filename : String, x : Float, y : Float, ?center : Bool = true) : Void {
		super();
		mFilename = filename;
		loadGraphic(filename, false, false);
		this.x = center ? x - this.width / 2 : x;
		this.y = center ? y - this.height / 2 : y;

		var ten_pct_width : Float = .1 * width;
		var ten_pct_height : Float = .1 * height;

		offset.x = ten_pct_width;
		offset.y = ten_pct_height;

		width = .8 * width;
		height = .8 * height;
	}

	public function toJson() : Dynamic {
		return {"f":mFilename,"p":[this.x, this.y]};
	}

	public static function fromJson(dyn : Dynamic) : CollectibleSprite {
		return new CollectibleSprite(dyn.f, dyn.p[0], dyn.p[1], false);
	}
}