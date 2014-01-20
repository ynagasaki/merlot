
import java.awt.*;
import java.util.ArrayDeque;
import java.util.Deque;

public class MeditorCanvas extends Canvas {
	public static final int GRID_RESOLUTION = 10;
	public static final int GRID_SNAP_THRESHOLD = GRID_RESOLUTION / 2;

	private static final Color GRID_COLOR = new Color(0,0,255,152);
	private static final Stroke GRID_STROKE = new BasicStroke(
			1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1f, new float[] { 1f, 1f, 1f, 1f }, 0f
	);

	private MerlotLevel level = null;
	private boolean gridon = false;
	private Rectangle gridextents = new Rectangle(0, 0, 0, 0);

	private Deque<MeditorState> stateStack = new ArrayDeque<MeditorState>(4);

	public MeditorCanvas() {
		pushState(new MeditorState(this));
	}

	public void pushState(MeditorState state) {
		if(stateStack.size() > 0) {
			MeditorState curr = stateStack.peekFirst();
			this.removeMouseListener(curr);
			this.removeMouseMotionListener(curr);
			this.removeKeyListener(curr);
		}

		stateStack.push(state);
		this.addMouseListener(state);
		this.addMouseMotionListener(state);
		this.addKeyListener(state);
	}

	public void popState() {
		if(stateStack.size() > 1) {
			MeditorState state = stateStack.removeFirst();
			this.removeMouseListener(state);
			this.removeMouseMotionListener(state);
			this.removeKeyListener(state);

			state = stateStack.peekFirst();
			this.addMouseListener(state);
			this.addMouseMotionListener(state);
			this.addKeyListener(state);
		}
	}

	public Selectable getSelectedItem() {
		return stateStack.peekFirst().selectedItem;
	}

	public MerlotLevel getLevel() {
		return level;
	}

	public Rectangle getGridExtents() {
		return gridextents;
	}

	public void gridOn(boolean on) {
		gridon = on;
		this.gridextents.setBounds(0, 0, level.width, level.height);
		this.repaint();
	}

	public boolean isGridOn() {
		return gridon;
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