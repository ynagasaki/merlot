
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.IOException;

public class MeditorToolPanel extends Panel implements ActionListener {
	private Meditor parentApp;

	private Button editBoundariesButton = new Button("Edit Boundaries");
	private Button addInnerLevelButton = new Button("Add Inner Level");
	private Button addPlatformButton = new Button("Add Platform");
	private Button plusZButton = new Button("+z");
	private Button minusZButton = new Button("-z");

	JList<MerlotSprite> spriteList = new JList<>();

	public MeditorToolPanel(Meditor app) {
		this.parentApp = app;

		setPreferredSize(new Dimension(200, Meditor.DEFAULT_HEIGHT));
		setLayout(new FlowLayout());

		Button [] buttons = {
			editBoundariesButton,
			addPlatformButton,
			addInnerLevelButton,
			plusZButton,
			minusZButton
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
				MerlotSprite val = spriteList.getSelectedValue();
				parentApp.getCanvas().currentState().mousePressed(
						new MouseEvent(
								spriteList,
								-1,
								System.currentTimeMillis(),
								0,
								val.getX(),
								val.getY(),
								1,
								false
						)
				);
			}
		});

		ScrollPane listScroller = new ScrollPane();
		listScroller.add(spriteList);
		listScroller.setPreferredSize(new Dimension(200, 350));

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
		} else if(source == plusZButton) {
			if(spriteList.getSelectedIndex() > 0) {
				MerlotSprite spr = spriteList.getSelectedValue();
				if(spr != null) {
					parentApp.getCanvas().reorderSpriteForward(spr);
				}
			}
		} else if(source == minusZButton) {
			if(spriteList.getSelectedIndex() < spriteList.getModel().getSize() - 1) {
				MerlotSprite spr = spriteList.getSelectedValue();
				if(spr != null) {
					parentApp.getCanvas().reorderSpriteBack(spr);
				}
			}
		}
	}
}
