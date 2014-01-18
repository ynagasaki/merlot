import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class MerlotLevel {

	int width, height;

	Point startPoint = null;

	BufferedImage backgroundImage = null;

	JSONObject levelJson = null;

	public MerlotLevel(JSONObject leveljson) throws IOException {
		this.levelJson = leveljson;

		this.backgroundImage = ImageIO.read(new File(Meditor.APP_ROOT + (String) leveljson.get("background")));

		this.width = Mutil.getIntValueFromJson(leveljson, "width", 0);
		this.height = Mutil.getIntValueFromJson(leveljson, "height", 0);

		JSONArray startpt = (JSONArray) leveljson.get("startpt");
		this.startPoint = new Point(Mutil.getIntValueFromJson(startpt, 0, 0), Mutil.getIntValueFromJson(startpt, 1, 0));
	}

	public void draw(Graphics2D g2d) {
		g2d.drawImage(this.backgroundImage, 0, 0, null);
		g2d.drawRect(this.startPoint.x, this.startPoint.y, Meditor.PLAYER_WIDTH, Meditor.PLAYER_HEIGHT);
	}
}
