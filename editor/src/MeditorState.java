import java.awt.*;
import java.awt.event.*;
import java.util.Iterator;

public class MeditorState extends MouseAdapter implements MouseMotionListener, KeyListener {
	public static int GRID_EXTENT_PADDING = 2;
	public static int GRID_EXTENT_START_OFFSET = MeditorCanvas.GRID_RESOLUTION * GRID_EXTENT_PADDING;
	public static int GRID_EXTENT_END_OFFSET = GRID_EXTENT_START_OFFSET * GRID_EXTENT_PADDING;

	protected Point oldpos = new Point(0,0);
	protected Point selectedItemUnsnappedPosition = new Point(0, 0);
	protected MeditorCanvas parentCanvas;
	protected Selectable selectedItem = null;

	public MeditorState(MeditorCanvas canvas) {
		this.parentCanvas = canvas;
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

				int selectedItemNewX = Mutil.floor(selectedItemUnsnappedPosition.x, MeditorCanvas.GRID_RESOLUTION);
				int selectedItemNewY = Mutil.floor(selectedItemUnsnappedPosition.y, MeditorCanvas.GRID_RESOLUTION);

				if(selectedItemUnsnappedPosition.x % MeditorCanvas.GRID_RESOLUTION > MeditorCanvas.GRID_SNAP_THRESHOLD){
					selectedItemNewX += MeditorCanvas.GRID_RESOLUTION;
				}

				if(selectedItemUnsnappedPosition.y % MeditorCanvas.GRID_RESOLUTION > MeditorCanvas.GRID_SNAP_THRESHOLD){
					selectedItemNewY += MeditorCanvas.GRID_RESOLUTION;
				}

				dx = selectedItemNewX - oldx;
				dy = selectedItemNewY - oldy;

				Rectangle gridextents = parentCanvas.getGridExtents();

				gridextents.x = oldx - GRID_EXTENT_START_OFFSET;
				gridextents.y = oldy - GRID_EXTENT_START_OFFSET;
				gridextents.width = selectedItem.getWidth() + GRID_EXTENT_END_OFFSET; // i'm not even sure this makes
				gridextents.height = selectedItem.getHeight() + GRID_EXTENT_END_OFFSET; // sense, lol
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
		if(selectedItem != null) {
			selectedItemUnsnappedPosition.setLocation(selectedItem.getX(), selectedItem.getY());
		}
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		MerlotLevel level = parentCanvas.getLevel();
		if(level != null) {
			Iterator<MerlotSprite> iter = level.sprites.descendingIterator();
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
	}

	@Override
	public void keyTyped(KeyEvent e) {
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
			parentCanvas.gridOn(true);
			if(selectedItem != null) {
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
}