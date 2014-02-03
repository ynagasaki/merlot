import java.awt.*;

public class ColoredRectSprite extends MerlotSprite {
	Color color = null;

	public void set(Color color, int x, int y, int width, int height) {
		this.color = color;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	@Override
	public void draw(Graphics2D g2d) {
		g2d.setColor(color);
		g2d.fillRect(x, y, width, height);
		if(selected) {
			g2d.setColor(SELECTED_COLOR);
			g2d.drawRect(x, y, width, height);
		}
	}
}
