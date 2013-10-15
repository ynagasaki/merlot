
package ;

class InnerLevel extends Level {

	public var x : Float = 0;
	public var y : Float = 0;

	public var parentLevel : Level = null;

	public function new(parent : Level, backgroundFilename : String) : Void {
		super(null);

		parentLevel = parent;

		prepareBackground(backgroundFilename);
	}

	public function setPosition(x : Float, y : Float) : Void {
		for(p in mPlatformSprites) {
			var xoffset : Float = p.x - this.x;
			var yoffset : Float = p.y - this.y;
			p.move(x + xoffset, y + yoffset);
		}

		for(c in mNutCoins) {
			var xoffset : Float = c.x - this.x;
			var yoffset : Float = c.y - this.y;
			c.move(x + xoffset, y + yoffset);
		}

		this.x = x;
		this.y = y;

		mBackground.x = x;
		mBackground.y = y;
	}

}