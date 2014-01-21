import java.awt.*;
import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;

public class BoundaryEditState extends MeditorState {
	MerlotPlatform platform;

	public BoundaryEditState(MeditorCanvas canvas, MerlotPlatform target) {
		super(canvas);

		platform = target;
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		boolean selectionMade = false;
		for(MerlotBoundary boundary : this.platform.boundaries) {
			if(boundary.shouldSelect(e.getX(), e.getY())) {
				if(selectedItem != null) {
					selectedItem.select(false);
				}
				selectedItem = boundary;
				boundary.select(true);
				selectionMade = true;
				break;
			}
		}

		if(!selectionMade && selectedItem != null) {
			selectedItem.select(false);
			selectedItem = null;
		}

		parentCanvas.repaint();
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_ESCAPE) {
			if(selectedItem != null) {
				selectedItem.select(false);
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
		}
	}

	@Override
	public boolean paintStateBelow() {
		return true;
	}
}
