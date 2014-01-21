
import java.awt.*;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Iterator;

public class MeditorCanvas extends Canvas {

	private boolean gridIsOn = false;
	private MeditorGrid grid;
	private MerlotLevel level = null;
	private Deque<MeditorState> stateStack = new ArrayDeque<MeditorState>(4);

	public MeditorCanvas() {
		grid = new MeditorGrid();
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

		repaint();
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

			repaint();
		}
	}

	public Selectable getSelectedItem() {
		return stateStack.peekFirst().selectedItem;
	}

	public MerlotLevel getLevel() {
		return level;
	}

	public void setLevel(MerlotLevel lvl) {
		this.level = lvl;
		this.setPreferredSize(new Dimension(level.width, level.height));
		this.setGridExtents(0, 0, level.width, level.height);

		this.getParent().setPreferredSize(new Dimension(level.width, level.height));
		this.getParent().revalidate();
		this.repaint();
	}

	public void gridOn(boolean on) {
		gridIsOn = on;
		repaint();
	}

	public boolean isGridOn() {
		return gridIsOn;
	}

	public void setGridExtents(int x, int y, int width, int height) {
		grid.setExtents(x, y, width, height);
		repaint();
	}

	@Override
	public void paint(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;

		if(this.level != null) {
			Iterator<MeditorState> iter = stateStack.iterator();

			paintInOrder(g2d, iter.next(), iter);

			if(gridIsOn) {
				grid.paint(g2d, level.getWidth(), level.getHeight());
			}
		} else {
			g2d.setColor(Color.DARK_GRAY);
			g2d.drawString("Hello, fart face. Load a friggin level.", 20, 20);
		}
	}

	private void paintInOrder(Graphics2D g2d, MeditorState currState, Iterator<MeditorState> stateStackIter) {
		if(currState.paintStateBelow() && stateStackIter.hasNext()) {
			paintInOrder(g2d, stateStackIter.next(), stateStackIter);
		}
		currState.paint(g2d);
	}
}