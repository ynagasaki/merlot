package ;

import org.flixel.util.FlxPoint;

class IntersectionCheckResult 
{
	public var intersectionPoint : FlxPoint;
	public var intersectingBoundary : Boundary;

	public function new(p : FlxPoint, b : Boundary) {
		intersectionPoint = p;
		intersectingBoundary = b;
	}
}