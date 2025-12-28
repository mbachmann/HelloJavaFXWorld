# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Run the app before JLink
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

mvn clean javafx:run

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Run the jlink
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

mvn clean javafx:jlink

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Run the app after jlink
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

target/image/bin/app

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# remove any previous output of the packaging
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

rm -rf target/jpackage/*

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Apply the environment variables (preferable in `~/.bashrc or` `~/.bash_profile` or `~/.zshrc`)
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export MAC_SIGNING_KEY_NAME="YOUR_CERTIFICATE_NAME_HERE"
export APPLE_ID="YOUR_APPLE_ID_HERE_WHICH_MAY_BE_YOUR_EMAIL_ADDRESS"
export APPLE_TEAM_ID="YOUR_APPLE_TEAM_ID_HERE"
export APPLE_HELLO_JAVA_FX_WORLD_APP_PASSWORD="YOUR_NOTARISED_APP_PASSWORD"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Package up the application into an app image (i.e. HelloJavaFXApp.app)
# .. be patient, it will take about 10 seconds
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

jpackage \
  --verbose \
  --type app-image \
  --dest target/jpackage \
  --name HelloJavaFXWorld \
  --vendor "United-Portal" \
  --module unitedportal.javafx.hellojavafxworld/unitedportal.javafx.hellojavafxworld.HelloApplication \
  --icon src/packaging/icons.icns \
  --app-version 1.0.0 \
  --runtime-image target/image \
  --java-options "-splash:\$APPDIR/splash.png" \
  --mac-sign \
  --mac-entitlements src/packaging/entitlements.plist \
  --mac-signing-key-user-name "$MAC_SIGNING_KEY_NAME" \
  --mac-package-identifier unitedportal.javafx.hellojavafxworld

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Copy over the splashscreen
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cp src/packaging/splash.png target/jpackage/HelloJavaFXWorld.app/Contents/app


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# You need to now re-codesign everything
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

codesign \
  --entitlements src/packaging/entitlements.plist \
  -vvv \
  --options runtime \
  --force \
  --sign "$MAC_SIGNING_KEY_NAME" \
  target/jpackage/HelloJavaFXWorld.app


  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Verify the jpackage
  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

open target/jpackage/HelloJavaFXWorld.app


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# This will create the disk image (i.e. HelloJavaFXWorld-1.0.0.dmg
# .. be patient, it will take about 10 seconds
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

jpackage \
  --verbose \
  --type dmg \
  --dest target/jpackage \
  --name HelloJavaFXWorld \
  --app-image target/jpackage/HelloJavaFXWorld.app \
  --icon src/packaging/icons.icns \
  --mac-sign \
  --mac-signing-key-user-name "$MAC_SIGNING_KEY_NAME" \
  --mac-package-identifier unitedportal.javafx.hellojavafxworld \
  --mac-package-name HelloJavaFXWorld \
  --mac-entitlements src/packaging/entitlements.plist \
  --vendor unitedportal \
  --app-version 1.0.0 \
  --copyright "Copyright (c) 2026 United-Portal"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Result of DMG-Installationsprogramm for HelloJavaFXWorld: ./target/jpackage/HelloJavaFXWorld-1.0.0.dmg.
# Mac-DMG-Package-Package has been successfully created
#
codesign --verify --deep --strict --verbose=2 target/jpackage/HelloJavaFXWorld-1.0.0.dmg
# target/jpackage/HelloJavaFXWorld-1.0.0.dmg: code object is not signed at all
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Now notarise the application
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

xcrun \
  notarytool \
  submit \
  --apple-id $APPLE_ID \
  --team-id $APPLE_TEAM_ID \
  --password $APPLE_HELLO_JAVA_FX_WORLD_APP_PASSWORD \
  target/jpackage/HelloJavaFXWorld-1.0.0.dmg \
  --wait

xcrun \
  stapler \
  staple \
  target/jpackage/HelloJavaFXWorld-1.0.0.dmg


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Do the gatekeeper test
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

spctl --assess --type open --verbose target/jpackage/HelloJavaFXWorld-1.0.0.dmg
# target/jpackage/HelloJavaFXWorld-1.0.0.dmg: accepted
# source=Insufficient Context
# override=security disabled
