import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.awt.*;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;

public class MerlotPlatform extends MerlotSprite {
	Deque<MerlotBoundary> boundaries = new ArrayDeque<>();

	MerlotLevel innerLevel;

	public MerlotPlatform(String filename) throws IOException {
		super(filename);

		hasFrames = false;
	}

	public MerlotLevel getAssociatedInnerLevel() {
		return innerLevel;
	}

	public void setAssociatedInnerLevel(MerlotLevel level) {
		innerLevel = level;
	}

	public MerlotPlatform(MerlotJsonObject json) throws IOException {
		super(json);

		MerlotJsonArray b = json.getArray("b");

		if(b.size() > 0) {
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
			g2d.setColor(Color.GRAY);
			for(MerlotBoundary b : boundaries) {
				b.draw(g2d);
			}
		}

		if(innerLevel != null) {
			g2d.setColor(Color.PINK);
			g2d.drawRect(x + 1, y + 1, width - 2, height - 2);
		}
	}

	@Override
	public void translate(int dx, int dy) {
		super.translate(dx, dy);
		for(MerlotBoundary b : boundaries) {
			b.translate(dx, dy);
		}
	}

	@SuppressWarnings("unchecked")
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
