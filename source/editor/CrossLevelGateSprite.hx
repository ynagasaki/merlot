
package editor;

import flixel.FlxSprite;

class CrossLevelGateSprite  extends FlxSprite implements SelectableItem {
	public var gate : CrossLevelGate = null;

	var mMoved : Bool = false;

	public function new(g : CrossLevelGate) : Void {
		super(g.position.x, g.position.y);

		makeGraphic(
			Math.ceil(CrossLevelGate.WIDTH), 
			Math.ceil(CrossLevelGate.HEIGHT), 
			0xFFFF0000, 
			true
		);

		gate = g;

		deselect();
	}

	public function getItem() : Dynamic { return this; }
	public function getX() : Float { return this.x; }
	public function getY() : Float { return this.y; }

	public function isCollectibleSprite() : Bool { return false; }
	public function isBoundarySprite() : Bool { return false; }
	public function isPlatformSprite() : Bool { return false; }
	public function isInnerLevel() : Bool { return false; }
	public function isGateSprite() : Bool { return true; }

	public function select() : Void {
		this.color = 0xFF7777FF;
	}

	public function deselect() : Void {
		this.color = 0xFFFFFFFF;
	}

	public function highlightRelatedBoundarySprites(lvl : Level, levelBoundarySpriteList : List<BoundarySprite>, highlight : Bool) {
		var linkedboundaries : List<Boundary> = gate.getLinkedBoundaries(lvl);
		for(boundary in linkedboundaries) {
			for(bs in levelBoundarySpriteList) {
				if(bs.boundary == boundary) {
					if(highlight)
						bs.select();
					else
						bs.deselect();
				}
			}
		}
	}

	override public function setPosition(x : Float = 0, y : Float = 0) : Void {
		var deltax : Float = this.x;
		var deltay : Float = this.y;

		super.setPosition(x, y);
		
		deltax = this.x - deltax;
		deltay = this.y - deltay;

		gate.position.x += deltax;
		gate.position.y += deltay;

		mMoved = true;
	}

	override public function update() : Void {
		super.update();

		if(!mMoved) {
			this.x = gate.position.x;
			this.y = gate.position.y;
		}

		mMoved = false;
	}
}