package ;

class Vector3 {
	public var x : Float;
	public var y : Float;
	public var z : Float;

	public function new(x : Float, y : Float, z : Float) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public static function cross(v1 : Vector3, v2 : Vector3) : Vector3 {
		return new Vector3(
			v1.y * v2.z - v1.z * v2.y,
			v1.z * v2.x - v1.x * v2.z,
			v1.x * v2.y - v1.y * v2.x
		);
	}

	public function toString() : String {
		return "(x=" + x + ", y=" + y + ", z=" + z + ")";
	}
}
