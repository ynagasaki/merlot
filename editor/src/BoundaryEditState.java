import java.awt.*;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;

public class BoundaryEditState extends MeditorState {
	private static class BoundaryNub implements Selectable {
		Point pos;
		MerlotBoundary boundary;
		boolean selected = false;

		public BoundaryNub(MerlotBoundary b, Point p) {
			boundary = b;
			pos = p;
		}
		@Override
		public void select(boolean on) {
			selected = on;
		}
		@Override
		public boolean shouldSelect(int x, int y) {
			int dx = x - this.pos.x;
			int dy = y - this.pos.y;
			return Math.sqrt(dx*dx + dy*dy) < 10;
		}
		@Override
		public void translate(int dx, int dy) {
 			pos.x += dx; pos.y += dy;
			boundary.calculateBoundaryAttributes();
		}
		@Override
		public int getX() {
			return pos.x;
		}
		@Override
		public int getY() {
			return pos.y;
		}
		@Override
		public int getWidth() {
			return 10;
		}
		@Override
		public int getHeight() {
			return 10;
		}
	}

	MerlotPlatform platform;
	BoundaryNub nub1;
	BoundaryNub nub2;

	public BoundaryEditState(MeditorCanvas canvas, MerlotPlatform target) {
		super(canvas, null);
		platform = target;
	}

	@Override
	public void mousePressed(MouseEvent e) {
		int x = e.getX(), y = e.getY();
		if(nub1 != null && nub1.shouldSelect(x, y)) {
			nub1.select(true);
			selectedItem = nub1;
			parentCanvas.repaint();
		}
		if(nub2 != null && selectedItem == null && nub2.shouldSelect(x, y)) {
			nub2.select(true);
			selectedItem = nub2;
			parentCanvas.repaint();
		}
	}

	@Override
	public void mouseMoved(MouseEvent e) {
		boolean selectionMade = false;
		for(MerlotBoundary boundary : this.platform.boundaries) {
			if(boundary.shouldSelect(e.getX(), e.getY())) {
				boundary.select(true);
				nub1 = new BoundaryNub(boundary, boundary.b1);
				nub2 = new BoundaryNub(boundary, boundary.b2);
				selectionMade = true;

				parentCanvas.repaint();
				break;
			} else {
				boundary.select(false);
			}
		}
		if(!selectionMade) {
			selectedItem = null;
			nub1 = null;
			nub2 = null;
			parentCanvas.repaint();
		}
		super.mouseMoved(e);
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_ESCAPE) {
			for(MerlotBoundary boundary : this.platform.boundaries) {
				boundary.select(false);
			}
			parentCanvas.popState();
		}
		super.keyPressed(e);
	}

	@Override
	public void paint(Graphics2D g2d) {
		int width = parentCanvas.getWidth();
		int height = parentCanvas.getHeight();

		if(platform != null) {
			int x, y;

			g2d.setColor(FOCUS_MASK_COLOR);

			// top
			g2d.fillRect(0, 0, width, platform.y);

			// left
			g2d.fillRect(0, platform.y, platform.x, height - platform.y);

			// right
			x = platform.x + platform.width;
			g2d.fillRect(x, platform.y, width - x, height - platform.y);

			// bottom
			y = platform.y + platform.height;
			g2d.fillRect(platform.x, y, platform.width, height - y);

			// paint nubs
			if(nub1 != null) {
				g2d.setColor(nub1.selected ? Color.YELLOW : Color.RED);
				g2d.fillRect(nub1.pos.x-5,nub1.pos.y-5,10,10);
			}
			if(nub2 != null) {
				g2d.setColor(nub2.selected ? Color.YELLOW : Color.RED);
				g2d.fillRect(nub2.pos.x-5,nub2.pos.y-5,10,10);
			}
		}
	}

	@Override
	public boolean paintStateBelow() {
		return true;
	}
}
