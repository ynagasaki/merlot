
package editor;

import org.flixel.FlxBasic;

interface SelectableItem {
	public function select() : Void;
	public function deselect() : Void;
	public function move(x : Float, y : Float) : Void;

	public function getItem() : FlxBasic;
	public function getX() : Float;
	public function getY() : Float;

	public function isBoundarySprite() : Bool;
	public function isPlatformSprite() : Bool;
	public function isCollectibleSprite() : Bool;
	public function isInnerLevel() : Bool;
}