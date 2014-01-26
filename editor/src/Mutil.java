import org.json.simple.JSONArray;

public class Mutil {
	public static int floor(int num, int resolution) {
		return num / resolution * resolution;
	}

	public static <T> JSONArray makeJsonArray(T... items) {
		JSONArray array = new JSONArray();

		for(T item : items) {
			array.add(item);
		}

		return array;
	}
}
