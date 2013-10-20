
package editor;

interface SelectableItem {
	public function select() : Void;
	public function deselect() : Void;
	public function move(x : Float, y : Float) : Void;

	public function getItem() : Dynamic; // this is not the best type to use.. could be causing bugs
	public function getX() : Float;
	public function getY() : Float;

	public function isBoundarySprite() : Bool;
	public function isPlatformSprite() : Bool;
	public function isCollectibleSprite() : Bool;
	public function isInnerLevel() : Bool;
}