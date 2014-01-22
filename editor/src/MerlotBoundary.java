
import java.awt.*;

public class MerlotBoundary implements Selectable {
	public static final String BOUNDARY_KEY = "s";
	public static final String NORMAL_KEY = "n";

	public static final BasicStroke DESELECTED_LINE = new BasicStroke(1f);
	public static final BasicStroke SELECTED_LINE = new BasicStroke(2f);

	private boolean selected = false;

	Point b1 = new Point(0, 0);
	Point b2 = new Point(0, 0);
	//Point n1 = new Point(0, 0);
	//Point n2 = new Point(0, 0);

	Point topmost, leftmost, rightmost, bottommost;

	Double slope = null;
	Double intercept = null;

	public MerlotBoundary(MerlotJsonObject json) {
		MerlotJsonArray b = json.getArray(BOUNDARY_KEY);
		MerlotJsonArray n = json.getArray(NORMAL_KEY);

		b1.setLocation(b.getInt(0), b.getInt(1));
		b2.setLocation(b.getInt(2), b.getInt(3));

		//n1.setLocation(n.getInt(0), n.getInt(1));
		//n2.setLocation(n.getInt(2), n.getInt(3));

		calculateBoundaryAttributes();
	}

	public void draw(Graphics2D g2d) {
		if(selected) {
			g2d.setStroke(SELECTED_LINE);
			g2d.setColor(Color.RED);
		}
		g2d.drawLine(b1.x, b1.y, b2.x, b2.y);
		g2d.setStroke(DESELECTED_LINE);
		g2d.setColor(Color.GRAY);
	}

	@Override
	public boolean shouldSelect(int cx, int cy) {
		double dist = Math.abs(((double) cy - slope * (double) cx - intercept) / Math.sqrt(slope * slope + 1.0));
		return dist < 10.0 && cx > leftmost.x - 10 && cx < rightmost.x + 10 && cy > topmost.y - 10 && cy < bottommost.y + 10;
	}

	@Override
	public void select(boolean on) {
		this.selected = on;
	}

	@Override
	public void translate(int dx, int dy) {
		b1.translate(dx, dy);
		b2.translate(dx, dy);
		//n1.translate(dx, dy);
		//n2.translate(dx, dy);
		calculateBoundaryAttributes();
	}

	@Override
	public int getX() {
		return leftmost.x;
	}

	@Override
	public int getY() {
		return topmost.y;
	}

	@Override
	public int getWidth() {
		return rightmost.x - leftmost.x;
	}

	@Override
	public int getHeight() {
		return topmost.y - bottommost.y;
	}

	public void calculateBoundaryAttributes() {
		rightmost = b1.x > b2.x ? b1 : b2;
		leftmost = b1.x > b2.x ? b2 : b1;
		topmost = b1.y > b2.y ? b2 : b1;
		bottommost = b1.y > b2.y ? b1 : b2;

		if(Math.abs(b2.x - b2.y) > 0.00001) {
			slope =  (double) (b2.y - b1.y) / (double) (b2.x - b2.y);
		}

		if(slope != null) {
			intercept = (double) b1.y - slope * (double) b1.x;
		}
	}
}
