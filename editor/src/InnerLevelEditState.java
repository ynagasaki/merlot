import java.awt.*;
import java.awt.event.KeyEvent;

public class InnerLevelEditState extends MeditorState {
	private MerlotPlatform platform;
	public InnerLevelEditState(MeditorCanvas canvas, MerlotPlatform p) {
		super(canvas, p.innerLevel);
		platform = p;

		platform.innerLevel.x = platform.getX();
		platform.innerLevel.y = platform.getY();
	}

	@Override
	public void paint(Graphics2D g2d) {
		this.platform.innerLevel.draw(g2d);
	}

	@Override
	public boolean paintStateBelow() {
		return true;
	}

	@Override
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_ESCAPE) {
			parentCanvas.popState();
		}
		super.keyPressed(e);
	}
}
