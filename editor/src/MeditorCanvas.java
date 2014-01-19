
import java.awt.*;
import java.awt.event.*;
import java.util.Iterator;

public class MeditorCanvas extends Canvas {
	private static final int GRID_RESOLUTION = 10;
	private static final Color GRID_COLOR = new Color(255,255,255,100);
	private static final Stroke GRID_STROKE = new BasicStroke(
			1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1f, new float[] { 1f, 1f, 1f, 1f }, 0f
	);

	private MerlotLevel level = null;
	private Selectable selectedItem = null;
	private boolean gridon = false;

	public MeditorCanvas() {
		final MeditorCanvas canvas = this;

		this.addMouseListener(new MouseListener() {
			@Override
			public void mouseClicked(MouseEvent e) {
			}

			@Override
			public void mousePressed(MouseEvent e) {
			}

			@Override
			public void mouseReleased(MouseEvent e) {
				canvas.onClick(e.getX(), e.getY());
			}

			@Override
			public void mouseEntered(MouseEvent e) {
			}

			@Override
			public void mouseExited(MouseEvent e) {
			}
		});
		this.addMouseMotionListener(new MouseMotionListener() {
			Point oldpos = new Point(0,0);
			@Override
			public void mouseDragged(MouseEvent e) {
				if(selectedItem != null) {
					int dx = e.getX() - oldpos.x;
					int dy = e.getY() - oldpos.y;

					selectedItem.translate(dx, dy);

					canvas.repaint();
				}
				oldpos.x = e.getX();
				oldpos.y = e.getY();
			}
			@Override
			public void mouseMoved(MouseEvent e) {
				oldpos.x = e.getX();
				oldpos.y = e.getY();
			}
		});
		this.addKeyListener(new KeyListener() {
			@Override
			public void keyTyped(KeyEvent e) {
			}
			@Override
			public void keyPressed(KeyEvent e) {
				if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
					canvas.gridOn(true);
				}
			}
			@Override
			public void keyReleased(KeyEvent e) {
				if(e.getKeyCode() == KeyEvent.VK_SHIFT) {
					canvas.gridOn(false);
				}
			}
		});
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

	public void gridOn(boolean on) {
		gridon = on;
		this.repaint();
	}

	public void setLevel(MerlotLevel level) {
		this.level = level;
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
				for(int x = 0; x <= width; x += GRID_RESOLUTION) g2d.drawLine(x,0,x,height);
				for(int y = 0; y <= height; y += GRID_RESOLUTION) g2d.drawLine(0,y,width,y);
			}
		} else {
			g2d.setColor(Color.DARK_GRAY);
			g2d.drawString("Hello, fart face.", 20, 20);
		}
	}
}