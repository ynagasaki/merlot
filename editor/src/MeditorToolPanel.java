
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;

public class MeditorToolPanel extends Panel implements ActionListener {
	private Meditor parentApp;

	private Button editBoundariesButton = new Button("Edit Boundaries");
	private Button addInnerLevelButton = new Button("Add Inner Level");
	private Button addPlatformButton = new Button("Add Platform");

	public MeditorToolPanel(Meditor app) {
		this.parentApp = app;

		setPreferredSize(new Dimension(200, Meditor.DEFAULT_HEIGHT));
		setLayout(new FlowLayout());

		Button [] buttons = {
			editBoundariesButton,
			addPlatformButton,
			addInnerLevelButton
		};

		for(Button button : buttons) {
			button.addActionListener(this);
			add(button);
		}
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		Object source = e.getSource();
		if(source == editBoundariesButton) {
			MeditorCanvas canvas = parentApp.getCanvas();
			Selectable selected = canvas.getSelectedItem();
			if(selected instanceof MerlotPlatform) {
				canvas.pushState(new BoundaryEditState(canvas, (MerlotPlatform) selected));
			}
		} else if(source == addInnerLevelButton) {
			MeditorCanvas canvas = parentApp.getCanvas();
			Selectable selected = canvas.getSelectedItem();
			if(selected instanceof MerlotPlatform) {
				System.out.println("poop");
			}
		} else if(source == addPlatformButton) {
			if(this.parentApp.getCanvas().getLevel() != null) {
				String path = this.parentApp.openLoadFileDialog("png");
				if(path.startsWith(Meditor.APP_ROOT)) {
					path = path.substring(Meditor.APP_ROOT.length());
				}
				try {
					MerlotPlatform platform = new MerlotPlatform(path);
					this.parentApp.getCanvas().getLevel().sprites.add(platform);
					this.parentApp.getCanvas().repaint();
				} catch(IOException ex) {
					System.out.println("*Error: failed to add platform: " + path);
					ex.printStackTrace();
				}
			}
		}
	}
}
