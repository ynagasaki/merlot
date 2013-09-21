package ;

import org.flixel.util.FlxPoint;

class IntersectionCheckResult 
{
	public var intersectionPoint : FlxPoint;
	public var intersectingLine : Line;

	public function new(p : FlxPoint, l : Line) {
		intersectionPoint = p;
		intersectingLine = l;
	}
}