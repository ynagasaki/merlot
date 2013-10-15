
package editor;

import org.flixel.FlxBasic;
import org.flixel.FlxSprite;

class SelectableSpriteWrapper implements SelectableItem {
	public var sprite : FlxSprite = null;

	public function new(spr : FlxSprite) : Void {
		sprite = spr;
	}

	public function select() : Void {
		sprite.color = 0xFF7777FF;
	}

	public function deselect() : Void {
		sprite.color = 0xFFFFFFFF;
	}

	public function move(x : Float, y : Float) : Void {
		sprite.move(x, y);
	}

	public function getItem() : Dynamic { return sprite; }
	public function getX() : Float { return sprite.x; }
	public function getY() : Float { return sprite.y; }

	public function isInnerLevel() : Bool { return false; }
	public function isBoundarySprite() : Bool { return false; } // boundarysprite is speshl
	public function isCollectibleSprite() : Bool { return Type.getClass(sprite) == CollectibleSprite; }
	public function isPlatformSprite() : Bool { return Type.getClass(sprite) == PlatformSprite; }
}