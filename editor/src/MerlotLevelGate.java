
public class MerlotLevelGate extends ColoredRectSprite {
	String level1_id, level2_id;

	public MerlotLevelGate(MerlotLevel l1, MerlotLevel l2) {
		this.level1_id = l1.getId();
		this.level2_id = l2.getId();
	}

	public MerlotLevelGate(MerlotJsonObject json) {
		level1_id = json.getStr("level1_id");
		level2_id = json.getStr("level2_id");
		x = json.getInt("x");
		y = json.getInt("y");
	}

	@Override
	public int getWidth() {
		return Meditor.PLAYER_WIDTH;
	}

	@Override
	public int getHeight() {
		return Meditor.DEFAULT_HEIGHT;
	}
}
