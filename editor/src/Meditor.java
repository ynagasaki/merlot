import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import java.nio.charset.StandardCharsets;
import java.util.List;

public class Meditor {
	public static String APP_ROOT = System.getProperty("user.dir");

	public static final int PLAYER_WIDTH = 40, PLAYER_HEIGHT = 75;
	public static final int DEFAULT_WIDTH = 1200, DEFAULT_HEIGHT = 700;

	public static void main(String[] args) {
		if(args.length < 1) {
			System.out.println("Need to pass app root dir.");
			return;
		} else {
			APP_ROOT = args[0];
			if(!APP_ROOT.endsWith("/")) APP_ROOT += "/";
		}

		// Setup window
		Frame frame = new Frame("Meditor v.0.1.0");
		frame.setIgnoreRepaint(true);
		frame.setSize(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		frame.setLayout(new BorderLayout());

		// Create new app
		final Meditor app = new Meditor();

		new MeditorMenu(app, frame);
		MeditorCanvas canvas = app.getCanvas();

		// setup scroll pane (main editor area)
		final ScrollPane scrollpane = new ScrollPane(ScrollPane.SCROLLBARS_AS_NEEDED);
		scrollpane.add(canvas);
		scrollpane.setPreferredSize(new Dimension(DEFAULT_WIDTH, DEFAULT_HEIGHT));

		frame.add("Center", scrollpane);
		frame.setVisible(true);
		frame.addWindowStateListener(new WindowStateListener() {
			@Override
			public void windowStateChanged(WindowEvent e) {
				Dimension windowsize = e.getWindow().getSize();
				scrollpane.setPreferredSize(windowsize);
				scrollpane.revalidate();
			}
		});
		frame.addWindowListener(new WindowListener() {
			@Override
			public void windowOpened(WindowEvent e) {
			}
			@Override
			public void windowClosing(WindowEvent e) {
				System.exit(0);
			}
			@Override
			public void windowClosed(WindowEvent e) {
			}
			@Override
			public void windowIconified(WindowEvent e) {
			}
			@Override
			public void windowDeiconified(WindowEvent e) {
			}
			@Override
			public void windowActivated(WindowEvent e) {
			}
			@Override
			public void windowDeactivated(WindowEvent e) {
			}
		});
		frame.addKeyListener(new KeyListener() {
			@Override
			public void keyTyped(KeyEvent e) {
			}
			@Override
			public void keyPressed(KeyEvent e) {
				app.getCanvas().dispatchEvent(e);
			}
			@Override
			public void keyReleased(KeyEvent e) {
				app.getCanvas().dispatchEvent(e);
			}
		});
	}

	private MeditorCanvas canvas = null;
	private MerlotLevel level = null;

	public Meditor() {
		this.canvas = new MeditorCanvas();
	}

	public MeditorCanvas getCanvas() {
		return this.canvas;
	}

	public void LoadLevelJson(String filename) {
		List<String> lines;
		StringBuilder content = new StringBuilder();

		try {
			lines = Files.readAllLines(Paths.get(filename), StandardCharsets.UTF_8);
		} catch(IOException ex) {
			ex.printStackTrace();
			return;
		}

		for(String line : lines) content.append(line);

		JSONObject tld = (JSONObject) JSONValue.parse(content.toString());

		try {
			level = new MerlotLevel(new MerlotJsonObject(tld));
		} catch(IOException ex) {
			System.out.println("* Error: load level file failed: " + filename);
			ex.printStackTrace();
		}

		if(level != null) {
			this.canvas.setLevel(level);
		}
	}
}
