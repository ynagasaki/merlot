import org.json.simple.JSONObject;

import java.awt.*;

public class MerlotLevelGate extends ColoredRectSprite {
	String level1_id, level2_id;

	public MerlotLevelGate(MerlotLevel l1, MerlotLevel l2) {
		this.level1_id = l1.getId();
		this.level2_id = l2.getId();
		set(Color.PINK, 0, 0, Meditor.PLAYER_WIDTH, Meditor.PLAYER_HEIGHT);
	}

	public MerlotLevelGate(MerlotJsonObject json) {
		level1_id = json.getStr("level1_id");
		level2_id = json.getStr("level2_id");
		x = json.getInt("x");
		y = json.getInt("y");
		set(Color.PINK, x, y, Meditor.PLAYER_WIDTH, Meditor.PLAYER_HEIGHT);
	}

	@SuppressWarnings("unchecked")
	public JSONObject toJson() {
		JSONObject json = new JSONObject();

		json.put("level1_id", level1_id);
		json.put("level2_id", level2_id);
		json.put("x", x);
		json.put("y", y);

		return json;
	}
}
