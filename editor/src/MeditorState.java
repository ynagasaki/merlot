import java.awt.*;
import java.awt.event.*;
import java.util.Iterator;

public class MeditorState extends MouseAdapter implements MouseMotionListener, KeyListener {
	public static final Color FOCUS_MASK_COLOR = new Color(0, 0, 0, 100);

	protected Point oldpos = new Point(0,0);
	protected Point selectedItemUnsnappedPosition = new Point(0, 0);
	protected MeditorCanvas parentCanvas;
	protected Selectable selectedItem = null;
	protected MerlotLevel parentLevel = null;

	public MeditorState(MeditorCanvas canvas, MerlotLevel level) {
		parentCanvas = canvas;
		parentLevel = level;
	}

	public MerlotLevel getLevel() {
		return parentLevel;
	}

	@Override
	public void mouseDragged(MouseEvent e) {
		if(selectedItem != null) {
			int dx = e.getX() - oldpos.x;
			int dy = e.getY() - oldpos.y;

			if(parentCanvas.isGridOn()) {
				int oldx = selectedItem.getX();
				int oldy = selectedItem.getY();

				selectedItemUnsnappedPosition.x += dx;
				selectedItemUnsnappedPosition.y += dy;

				int selectedItemNewX = Mutil.floor(selectedItemUnsnappedPosition.x, MeditorGrid.GRID_RESOLUTION);
				int selectedItemNewY = Mutil.floor(selectedItemUnsnappedPosition.y, MeditorGrid.GRID_RESOLUTION);

				if(selectedItemUnsnappedPosition.x % MeditorGrid.GRID_RESOLUTION > MeditorGrid.GRID_SNAP_THRESHOLD) {
					selectedItemNewX += MeditorGrid.GRID_RESOLUTION;
				}

				if(selectedItemUnsnappedPosition.y % MeditorGrid.GRID_RESOLUTION > MeditorGrid.GRID_SNAP_THRESHOLD) {
					selectedItemNewY += MeditorGrid.GRID_RESOLUTION;
				}

				dx = selectedItemNewX - oldx;
				dy = selectedItemNewY - oldy;

				parentCanvas.setGridExtents(oldx, oldy, selectedItem.getWidth(), selectedItem.getHeight());
			}

			selectedItem.translate(dx, dy);

			parentCanvas.repaint();
		}
		oldpos.x = e.getX();
		oldpos.y = e.getY();
	}

	@Override
	public void mouseMoved(MouseEvent e) {
		oldpos.x = e.getX();
		oldpos.y = e.getY();
	}

	@Override
	public void mousePressed(MouseEvent e) {
		if(parentLevel != null) {
			Iterator<MerlotSprite> iter = parentLevel.sprites.descendingIterator();
			while(iter.hasNext()) {
				MerlotSprite spr = iter.next();

				if(spr.shouldSelect(e.getX(), e.getY())) {
					if(selectedItem != null) {
						selectedItem.select(false);
					}
					selectedItem = spr;
					selectedItem.select(true);
					parentCanvas.repaint();
					break;
				}
			}
		}
		if(selectedItem != null) {
			selectedItemUnsnappedPosition.setLocation(selectedItem.getX(), selectedItem.getY());
		}
	}

	@Override
	public void mouseReleased(MouseEvent e) {
	}

	@Override
	public void keyTyped(KeyEvent e) {
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
			parentCanvas.gridOn(true);
			if(selectedItem != null) {
				parentCanvas.setGridExtents(selectedItem.getX(), selectedItem.getY(), selectedItem.getWidth(), selectedItem.getHeight());
				selectedItemUnsnappedPosition.setLocation(selectedItem.getX(), selectedItem.getY());
			}
		}
	}

	@Override
	public void keyReleased(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
			parentCanvas.gridOn(false);
		}
	}

	public void paint(Graphics2D g2d) {
		if(parentLevel != null) {
			parentLevel.draw(g2d);
		}
	}

	public boolean paintStateBelow() {
		return false;
	}
}