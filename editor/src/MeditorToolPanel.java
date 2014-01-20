
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class MeditorToolPanel extends Panel implements ActionListener {
	private Meditor app;

	private Button editBoundariesButton;

	public MeditorToolPanel(Meditor app) {
		this.app = app;

		setPreferredSize(new Dimension(200, Meditor.DEFAULT_HEIGHT));
		setLayout(new FlowLayout());

		editBoundariesButton = new Button("Edit Boundaries");
		editBoundariesButton.addActionListener(this);
		add(editBoundariesButton);
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		if(e.getSource() == editBoundariesButton) {
			Selectable selected = app.getCanvas().getSelectedItem();
			if(selected instanceof MerlotPlatform) {
				System.out.println("Do it");
			}
		}
	}
}
