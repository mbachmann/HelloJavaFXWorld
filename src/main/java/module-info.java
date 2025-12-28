module unitedportal.javafx.hellojavafxworld {
	requires javafx.controls;
	requires javafx.fxml;
	requires java.desktop;


	opens unitedportal.javafx.hellojavafxworld to javafx.fxml;
	exports unitedportal.javafx.hellojavafxworld;
}
