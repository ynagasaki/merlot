
import java.awt.*;
import java.awt.event.*;
import java.util.Iterator;

public class MeditorCanvas extends Canvas {
	private static final int GRID_RESOLUTION = 10;
	private static final int GRID_SNAP_THRESHOLD = GRID_RESOLUTION / 2;
	private static final Color GRID_COLOR = new Color(0,0,152,152);
	private static final Stroke GRID_STROKE = new BasicStroke(
			1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1f, new float[] { 1f, 1f, 1f, 1f }, 0f
	);

	private static class InputListener extends MouseAdapter implements MouseMotionListener, KeyListener {
		Point oldpos = new Point(0,0);
		Point selectedItemUnsnappedPosition = new Point(0, 0);
		MeditorCanvas parentCanvas;

		public InputListener(MeditorCanvas canvas) {
			this.parentCanvas = canvas;
		}

		@Override
		public void mouseDragged(MouseEvent e) {
			Selectable selected = parentCanvas.getSelectedItem();
			if(selected != null) {
				int dx = e.getX() - oldpos.x;
				int dy = e.getY() - oldpos.y;

				if(parentCanvas.gridon) {
					int oldx = selected.getX();
					int oldy = selected.getY();

					selectedItemUnsnappedPosition.x += dx;
					selectedItemUnsnappedPosition.y += dy;

					int selectedItemNewX, selectedItemNewY;

					if(selectedItemUnsnappedPosition.x % GRID_RESOLUTION > GRID_SNAP_THRESHOLD) {
						selectedItemNewX = selectedItemUnsnappedPosition.x / GRID_RESOLUTION * GRID_RESOLUTION + GRID_RESOLUTION;
					} else {
						selectedItemNewX = selectedItemUnsnappedPosition.x / GRID_RESOLUTION * GRID_RESOLUTION;
					}

					if(selectedItemUnsnappedPosition.y % GRID_RESOLUTION > GRID_SNAP_THRESHOLD) {
						selectedItemNewY = selectedItemUnsnappedPosition.y / GRID_RESOLUTION * GRID_RESOLUTION + GRID_RESOLUTION;
					} else {
						selectedItemNewY = selectedItemUnsnappedPosition.y / GRID_RESOLUTION * GRID_RESOLUTION;
					}

					dx = selectedItemNewX - oldx;
					dy = selectedItemNewY - oldy;

					Rectangle gridextents = parentCanvas.getGridExtents();

					gridextents.x = oldx - GRID_RESOLUTION * 2;
					gridextents.y = oldy - GRID_RESOLUTION * 2;
					gridextents.width = selected.getWidth() + GRID_RESOLUTION * 4;
					gridextents.height = selected.getHeight() + GRID_RESOLUTION * 4;
				}

				selected.translate(dx, dy);

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
			Selectable selected = parentCanvas.getSelectedItem();
			if(selected != null) {
				selectedItemUnsnappedPosition.setLocation(selected.getX(), selected.getY());
			}
		}
		@Override
		public void mouseReleased(MouseEvent e) {
			parentCanvas.onClick(e.getX(), e.getY());
		}
		@Override
		public void keyTyped(KeyEvent e) {
		}
		@Override
		public void keyPressed(KeyEvent e) {
			if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
				parentCanvas.gridOn(true);
				Selectable selected = parentCanvas.getSelectedItem();
				if(selected != null) {
					selectedItemUnsnappedPosition.setLocation(selected.getX(), selected.getY());
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

	private MerlotLevel level = null;
	private Selectable selectedItem = null;
	private boolean gridon = false;
	private Rectangle gridextents = new Rectangle(0, 0, 0, 0);

	public MeditorCanvas() {
		InputListener canvasListener = new InputListener(this);

		this.addMouseListener(canvasListener);
		this.addMouseMotionListener(canvasListener);
		this.addKeyListener(canvasListener);
	}

	public void onClick(int x, int y) {
		if(level != null) {
			Iterator<MerlotSprite> iter = level.sprites.descendingIterator();
			while(iter.hasNext()) {
				MerlotSprite spr = iter.next();

				if(spr.shouldSelect(x, y)) {
					if(selectedItem != null) {
						selectedItem.select(false);
					}
					selectedItem = spr;
					selectedItem.select(true);
					repaint();
					break;
				}
			}
		}
	}

	public Selectable getSelectedItem() {
		return selectedItem;
	}

	public void setSelectedItem(Selectable selectedItem) {
		this.selectedItem = selectedItem;
	}

	public Rectangle getGridExtents() {
		return gridextents;
	}

	public void gridOn(boolean on) {
		gridon = on;
		this.gridextents.setBounds(0, 0, level.width, level.height);
		this.repaint();
	}

	public void setLevel(MerlotLevel lvl) {
		this.level = lvl;
		this.gridextents.setBounds(0, 0, level.width, level.height);
		this.setPreferredSize(new Dimension(level.width, level.height));

		this.getParent().setPreferredSize(new Dimension(level.width, level.height));
		this.getParent().revalidate();
		this.repaint();
	}

	@Override
	public void paint(Graphics g) {
		int width = this.getWidth();
		int height = this.getHeight();
		Graphics2D g2d = (Graphics2D) g;

		if(this.level != null) {
			this.level.draw(g2d);

			if(gridon) {
				g2d.setStroke(GRID_STROKE);
				g2d.setColor(GRID_COLOR);
				for(int x = 0; x <= gridextents.width; x += GRID_RESOLUTION) {
					g2d.drawLine(gridextents.x + x, 0, gridextents.x + x, height);
				}
				for(int y = 0; y <= gridextents.height; y += GRID_RESOLUTION) {
					g2d.drawLine(0, gridextents.y + y, width, gridextents.y + y);
				}
			}
		} else {
			g2d.setColor(Color.DARK_GRAY);
			g2d.drawString("Hello, fart face.", 20, 20);
		}
	}
}