import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.FilenameFilter;

/**
 * The main menu bar for the Meditor.
 */
public class MeditorMenu implements ActionListener {
	public static final String MENUITEM_OPEN = "Open";

	// Logic jank
	private Meditor parentApp = null;

	// Gui jank
	private Frame parentFrame = null;
	private Menu menu = new Menu("File");
	private MenuBar bar = new MenuBar();

	public MeditorMenu(Meditor app, Frame parentFrame) {
		MenuItem openMenuItem = new MenuItem(MENUITEM_OPEN);
		openMenuItem.addActionListener(this);
		menu.add(openMenuItem);
		bar.add(menu);

		this.parentApp = app;
		this.parentFrame = parentFrame;
		this.parentFrame.setMenuBar(this.bar);
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		String label = null;
		if(e.getSource() instanceof MenuItem) {
			MenuItem source = (MenuItem) e.getSource();
			label = source.getLabel();
		}
		if(label.equalsIgnoreCase(MENUITEM_OPEN)) {
			FileDialog fd = new FileDialog(this.parentFrame, "Open level JSON", FileDialog.LOAD);

			fd.setDirectory(Meditor.APP_ROOT);
			fd.setFilenameFilter(new JSONFilenameFilter());
			fd.setVisible(true);

			String dir = fd.getDirectory();
			String file = fd.getFile();

			if(dir != null && file != null) {
				this.parentApp.LoadLevelJson(dir + file);
			}
		}
	}
}

class JSONFilenameFilter implements FilenameFilter {
	@Override
	public boolean accept(File dir, String name) {
		return name.toLowerCase().trim().endsWith(".json");
	}
}