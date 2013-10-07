
package ;

import org.flixel.FlxSprite;

class BoundarySprite extends FlxSprite {
	var mBoundary : Boundary = null;

	public function new(boundary : Boundary) : Void {
		super(boundary.surface.leftmostPoint.x, boundary.surface.topmostPoint.y);

		makeGraphic(
			Math.round(boundary.surface.rightmostPoint.x), 
			Math.round(boundary.surface.bottommostPoint.y), 
			0x00FFFFFF, 
			true
		);

		drawLine(
			boundary.surface.p1.x - this.x, 
			boundary.surface.p1.y - this.y, 
			boundary.surface.p2.x - this.x, 
			boundary.surface.p2.y - this.y, 
			0xFF000000, 
			1
		);

		mBoundary = boundary;
	}

	override public function update() {
		super.update();
		x = mBoundary.surface.leftmostPoint.x;
		y = mBoundary.surface.topmostPoint.y;
	}
}