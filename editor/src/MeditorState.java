import java.awt.*;
import java.awt.event.*;
import java.util.Iterator;

public class MeditorState extends MouseAdapter implements MouseMotionListener, KeyListener {
	public static final int GRID_RESOLUTION = 10;
	public static final int GRID_SNAP_THRESHOLD = GRID_RESOLUTION / 2;
	public static final int GRID_EXTENT_PADDING = 2;
	public static final int GRID_EXTENT_START_OFFSET = GRID_RESOLUTION * GRID_EXTENT_PADDING;
	public static final int GRID_EXTENT_END_OFFSET = GRID_EXTENT_START_OFFSET * GRID_EXTENT_PADDING;

	public static final Color GRID_COLOR = new Color(0,0,255,152);
	public static final Stroke GRID_STROKE = new BasicStroke(
			1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1f, new float[] { 1f, 1f, 1f, 1f }, 0f
	);

	public static final Color FOCUS_MASK_COLOR = new Color(0, 0, 0, 100);

	protected boolean gridon = false;
	protected Rectangle gridextents = new Rectangle(0, 0, 0, 0);

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

			if(gridon) {
				int oldx = selectedItem.getX();
				int oldy = selectedItem.getY();

				selectedItemUnsnappedPosition.x += dx;
				selectedItemUnsnappedPosition.y += dy;

				int selectedItemNewX = Mutil.floor(selectedItemUnsnappedPosition.x, GRID_RESOLUTION);
				int selectedItemNewY = Mutil.floor(selectedItemUnsnappedPosition.y, GRID_RESOLUTION);

				if(selectedItemUnsnappedPosition.x % GRID_RESOLUTION > GRID_SNAP_THRESHOLD){
					selectedItemNewX += GRID_RESOLUTION;
				}

				if(selectedItemUnsnappedPosition.y % GRID_RESOLUTION > GRID_SNAP_THRESHOLD){
					selectedItemNewY += GRID_RESOLUTION;
				}

				dx = selectedItemNewX - oldx;
				dy = selectedItemNewY - oldy;

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
			gridOn(true);
			if(selectedItem != null) {
				selectedItemUnsnappedPosition.setLocation(selectedItem.getX(), selectedItem.getY());
			}
		}
	}

	@Override
	public void keyReleased(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
			gridOn(false);
		}
	}

	public void paint(Graphics2D g2d) {
		MerlotLevel level = parentCanvas.getLevel();
		level.draw(g2d);

		if(gridon) {
			int width = parentCanvas.getWidth();
			int height = parentCanvas.getHeight();

			g2d.setStroke(GRID_STROKE);
			g2d.setColor(GRID_COLOR);
			for(int x = 0; x <= gridextents.width; x += GRID_RESOLUTION) {
				g2d.drawLine(gridextents.x + x, 0, gridextents.x + x, height);
			}
			for(int y = 0; y <= gridextents.height; y += GRID_RESOLUTION) {
				g2d.drawLine(0, gridextents.y + y, width, gridextents.y + y);
			}
		}
	}

	public boolean paintStateBelow() {
		return false;
	}

	public void gridOn(boolean on) {
		MerlotLevel level = parentCanvas.getLevel();
		gridon = on;
		gridextents.setBounds(0, 0, level.width, level.height);
		parentCanvas.repaint();
	}
}