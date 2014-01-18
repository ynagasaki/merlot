import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import java.nio.charset.StandardCharsets;
import java.util.Iterator;
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

		final Meditor app = new Meditor();

		// setup scroll pane (main editor area)
		final ScrollPane scrollpane = new ScrollPane(ScrollPane.SCROLLBARS_AS_NEEDED);
		scrollpane.add(app.getCanvas());
		scrollpane.setPreferredSize(new Dimension(DEFAULT_WIDTH, DEFAULT_HEIGHT));

		// setup app window
		Frame frame = new Frame("Meditor v.0.1.0");
		frame.setSize(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		frame.setLayout(new BorderLayout());
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

		// setup app menu bar
		new MeditorMenu(app, frame);
	}

	private MeditorCanvas canvas = null;
	private MerlotLevel level = null;
	private MerlotSprite selected = null;

	public Meditor() {
		this.canvas = new MeditorCanvas(this);
	}

	public MeditorCanvas getCanvas() {
		return this.canvas;
	}

	public void onClick(int x, int y) {
		if(level != null) {
			Iterator<MerlotSprite> iter = level.sprites.descendingIterator();
			while(iter.hasNext()) {
				MerlotSprite spr = iter.next();

				if(spr.containsPoint(x, y)) {
					if(selected != null) {
						selected.selected = false;
					}
					selected = spr;
					selected.selected = true;
					canvas.repaint();
					break;
				}
			}
		}
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

class MeditorCanvas extends Component {
	private static final int PINO_HEAD_WIDTH = 280;
	private static final int PINO_HEAD_HEIGHT = 200;

	private static final int GRID_RESOLUTION = 10;
	private static final Color GRID_COLOR = new Color(0,0,0,30);
	private static final Stroke GRID_STROKE = new BasicStroke(
			1f, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 1f, new float[] { 1f, 1f, 1f, 1f }, 0f
		);

	private MerlotLevel level = null;

	public MeditorCanvas(final Meditor app) {
		this.addMouseListener(new MouseListener() {
			@Override
			public void mouseClicked(MouseEvent e) {
			}

			@Override
			public void mousePressed(MouseEvent e) {
			}

			@Override
			public void mouseReleased(MouseEvent e) {
				app.onClick(e.getX(), e.getY());
			}

			@Override
			public void mouseEntered(MouseEvent e) {
			}

			@Override
			public void mouseExited(MouseEvent e) {
			}
		});
	}

	public void setLevel(MerlotLevel level) {
		this.level = level;
		this.setPreferredSize(new Dimension(level.width, level.height));
		this.getParent().setPreferredSize(new Dimension(level.width, level.height));
		this.getParent().revalidate();
	}

	public void paint(Graphics g) {
		Graphics2D g2d = (Graphics2D) g;

		int width = getSize().width - 1;
		int height = getSize().height - 1;

		if(this.level != null) {
			this.level.draw(g2d);

			g2d.setStroke(GRID_STROKE);
			g2d.setColor(GRID_COLOR);
			for(int x = 0; x <= width; x += GRID_RESOLUTION) g2d.drawLine(x,0,x,height);
			for(int y = 0; y <= height; y += GRID_RESOLUTION) g2d.drawLine(0,y,width,y);
		} else {
			g2d.setColor(Color.WHITE);
			g2d.fillOval(width/2 - PINO_HEAD_WIDTH/2, height/2 - PINO_HEAD_HEIGHT/2, PINO_HEAD_WIDTH, PINO_HEAD_HEIGHT);
			g2d.setColor(Color.BLACK);
			g2d.drawOval(width/2 - PINO_HEAD_WIDTH/2, height/2 - PINO_HEAD_HEIGHT/2, PINO_HEAD_WIDTH, PINO_HEAD_HEIGHT);
		}
		
		//g2d.finalize();
	}
}