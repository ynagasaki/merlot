
package ;

interface ICarryable {
	function onPickedUp() : Void;
	function onDropped() : Void;
	function onBeingCarried(held_x : Float, held_y : Float, facing : Int) : Void;
}