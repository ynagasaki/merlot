import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;

import java.nio.charset.StandardCharsets;
import java.util.List;

public class Meditor {
	public static String APP_TITLE = "Meditor v0.1.0";
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
		Frame frame = new Frame(APP_TITLE);
		frame.setIgnoreRepaint(true);
		frame.setSize(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		frame.setLayout(new BorderLayout());

		// Create new app
		final Meditor app = new Meditor(frame);

		new MeditorMenu(app, frame);
		MeditorCanvas canvas = app.getCanvas();
		frame.add("West", new MeditorToolPanel(app));

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
		frame.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				System.exit(0);
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
	private Frame window = null;

	public Meditor(Frame frame) {
		this.window = frame;
		this.canvas = new MeditorCanvas();
	}

	public MeditorCanvas getCanvas() {
		return this.canvas;
	}

	public void saveCanvasRender(final String filename) {
		BufferedImage result = canvas.requestCanvasRender();
		if(result != null) {
			File outputfile = new File(filename + ".png");
			try {
				ImageIO.write(result, "png", outputfile);
			} catch(Exception ex) {
				ex.printStackTrace();
			}
		}
	}

	public void loadLevelJson(String filename) {
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
			this.window.setTitle(APP_TITLE + " - " + filename);
			this.canvas.setLevel(level);
		}
	}

	public void saveLevelJson(String filename) {
		FileOutputStream fouts;
		String data = level.toJson().toString();

		if(filename == null) {
			filename = level.getFilename();
		}

		try {
			fouts = new FileOutputStream(filename, false);
		} catch(Exception ex) {
			ex.printStackTrace();
			return;
		}

		Writer out;
		try {
			out = new OutputStreamWriter(fouts, "UTF-8");
		} catch(Exception ex) {
			try {
				fouts.close();
			} catch(Exception ex2) {
				ex2.addSuppressed(ex);
				ex2.printStackTrace();
			}
			return;
		}

		try {
			out.write(data);
		} catch(Exception ex) {
			ex.printStackTrace();
		} finally {
			try {
				out.close();
			} catch(Exception ex2) {
				ex2.printStackTrace();
			}
		}
	}

	public String openLoadFileDialog(final String extension) {
		FileDialog fd = new FileDialog(this.window, "Load a " + extension + " file", FileDialog.LOAD);

		fd.setDirectory(Meditor.APP_ROOT);

		fd.setFilenameFilter(new FilenameFilter() {
			@Override
			public boolean accept(File dir, String name) {
				return name.toLowerCase().trim().endsWith(extension);
			}
		});

		fd.setVisible(true);

		String dir = fd.getDirectory();
		String file = fd.getFile();

		return dir + file;
	}
}
