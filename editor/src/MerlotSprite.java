import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class MerlotSprite {
	int x, y;
	String filename;
	MerlotJsonObject json = null;
	BufferedImage img = null;

	public MerlotSprite(MerlotJsonObject json) throws IOException {
		this.json = json;

		filename = json.getStr(getImageKey());

		if(json.hasKey("p")) {
			MerlotJsonArray p = json.getArray("p");
			x = p.getInt(0);
			y = p.getInt(1);
		} else if(json.hasKey("x") && json.hasKey("y")) {
			x = json.getInt("x");
			y = json.getInt("y");
		} else {
			x = y = 0;
		}

		img = ImageIO.read(new File(Meditor.APP_ROOT + filename));
	}

	private String getImageKey() {
		return json.hasKey("f") ? "f" : "background";
	}

	public void draw(Graphics2D g2d) {
		g2d.drawImage(img, x, y, null);
	}
}
