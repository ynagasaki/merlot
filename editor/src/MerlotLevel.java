
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.awt.Graphics2D;
import java.awt.Color;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;

public class MerlotLevel extends MerlotSprite {

	int width, height;

	ColoredRectSprite startPointSprite = new ColoredRectSprite();

	Deque<MerlotSprite> sprites = new ArrayDeque<MerlotSprite>();

	public MerlotLevel(MerlotJsonObject leveljson) throws IOException {
		super(leveljson);

		this.width = leveljson.getInt("width");
		this.height = leveljson.getInt("height");

		MerlotJsonArray startpt = leveljson.getArray("startpt");
		this.startPointSprite.set(Color.GREEN, startpt.getInt(0), startpt.getInt(1), Meditor.PLAYER_WIDTH, Meditor.PLAYER_HEIGHT);

		/* load sprites */
		MerlotJsonArray.eachfunc<JSONObject, String> loadsprite = new MerlotJsonArray.eachfunc<JSONObject, String>() {
			@Override
			public boolean process(JSONObject item) {
				MerlotJsonObject sprobj = new MerlotJsonObject(item);
				try {
					if(arg != null && arg.equalsIgnoreCase("platforms")) {
						sprites.add(new MerlotPlatform(sprobj));
					} else {
						sprites.add(new MerlotSprite(sprobj));
					}
				} catch(IOException ex) {
					System.out.println("*Error loading sprite: " + sprobj.getStr("f"));
					ex.printStackTrace();
					return false;
				}
				return true;
			}
		};

		this.sprites.clear();

		String [] keys = new String[] {"nutcoins", "platforms", "npcs"};
		for(String key : keys) {
			loadsprite.setarg(key);
			MerlotJsonArray.each(leveljson.getArray(key), loadsprite);
		}

		sprites.add(startPointSprite);
	}

	@Override
	public void draw(Graphics2D g2d) {
		super.draw(g2d);

		for(MerlotSprite spr : sprites) {
			spr.draw(g2d);
		}

		startPointSprite.draw(g2d);
	}

	public String getFilename() {
		return Meditor.APP_ROOT + this.json.getStr("id");
	}

	public JSONObject toJson() {
		JSONObject json = new JSONObject();

		json.put("id", this.json.getStr("id"));
		json.put("width", width);
		json.put("height", height);
		json.put("background", imgfilename);

		json.put("startpt", Mutil.makeJsonArray(startPointSprite.getX(), startPointSprite.getY()));

		JSONArray nutcoins = new JSONArray();
		JSONArray platforms = new JSONArray();
		JSONArray npcs = new JSONArray();

		for(MerlotSprite spr : sprites) {
			if(spr instanceof ColoredRectSprite) {
				continue;
			} else if(spr instanceof  MerlotPlatform) {
				platforms.add(((MerlotPlatform) spr).toJson());
			} else if(spr.imgfilename.contains("coin")) {
				JSONObject nc = new JSONObject();
				nc.put("f", spr.imgfilename);
				nc.put("p", Mutil.makeJsonArray(spr.getX(), spr.getY()));
				nutcoins.add(nc);
			} else if(spr.imgfilename.contains("baddies")) {
				JSONObject b = new JSONObject();
				b.put("f", spr.imgfilename);
				b.put("x", spr.getX());
				b.put("y", spr.getY());
				b.put("w", spr.getWidth());
				b.put("h", spr.getHeight());
				npcs.add(b);
			}
		}

		json.put("nutcoins", nutcoins);
		json.put("npcs", npcs);
		json.put("platforms", platforms);

		json.put("gates", new JSONArray());
		json.put("boundaries", new JSONArray());
		json.put("innerlevels", new JSONArray());

		return json;
	}
}
