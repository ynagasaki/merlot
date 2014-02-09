
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import java.awt.Graphics2D;
import java.awt.Color;
import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;

public class MerlotLevel extends MerlotSprite {

	String id;

	ColoredRectSprite startPointSprite = null;

	Deque<MerlotSprite> sprites = new ArrayDeque<>();
	Integer innerLevelCount = 0;

	public MerlotLevel(String id, String bgfilename) throws IOException {
		super(bgfilename);
		this.id = id;
	}

	public MerlotLevel(MerlotJsonObject leveljson) throws IOException {
		super(leveljson);

		this.id = this.json.getStr("id");
		this.width = leveljson.getInt("width");
		this.height = leveljson.getInt("height");

		if(leveljson.hasKey("x")) this.x = leveljson.getInt("x");
		if(leveljson.hasKey("y")) this.y = leveljson.getInt("y");

		if(leveljson.hasKey("startpt")) {
			startPointSprite = new ColoredRectSprite();
			MerlotJsonArray startpt = leveljson.getArray("startpt");
			this.startPointSprite.set(
					Color.GREEN,
					startpt.getInt(0),
					startpt.getInt(1),
					Meditor.PLAYER_WIDTH,
					Meditor.PLAYER_HEIGHT
			);
		}

		/* load sprites */
		MerlotJsonArray.eachfunc<JSONObject, String> loadsprite = new MerlotJsonArray.eachfunc<JSONObject, String>() {
			@Override
			public boolean process(JSONObject item) {
				MerlotJsonObject sprobj = new MerlotJsonObject(item);
				try {
					if(arg != null && arg.equalsIgnoreCase("platforms")) {
						sprites.addLast(new MerlotPlatform(sprobj));
					} else {
						sprites.addLast(new MerlotSprite(sprobj));
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

		String [] keys = new String[] {"platforms", "nutcoins", "npcs"};
		for(String key : keys) {
			loadsprite.setarg(key);
			MerlotJsonArray.each(leveljson.getArray(key), loadsprite);
		}

		if(startPointSprite != null) sprites.add(startPointSprite);

		/* load inner levels and associate them with plats */
		MerlotJsonArray innerlevels = leveljson.getArray("innerlevels");
		MerlotJsonArray.each(innerlevels, new MerlotJsonArray.eachfunc<JSONObject, String>() {
			@Override
			boolean process(JSONObject item) {
				try {
					MerlotJsonObject jsonobj = new MerlotJsonObject(item);
					MerlotLevel lvl = new MerlotLevel(jsonobj);

					// Figure out which platform this level belongs to
					for(MerlotSprite pspr : sprites) {
						if(pspr instanceof MerlotPlatform && pspr.shouldSelect(pspr.getX(), pspr.getY())) {
							((MerlotPlatform) pspr).setAssociatedInnerLevel(lvl);
							innerLevelCount += 1;
							break;
						}
					}
				} catch (IOException e) {
					System.out.println("*Error: failed to load inner level.");
					e.printStackTrace();
					return false;
				}
				return true;
			}
		});
	}

	@Override
	public void draw(Graphics2D g2d) {
		super.draw(g2d);

		for(MerlotSprite spr : sprites) {
			spr.draw(g2d);
		}

		if(startPointSprite != null) startPointSprite.draw(g2d);
	}

	public String getId() {
		return this.id;
	}

	@SuppressWarnings("unchecked")
	public JSONObject toJson() {
		JSONObject json = new JSONObject();

		json.put("id", id);
		json.put("width", width);
		json.put("height", height);
		json.put("background", imgfilename);

		if(startPointSprite != null) {
			json.put("startpt", Mutil.makeJsonArray(startPointSprite.getX(), startPointSprite.getY()));
		}

		JSONArray nutcoins = new JSONArray();
		JSONArray platforms = new JSONArray();
		JSONArray npcs = new JSONArray();
		JSONArray innerlevels = new JSONArray();

		for(MerlotSprite spr : sprites) {
			if(spr instanceof ColoredRectSprite) {
				continue;
			}

			if(spr instanceof  MerlotPlatform) {
				MerlotPlatform plat = (MerlotPlatform) spr;
				MerlotLevel innerlvl = plat.getAssociatedInnerLevel();

				platforms.add(plat.toJson());

				if(innerlvl != null) {
					JSONObject iljson = innerlvl.toJson();
					iljson.remove("startpt");
					iljson.put("x", innerlvl.getX());
					iljson.put("y", innerlvl.getY());
					innerlevels.add(iljson);
				}
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
		json.put("innerlevels", innerlevels);

		return json;
	}
}
