import java.awt.event.KeyEvent;
import java.awt.event.MouseEvent;

public class BoundaryEditState extends MeditorState {
	public BoundaryEditState(MeditorCanvas canvas) {
		super(canvas);
	}

	@Override
	public void mouseReleased(MouseEvent e) {

	}

	@Override
	public void keyPressed(KeyEvent e) {
		//System.out.println("hello");
		if(e.getKeyCode() == KeyEvent.VK_ESCAPE) {
			parentCanvas.popState();
		}
	}
}
