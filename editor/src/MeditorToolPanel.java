
import javax.swing.*;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import java.awt.*;
import java.awt.event.*;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.io.IOException;

public class MeditorToolPanel extends Panel implements ActionListener {
	private Meditor parentApp;

	private Button editBoundariesButton = new Button("Edit Boundaries");
	private Button addInnerLevelButton = new Button("Add Inner Level");
	private Button addPlatformButton = new Button("Add Platform");

	JList spriteList = new JList();

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

		spriteList.setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
		spriteList.setLayoutOrientation(JList.VERTICAL);
		spriteList.setVisibleRowCount(-1);
		spriteList.addMouseListener(new MouseAdapter() {
			@Override
			public void mouseReleased(MouseEvent e) {
				String val = spriteList.getSelectedValue().toString();
				String [] xy = val.split(" ")[0].split(",");
				parentApp.getCanvas().currentState().mousePressed(
						new MouseEvent(
								spriteList,
								-1,
								System.currentTimeMillis(),
								0,
								Integer.parseInt(xy[0]),
								Integer.parseInt(xy[1]),
								1,
								false
						)
				);
			}
		});

		ScrollPane listScroller = new ScrollPane();
		listScroller.add(spriteList);
		listScroller.setPreferredSize(new Dimension(200, 500));

		add(listScroller);
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
				if(path == null) return;
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
