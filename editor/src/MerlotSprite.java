import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class MerlotSprite implements Selectable {
	public static final Color SELECTED_COLOR = Color.BLUE; //new Color(0, 0, 255, 200);

	protected int x, y;
	protected int width, height;
	boolean selected = false;
	boolean hasFrames = false;

	String imgfilename;
	MerlotJsonObject json = null;
	BufferedImage img = null;

	public MerlotSprite() {
	}

	public MerlotSprite(String filename) throws IOException {
		imgfilename = filename;

		x = y = 0;

		img = ImageIO.read(new File(Meditor.APP_ROOT, imgfilename));

		width = img.getWidth();
		height = img.getHeight();
	}

	public MerlotSprite(MerlotJsonObject json) throws IOException {
		this.json = json;

		imgfilename = json.getStr(getImageKey());

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

		img = ImageIO.read(new File(Meditor.APP_ROOT, imgfilename));

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

	@Override
	public boolean shouldSelect(int cx, int cy) {
		int ix = cx - x; // canvasx, canvasy
		int iy = cy - y;
		return ix >= 0 && ix < width && iy >= 0 && iy < height;
	}

	@Override
	public void select(boolean on) {
		this.selected = on;
	}

	@Override
	public void translate(int dx, int dy) {
		this.x += dx;
		this.y += dy;
	}

	@Override
	public int getX() {
		return x;
	}

	@Override
	public int getY() {
		return y;
	}

	@Override
	public int getWidth() {
		return width;
	}

	@Override
	public int getHeight() {
		return height;
	}

	@Override
	public String toString() {
		String imgname = imgfilename;
		if(imgname != null)
			imgname = imgname.substring(imgname.lastIndexOf('/') + 1, imgname.lastIndexOf('.'));
		return String.format("%d,%d %s", x, y, imgname == null ? getClass().getSimpleName() : imgname);
	}
}
