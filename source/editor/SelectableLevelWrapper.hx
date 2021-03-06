
package editor;

class SelectableLevelWrapper implements SelectableItem
{
	public var level : InnerLevel = null;

	public function new(lvl : InnerLevel) : Void {
		level = lvl;
	}

	public function select() : Void {
		level.getBackground().color = 0xFF7777FF;
	}
	
	public function deselect() : Void {
		level.getBackground().color = 0xFFFFFFFF;
	}
	
	public function setPosition(x : Float = 0, y : Float = 0) : Void {
		// go through all plats, nuts, etc and move em
		level.setPosition(x, y);
	}

	public function getItem() : Dynamic {
		return level;
	}

	public function getX() : Float {
		return level.x;
	}

	public function getY() : Float {
		return level.y;
	}

	public function isGateSprite() : Bool { return false; }
	public function isBoundarySprite() : Bool { return false; }
	public function isPlatformSprite() : Bool { return false; }
	public function isCollectibleSprite() : Bool { return false; }
	public function isInnerLevel() : Bool { return true; }

}