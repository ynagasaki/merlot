
import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Iterator;

public class MeditorCanvas extends Canvas {
	private boolean gridIsOn = false;
	private MeditorGrid grid;
	private Deque<MeditorState> stateStack = new ArrayDeque<>(4);
	private Meditor parentApp;

	public MeditorCanvas(Meditor app) {
		parentApp = app;
		grid = new MeditorGrid();
	}

	public MeditorState currentState() {
		if(stateStack.size() > 0) {
			return stateStack.peekFirst();
		}
		return null;
	}

	public MerlotLevel currentLevel() {
		if(currentState() == null) return null;
		return currentState().getLevel();
	}

	public MerlotLevel topmostLevel() {
		for(MeditorState state : stateStack) {
			MerlotLevel lvl = state.getLevel();
			if(lvl != null) return lvl;
		}
		return null;
	}

	public void rejiggerTheCurrentLevelCanvasDimensions() {
		MerlotLevel level = currentLevel();
		Dimension dim = new Dimension(level.getWidth(), level.getHeight());

		this.setPreferredSize(dim);
		this.getParent().setPreferredSize(dim);
		this.getParent().revalidate();
	}

	public void pushState(MeditorState state) {
		if(stateStack.size() > 0) {
			MeditorState curr = stateStack.peekFirst();
			this.removeMouseListener(curr);
			this.removeMouseMotionListener(curr);
			this.removeKeyListener(curr);
		}

		stateStack.addFirst(state);
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
		return currentState().selectedItem;
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

	public BufferedImage requestCanvasRender() {
		MerlotLevel level = currentState().getLevel();
		if(level != null) {
			BufferedImage result = new BufferedImage(level.width, level.height, BufferedImage.TYPE_INT_ARGB);
			Graphics2D g2d = result.createGraphics();
			this.paint(g2d);
			return result;
		}
		return null;
	}

	@Override
	public void paint(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;

		if(stateStack.size() > 0) {
			Iterator<MeditorState> iter = stateStack.iterator();

			paintInOrder(g2d, iter.next(), iter);

			if(gridIsOn) {
				MerlotLevel topmost = topmostLevel();
				grid.paint(g2d, topmost.getX(), topmost.getY(), topmost.getWidth(), topmost.getHeight());
			}

			parentApp.syncGui();
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

	public void reorderSpriteForward(MerlotSprite spr) {
		MerlotLevel level = currentLevel();

		if(level == null || level.sprites.peekLast() == spr) return;

		int size = level.sprites.size();
		Deque<MerlotSprite> temp = new ArrayDeque<>(size);
		Iterator<MerlotSprite> iter = level.sprites.iterator();

		boolean doit = false;
		while(size -- > 0) {
			MerlotSprite curr = iter.next();
			if(curr == spr) {
				doit = true;
			} else if(doit) {
				temp.addLast(curr);
				temp.addLast(spr);
				doit = false;
			} else {
				temp.addLast(curr);
			}
		}

		level.sprites = temp;
		repaint();
	}

	public void reorderSpriteBack(MerlotSprite spr) {
		MerlotLevel level = currentLevel();

		if(level == null || level.sprites.peekFirst() == spr) return;

		int size = level.sprites.size();
		Deque<MerlotSprite> temp = new ArrayDeque<>(size);
		Iterator<MerlotSprite> iter = level.sprites.descendingIterator();

		boolean doit = false;
		while(size -- > 0) {
			MerlotSprite curr = iter.next();
			if(curr == spr) {
				doit = true;
			} else if(doit) {
				temp.addFirst(curr);
				temp.addFirst(spr);
				doit = false;
			} else {
				temp.addFirst(curr);
			}
		}

		level.sprites = temp;
		repaint();
	}
}