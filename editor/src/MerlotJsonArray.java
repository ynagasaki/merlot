import org.json.simple.JSONArray;

import java.util.Iterator;

public class MerlotJsonArray {
	public static interface eachfunc<T> {
		boolean process(T item);
	}

	public static void each(MerlotJsonArray array, eachfunc f) {
		Iterator iter = array.array.iterator();
		while(iter.hasNext() && f.process(iter.next()));
	}

	private JSONArray array;

	public MerlotJsonArray(JSONArray array) {
		this.array = array;
	}

	public Integer getInt(int idx) {
		Object value = this.array.get(idx);

		if(value instanceof Long) return ((Long) value).intValue();
		if(value instanceof Double) return ((Double) value).intValue();

		return (Integer) value;
	}

	public Double getDouble(int idx) {
		return ((Double) this.array.get(idx)).doubleValue();
	}
}
