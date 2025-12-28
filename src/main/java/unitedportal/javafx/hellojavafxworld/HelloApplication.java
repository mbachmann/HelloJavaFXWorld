package unitedportal.javafx.hellojavafxworld;

import javafx.application.Application;
import javafx.application.Platform;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.input.KeyCode;
import javafx.stage.Stage;

import java.awt.*;
import java.io.IOException;

public class HelloApplication extends Application {
	@Override
	public void start(Stage stage) throws IOException {

		stage.setOnCloseRequest(evt -> {
			Platform.exit();
			new Thread(() -> {
				try { Thread.sleep(100); } catch (InterruptedException ignored) {}
				System.exit(0);
			}, "hard-exit").start();
		});


		var url = HelloApplication.class.getResource("hello-view.fxml");
		System.out.println("FXML URL = " + url);


		FXMLLoader fxmlLoader = new FXMLLoader(HelloApplication.class.getResource("hello-view.fxml"));
		Scene scene = new Scene(fxmlLoader.load(), 320, 240);

		scene.setOnKeyReleased(event -> {
			if (event.getCode() == KeyCode.Q && event.isMetaDown()) {
				System.out.println("exiting...");
				Platform.exit();
			}
		});

		stage.setTitle("Hello!");
		stage.setScene(scene);
		stage.show();

		SplashScreen splash = SplashScreen.getSplashScreen();
		if (splash != null) {
			splash.close();
		}

	}

	public static void main(String[] args) {
		launch();
	}
}
