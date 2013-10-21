package ;

import org.flixel.util.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.util.FlxRect;

class Utility {
	public static inline var EPSILON : Float = 0.0001;

	public static function isZero(x : Float) : Bool {
		return x > -EPSILON && x < EPSILON;
	}

	public static function sameLoc(p1 : FlxPoint, p2 : FlxPoint) {
		return p1.x == p2.x && p1.y == p2.y;
	}

	public static function isRectInRect(r1 : FlxRect, r2 : FlxRect) : Bool {
		return r1.x>=r2.x&&r1.y>=r2.y&&r1.x+r1.width<=r2.x+r2.width&&r1.y+r1.height<=r2.y+r2.height;
	}

	/*
	 * Check if two line segments intersect, return the intersection
	 * point if intersect.
	 */
	public static function checkLineIntersection(line1 : Line, line2 : Line) : FlxPoint {
		//trace("Checking intersection: " + line1 + " and " + line2);
		
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

	public static function isPointInSpriteBounds(x : Float, y : Float, spr : FlxSprite) : Bool{
		var sx : Float = spr.x;
		var sy : Float = spr.y;
		var sx2 : Float = sx + spr.width;
		var sy2 : Float = sy + spr.height;
		return x >= sx && x <= sx2 && y >= sy && y <= sy2;
	}
}