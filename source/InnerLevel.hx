
package ;

class InnerLevel extends Level {

	public var x : Float = 0;
	public var y : Float = 0;

	public function new(backgroundFilename : String, X : Float, Y : Float) {
		super(null);

		x = X;
		y = Y;

		prepareBackground(backgroundFilename);
	}

}