import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class Mutil {
	public static Integer getIntValueFromJson(JSONObject obj, String key, Integer fallback) {
		if(!obj.containsKey(key)) return fallback;
		else return ((Long) obj.get(key)).intValue();
	}

	public static Integer getIntValueFromJson(JSONArray obj, int i, Integer fallback) {
		if(i < 0 || i > obj.size() - 1) return fallback;
		else return ((Long) obj.get(i)).intValue();
	}
}
