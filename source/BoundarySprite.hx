
package ;

import org.flixel.FlxSprite;

class BoundarySprite extends FlxSprite {
	public var boundary : Boundary = null;

	public function new(b : Boundary) : Void {
		super(b.surface.leftmostPoint.x, b.surface.topmostPoint.y);

		makeGraphic(
			Math.round(b.surface.rightmostPoint.x - this.x + 1), 
			Math.round(b.surface.bottommostPoint.y - this.y + 1), 
			0x00FFFFFF, 
			true
		);

		boundary = b;

		drawDeselected();
	}

	public function drawSelected() : Void {
		fill(0x00FFFFFF);
		drawLine(
			boundary.surface.p1.x - this.x, 
			boundary.surface.p1.y - this.y, 
			boundary.surface.p2.x - this.x, 
			boundary.surface.p2.y - this.y, 
			0xFFFFFFFF, 
			1
		);
	}

	public function drawDeselected() : Void {
		fill(0x00FFFFFF);
		drawLine(
			boundary.surface.p1.x - this.x, 
			boundary.surface.p1.y - this.y, 
			boundary.surface.p2.x - this.x, 
			boundary.surface.p2.y - this.y, 
			0xFF000000, 
			1
		);
	}

	override public function update() {
		super.update();
		x = boundary.surface.leftmostPoint.x;
		y = boundary.surface.topmostPoint.y;
	}
}
