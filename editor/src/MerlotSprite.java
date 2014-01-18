import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class MerlotSprite {
	public static final Color SELECTED_COLOR = Color.BLUE; //new Color(0, 0, 255, 200);

	int x, y;
	int width, height;
	boolean selected = false;
	boolean hasFrames = false;

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

		if(json.hasKey("h") && json.hasKey("w")) {
			width = json.getInt("w");
			height = json.getInt("h");
		} else {
			width = img.getWidth();
			height = img.getHeight();
		}

		hasFrames = width != img.getWidth() || height != img.getHeight();
	}

	private String getImageKey() {
		return json.hasKey("f") ? "f" : "background";
	}

	public void draw(Graphics2D g2d) {
		if(!hasFrames) {
			g2d.drawImage(img, x, y, null);
		} else {
			g2d.drawImage(img, x, y, x + width, y + height, 0, 0, width, height, null);
		}

		if(selected) {
			g2d.setColor(SELECTED_COLOR);
			g2d.drawRect(x, y, width, height);
		}
	}

	public boolean containsPoint(int cx, int cy) {
		int ix = cx - x; // canvasx, canvasy
		int iy = cy - y;
		int iw = img.getWidth();
		int ih = img.getHeight();
		return ix >= 0 && ix < iw && iy >= 0 && iy < ih;
	}
}
