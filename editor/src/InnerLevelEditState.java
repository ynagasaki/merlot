import java.awt.*;

public class InnerLevelEditState extends MeditorState {
	private MerlotPlatform parentPlatform;
	public InnerLevelEditState(MeditorCanvas canvas, MerlotPlatform platform) {
		super(canvas);
		parentPlatform = platform;

		parentPlatform.innerLevel.x = parentPlatform.getX();
		parentPlatform.innerLevel.y = parentPlatform.getY();
	}

	@Override
	public void paint(Graphics2D g2d) {
		parentPlatform.innerLevel.draw(g2d);
	}

	@Override
	public boolean paintStateBelow() {
		return true;
	}

}
