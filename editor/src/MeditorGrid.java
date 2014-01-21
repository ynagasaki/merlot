import java.awt.*;

public class MeditorGrid {
	public static final int GRID_RESOLUTION = 10;
	public static final int GRID_SNAP_THRESHOLD = GRID_RESOLUTION / 2;
	public static final int GRID_EXTENT_PADDING = 2;
	public static final int GRID_EXTENT_START_OFFSET = GRID_RESOLUTION * GRID_EXTENT_PADDING;
	public static final int GRID_EXTENT_END_OFFSET = GRID_EXTENT_START_OFFSET * GRID_EXTENT_PADDING;

	public static final Color GRID_COLOR = new Color(0,0,255,152);
	public static final Stroke GRID_STROKE = new BasicStroke(
			1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1f, new float[] { 1f, 1f, 1f, 1f }, 0f
	);

	private Rectangle gridextents = new Rectangle(0, 0, 0, 0);

	public MeditorGrid() {}

	public void setExtents(int x, int y, int width, int height) {
		x -= GRID_EXTENT_START_OFFSET;
		y -= GRID_EXTENT_START_OFFSET;
		width += GRID_EXTENT_END_OFFSET;
		height += GRID_EXTENT_END_OFFSET;
		gridextents.setBounds(x, y, width, height);
	}

	public void paint(Graphics2D g2d, int areaWidth, int areaHeight) {
		g2d.setStroke(GRID_STROKE);
		g2d.setColor(GRID_COLOR);
		for(int x = 0; x <= gridextents.width; x += GRID_RESOLUTION) {
			g2d.drawLine(gridextents.x + x, 0, gridextents.x + x, areaHeight);
		}
		for(int y = 0; y <= gridextents.height; y += GRID_RESOLUTION) {
			g2d.drawLine(0, gridextents.y + y, areaWidth, gridextents.y + y);
		}
	}
}
