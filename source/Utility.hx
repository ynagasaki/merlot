package;

import org.flixel.util.FlxPoint;

class Utility {
	public static inline var EPSILON : Float = 0.0001;

	public static function isZero(x : Float) : Bool {
		return x > -EPSILON && x < EPSILON;
	}

	/*
	 * Check if two line segments intersect, return the intersection
	 * point if intersect.
	 */
	public static function checkLineIntersection(line1 : Line, line2 : Line) : FlxPoint {
		/// CONSTRUCT 2x2 LINEAR SYSTEM FOR (alpha,beta) CONVEX COORDS:
		/// [ a b ] [alpha] = [c]
		/// [ d e ] [beta ]   [f]
		var a : Float = (line1.p2.x - line1.p1.x);
		var d : Float = (line1.p2.y - line1.p1.y);
		var b : Float = -(line2.p2.x - line2.p1.x);
		var e : Float = -(line2.p2.y - line2.p1.y);
		var c : Float = (line2.p1.x - line1.p1.x);
		var f : Float = (line2.p1.y - line1.p1.y);

		/// SOLVE, e.g., USING CRAMER'S RULE:
		var det : Float = a * e - b * d;

		if(!isZero(det)) {
			// Lines are not parallel
			var alpha : Float = (c * e - b * f) / det;
			var beta : Float = (a * f - c * d) / det;

			if (alpha >= 0 && alpha <= 1 && beta >= 0 && beta <= 1) { // Parameterized ratio
				var nonalpha : Float = 1.0 - alpha;
				return new FlxPoint(
					(line1.p1.x * nonalpha + line1.p2.x * alpha), 
					(line1.p1.y * nonalpha + line1.p2.y * alpha)
				);
			}
		}

		return null;
	}
}