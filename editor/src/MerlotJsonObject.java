import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class MerlotJsonObject {
	private JSONObject json = null;

	public MerlotJsonObject(JSONObject obj) {
		this.json = obj;
	}

	public boolean hasKey(String key) {
		return this.json.containsKey(key);
	}

	public String getStr(String key) {
		return (String) this.json.get(key);
	}

	public Integer getInt(String key) {
		return ((Long) this.json.get(key)).intValue();
	}

	public Double getDouble(String key) {
		return (Double) this.json.get(key);
	}

	public MerlotJsonArray getArray(String key) {
		return new MerlotJsonArray((JSONArray) this.json.get(key));
	}
}
