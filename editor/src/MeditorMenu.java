import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * The main menu bar for the Meditor.
 */
public class MeditorMenu implements ActionListener {

	public static final String[] MENUITEM_NEW = new String[] {"New...", "N"};
	public static final String[] MENUITEM_OPEN = new String[] {"Open...", "O"};
	public static final String[] MENUITEM_SAVE = new String[] {"Save", "S"};
	public static final String[] MENUITEM_SEP = new String[] { "-", null };
	public static final String[] MENUITEM_RENDER = new String[] {"Render to File...", "R"};

	// Logic jank
	private Meditor parentApp = null;

	// Gui jank
	private Frame parentFrame = null;

	public MeditorMenu(Meditor app, Frame parentFrame) {
		Menu menu = new Menu("File");
		MenuBar bar = new MenuBar();
		String [][] menuitems = new String [][] {
			MENUITEM_NEW,
			MENUITEM_OPEN,
			MENUITEM_SAVE,
			MENUITEM_SEP,
			MENUITEM_RENDER
		};

		for(String[] item : menuitems) {
			MenuItem mitem = new MenuItem(item[0]);
			if(item[1] != null) {
				mitem.setShortcut(new MenuShortcut(item[1].charAt(0)));
			}
			mitem.addActionListener(this);
			menu.add(mitem);
		}

		bar.add(menu);

		this.parentApp = app;
		this.parentFrame = parentFrame;
		this.parentFrame.setMenuBar(bar);
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		String label = null;
		if(e.getSource() instanceof MenuItem) {
			MenuItem source = (MenuItem) e.getSource();
			label = source.getLabel();
		}
		if(label == null) return;
		if(label.equalsIgnoreCase(MENUITEM_OPEN[0])) {
			String path = this.parentApp.openLoadFileDialog("json");
			if(path != null) {
				this.parentApp.loadLevelJson(path);
			}
		} else if(label.equalsIgnoreCase(MENUITEM_SAVE[0])) {
			this.parentApp.saveLevelJson(null);
		} else if(label.equalsIgnoreCase(MENUITEM_RENDER[0])) {
			if(this.parentApp.getCanvas().getLevel() != null) {
				FileDialog fd = new FileDialog(parentFrame, "Save rendering", FileDialog.SAVE);

				fd.setDirectory(Meditor.APP_ROOT);
				fd.setVisible(true);

				String dir = fd.getDirectory();
				String file = fd.getFile();
				int extidx = file.lastIndexOf('.');

				if(extidx >= 0) {
					file = file.substring(0, extidx);
				}

				if(file.length() > 0) {
					this.parentApp.saveCanvasRender(dir + file);
				} else {
					System.out.println("*Error: filename is empty; canceling render.");
				}
			}
		} else if(label.equalsIgnoreCase(MENUITEM_NEW[0])) {
			System.out.println("All I'm hearing is... I'm too fat.");
		}
	}
}
