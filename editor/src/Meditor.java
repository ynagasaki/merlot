import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import java.awt.*;
import java.awt.event.WindowStateListener;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.nio.charset.StandardCharsets;
import java.util.List;

public class Meditor {
	public static String APP_ROOT = System.getProperty("user.dir");

	public static final int PLAYER_WIDTH = 40, PLAYER_HEIGHT = 75;

	public static void main(String[] args) {
		if(args.length < 1) {
			System.out.println("Need to pass app root dir.");
			return;
		} else {
			APP_ROOT = args[0];
			if(!APP_ROOT.endsWith("/")) APP_ROOT += "/";
		}

		Meditor app = new Meditor();

		//Panel toolpanel = new Panel();
		//toolpanel.setPreferredSize(new Dimension(200, 600));

		final ScrollPane scrollpane = new ScrollPane(ScrollPane.SCROLLBARS_ALWAYS);
		scrollpane.add(app.getCanvas());
		scrollpane.setPreferredSize(new Dimension(800, 600));

		Frame frame = new Frame("Meditor v.0.1.0");
		frame.setSize(800, 600);
		frame.setLayout(new BorderLayout());
		//frame.add("West", toolpanel);
		frame.add("Center", scrollpane);
		frame.setVisible(true);
		frame.addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				System.exit(0);
			}
		});
		frame.addWindowStateListener(new WindowStateListener() {
			@Override
			public void windowStateChanged(WindowEvent e) {
				Dimension windowsize = e.getWindow().getSize();
				scrollpane.setPreferredSize(windowsize);
				scrollpane.revalidate();
			}
		});

		new MeditorMenu(app, frame);
	}

	private MeditorCanvas canvas = null;

	public Meditor() {
		this.canvas = new MeditorCanvas();
	}

	public MeditorCanvas getCanvas() {
		return this.canvas;
	}

	public void LoadLevelJson(String filename) {
		List<String> lines = null;
		StringBuilder content = new StringBuilder();

		try {
			lines = Files.readAllLines(Paths.get(filename), StandardCharsets.UTF_8);
		} catch(IOException ex) {
			ex.printStackTrace();
			return;
		}

		for(String line : lines) content.append(line);

		JSONObject tld = (JSONObject) JSONValue.parse(content.toString());
		MerlotLevel lvl = null;

		try {
			lvl = new MerlotLevel(new MerlotJsonObject(tld));
		} catch(IOException ex) {
			System.out.println("* Error: load level file failed: " + filename);
			ex.printStackTrace();
		}

		if(lvl != null) {
			this.canvas.setLevel(lvl);
		}
	}
}

class MeditorCanvas extends Component {
	private static final int PINO_HEAD_WIDTH = 280;
	private static final int PINO_HEAD_HEIGHT = 200;

	public void setLevel(MerlotLevel level) {
		this.level = level;
		this.setPreferredSize(new Dimension(level.width, level.height));

		this.getParent().setPreferredSize(new Dimension(level.width, level.height));
		this.getParent().revalidate();
	}

	private MerlotLevel level = null;

	public void paint(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;

		if(this.level != null) {
			this.level.draw(g2d);
		} else {
			int width = getSize().width - 1;
			int height = getSize().height - 1;

			g2d.setColor(Color.WHITE);
			g2d.fillOval(width/2 - PINO_HEAD_WIDTH/2, height/2 - PINO_HEAD_HEIGHT/2, PINO_HEAD_WIDTH, PINO_HEAD_HEIGHT);
			g2d.setColor(Color.BLACK);
			g2d.drawOval(width/2 - PINO_HEAD_WIDTH/2, height/2 - PINO_HEAD_HEIGHT/2, PINO_HEAD_WIDTH, PINO_HEAD_HEIGHT);
		}
		
		//g2d.finalize();
	}
}