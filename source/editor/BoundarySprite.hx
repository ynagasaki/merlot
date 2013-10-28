
package editor;

import org.flixel.FlxSprite;

class BoundarySprite extends FlxSprite implements SelectableItem {
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

		deselect();
	}

	public function getItem() : Dynamic { return this; }
	public function getX() : Float { return this.x; }
	public function getY() : Float { return this.y; }

	public function isGateSprite() : Bool { return false; }
	public function isCollectibleSprite() : Bool { return false; }
	public function isBoundarySprite() : Bool { return true; }
	public function isPlatformSprite() : Bool { return false; }
	public function isInnerLevel() : Bool { return false; }

	public function select() : Void {
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

	public function deselect() : Void {
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
