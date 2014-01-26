import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.awt.Graphics2D;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;

public class MerlotPlatform extends MerlotSprite {
	Deque<MerlotBoundary> boundaries = null;

	public MerlotPlatform(MerlotJsonObject json) throws IOException {
		super(json);

		MerlotJsonArray b = json.getArray("b");

		if(b.size() > 0) {
			boundaries = new ArrayDeque<MerlotBoundary>();

			MerlotJsonArray.each(b, new MerlotJsonArray.eachfunc<JSONObject, Object>() {
				@Override
				public boolean process(JSONObject item) {
					boundaries.add(new MerlotBoundary(new MerlotJsonObject(item)));
					return true;
				}
			});
		}
	}

	@Override
	public void draw(Graphics2D g2d) {
		super.draw(g2d);

		if(boundaries != null) {
			for(MerlotBoundary b : boundaries) {
				b.draw(g2d);
			}
		}
	}

	@Override
	public void translate(int dx, int dy) {
		super.translate(dx, dy);
		for(MerlotBoundary b : boundaries) {
			b.translate(dx, dy);
		}
	}

	public JSONObject toJson() {
		JSONObject json = new JSONObject();

		json.put("f", imgfilename);
		json.put("p", Mutil.makeJsonArray(x, y));

		JSONArray bs = new JSONArray();

		for(MerlotBoundary boundary : boundaries) {
			bs.add(boundary.toJson());
		}

		json.put("b", bs);

		return json;
	}
}
