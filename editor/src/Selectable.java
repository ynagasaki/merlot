
public interface Selectable {
	void select(boolean on);
	boolean shouldSelect(int x, int y);

	void translate(int dx, int dy);
	int getX();
	int getY();
	int getWidth();
	int getHeight();
}
