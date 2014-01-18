
import org.json.simple.JSONObject;

import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Color;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;

public class MerlotLevel extends MerlotSprite {

	int width, height;

	Point startPoint = null;

	Deque<MerlotSprite> sprites = new ArrayDeque<MerlotSprite>();

	public MerlotLevel(MerlotJsonObject leveljson) throws IOException {
		super(leveljson);

		this.width = leveljson.getInt("width");
		this.height = leveljson.getInt("height");

		MerlotJsonArray startpt = leveljson.getArray("startpt");
		this.startPoint = new Point(startpt.getInt(0), startpt.getInt(1));

		/* load sprites */
		MerlotJsonArray.eachfunc<JSONObject> loadsprite = new MerlotJsonArray.eachfunc<JSONObject>() {
			@Override
			public boolean process(JSONObject item) {
				MerlotJsonObject sprobj = new MerlotJsonObject(item);
				try {
					sprites.add(new MerlotSprite(sprobj));
				} catch(IOException ex) {
					System.out.println("*Error loading sprite: " + sprobj.getStr("f"));
					ex.printStackTrace();
					return false;
				}
				return true;
			}
		};

		MerlotJsonArray.each(leveljson.getArray("nutcoins"), loadsprite);
		MerlotJsonArray.each(leveljson.getArray("platforms"), loadsprite);
		MerlotJsonArray.each(leveljson.getArray("npcs"), loadsprite);
	}

	@Override
	public void draw(Graphics2D g2d) {
		super.draw(g2d);

		for(MerlotSprite spr : sprites) {
			spr.draw(g2d);
		}

		g2d.setColor(Color.GREEN);
		g2d.fillRect(this.startPoint.x, this.startPoint.y, Meditor.PLAYER_WIDTH, Meditor.PLAYER_HEIGHT);
	}
}
