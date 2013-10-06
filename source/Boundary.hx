package ;

class Boundary {
	public var surface : Line = null;
	public var normal : Line = null;

	public var next : Boundary = null;
	public var prev : Boundary = null;

	public function new() {
		
	}

	/**
	* "Next" only makes sense with LTR segments
	*/
	public function hasNext() : Bool { 
		return next != null;
	}

	/**
	* "Prev" only makes sense with LTR segments
	*/
	public function hasPrev() : Bool {
		return prev != null;
	}

	public function is(other : Boundary) : Bool {
		return this == other;
	}

	public function toJson() : Dynamic {
		var s : Line = surface;
		var n : Line = normal;
		return {"s":[s.p1.x, s.p1.y, s.p2.x, s.p2.y], "n":[n.p1.x, n.p1.y, n.p2.x, n.p2.y]};
	}

	public static function fromJson(jsonobj : Dynamic) : Boundary {
		var retval : Boundary = new Boundary();
		retval.surface = new Line(jsonobj.s[0], jsonobj.s[1], jsonobj.s[2], jsonobj.s[3]);
		retval.normal = new Line(jsonobj.n[0], jsonobj.n[1], jsonobj.n[2], jsonobj.n[3]);
		return retval;
	}
}