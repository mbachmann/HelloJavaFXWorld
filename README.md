# Building and Deploying a JavaFX Application on macOS with Maven (Java 25)


This guide explains how to build, sign, notarize, and distribute a JavaFX application for macOS using **Maven**, `jlink`, `jpackage`, `codesign`, and `notarytool`. 
The goal is to create a downloadable `.dmg` disk image that runs without Gatekeeper warnings.

## The Error Messages of Downloaded Apps without signing and notarizing

With the ever-improving security of MacOS, checks on downloaded and runnable software have become more pervasive. Trying to build and distribute an application outside of the Apple App Store has its own challenges.

This guide runs you through the process of how to get this all sorted so that you aren’t going to see the following error messages.

<p float="left">
<img src="readme/app-damaged.png" height="350" width="280" alt="">
<img src="readme/app-malicious.png" height="350" width="280" alt="">
</p>

---

## ✅ Prerequisites

- **IntelliJ IDEA (or your preferred IDE)  
  https://www.jetbrains.com/idea/download/?section=mac

- **Azul Zulu JDK with JavaFX**  
  https://www.azul.com/downloads/#downloads-table-zulu

- **Apple Developer Account** (USD $99/year)  
  https://developer.apple.com/

- **App-specific password for notarization**  
  https://appleid.apple.com/account/manage

---

## ✅ Setup Apple Developer Credentials

Go to https://developer.apple.com/ to sign up for an Apple Developer account. 
You can skip the certificate creation if you already have one.

However, make sure the necessary intermediate certificats are installed in your keychain of your macOS.

If not available, you can download it from here:

- **Download Intermediates**
  https://www.apple.com/certificateauthority/
- **Overview of Certificates** 
- https://developer.apple.com/support/certificates/
  **Explaning the Types of Intermediates (G2, G3, ...), we need G3**
- https://developer.apple.com/help/account/certificates/wwdr-intermediate-certificates/



![keychain.png](readme/keychain.png)

If the Developer ID Application is **not** available, then follow the instructions below.

---

## Create a Developer ID Application Certificate

### Create a CSR File

Firstly, go to the KeyChain Application in MacOs an create a CSR. Open the menu certificate assistant.

Keychain Access → Certificate Assistant → Request a Certificate From a Certificate Authority…

![create-a-csr.png](readme/create-a-csr.png)

You enter your eMail address

![certificate-assistant.png](readme/certificate-assistant.png)

and then save the csr-file:

![save-csr.png](readme/save-csr.png)

### Create the Certificate

Once signed up at https://developer.apple.com/account go to Account -> Certificates -> Click on the (+) button to add a new certificate.

You want to create a Developer ID Application certificate

![developer-id-application.png](readme/developer-id-application.png)

Go through the process of generating a certificate signing request.

![reminder.png](readme/reminder.png)

The key part here is ‘software that you sign it with must be notarized by Apple’ — we will come back to this part when we start packaging the application.

Download and install the certificate into your keychain.

Open up your keychain to determine the name of the certificate

Here you can check your created certificate:

![certificate.png](readme/certificate.png)

In the greyed-out box, you will see your certificate name and team ID.


https://developer.apple.com/account/resources/certificates/list

----

## Notarise app password
The last step in getting all of the components together is to get a notarised app password for this specific app that you will be building.

go to https://developer.apple.com/account/resources/identifiers/bundleId/add/bundle to add a new bundle for this application

Press enter or click to view image in full size

![register-an-app.png](readme/register-an-app.png)

Type in the name HelloJavaFXWorld and the Bundle ID unitedportal.javafx.HelloJavaFXWorld.

Also note the team ID under the App ID Profile which will appear in the greyed-out box above

Click on the Continue button and then Register.

----

## App Specific Password

Now sign into https://appleid.apple.com/

go to https://appleid.apple.com/account/manage

and click on the App Specific Passwords link

![app-specific-password.png](readme/app-specific-password.png)


A pop up will be presented — click on the + button to add a new password.

<img src="readme/password.png" height="300" alt="">

Yet another popup — enter the name NOTE: it does not have to be the same as your application name — but it helps to keep everything in line.

<img src="readme/generate-app-specific-password.png" height="300" alt="">

Click on Create — you will need to enter your developer ID password again.

<img src="readme/your-app-specific-password-is.png" height="300" alt="">

Save this password — you will never see this password again — if you lose it, you will have to regenerate it.

----

## Summary about Developer ID Application certificate

1. Create a **Developer ID Application certificate** in your Apple Developer account.
2. Download and install the certificate into your macOS Keychain.
3. Note your:
   - Certificate name → `MAC_SIGNING_KEY_NAME`
   - Team ID → `APPLE_TEAM_ID`
   - Apple ID → `APPLE_ID`
   - App-specific password → `APPLE_HELLO_JAVA_FX_WORLD_APP_PASSWORD`
   - The application bundleID

Add these to your `~/.zshrc` or `~/.bashrc` or `~/.bash_profile`:

```bash
export MAC_SIGNING_KEY_NAME="Developer ID Application: Your Name (TEAMID)"
export APPLE_ID="your-apple-id@example.com"
export APPLE_TEAM_ID="YOUR_TEAM_ID"
export APPLE_HELLO_JAVA_FX_WORLD_APP_PASSWORD="your-app-specific-password"
```

---

## ✅ Project Setup (Maven)

Create a Maven JavaFX project with your prefered IDE (example: `HelloJavaFXWorld`).

Here, for example, with IntelliJ:



Ensure:
- JDK 21+ with JavaFX modules.
- Remove `-SNAPSHOT` from version in `pom.xml`:
  ```xml
  <version>1.0.0</version>
  ```

---

## ✅ Create Entitlements File

`src/packaging/entitlements.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key><false/>
    <key>com.apple.security.network.server</key><true/>
    <key>com.apple.security.network.client</key><true/>
    <key>com.apple.security.files.user-selected.read-write</key><true/>
    <key>com.apple.security.cs.allow-jit</key><true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key><true/>
    <key>com.apple.security.cs.disable-library-validation</key><true/>
</dict>
</plist>
```

## Put the Icons and the Splash Screen to src/packaging

![packaging-folder.png](readme/packaging-folder.png)

---

## Scripts for jlink, jpackage, xcrun, codesign

The scripts can be found in `dist-mac.sh`. 

### ✅ Verify the environment variable

```bash
echo $MAC_SIGNING_KEY_NAME
echo $APPLE_ID
echo $APPLE_TEAM_ID
echo $APPLE_HELLO_JAVA_FX_WORLD_APP_PASSWORD
```

### ✅ Run the application

```bash
mvn clean javafx:run
```

### ✅ Build Runtime Image with jlink

Use Maven plugin or command:

```bash
mvn clean javafx:jlink
```

### ✅ Verify Runtime Image with jlink

```bash
target/image/bin/app
```

We are ready to jpackage

---

### ✅ Package App with jpackage

#### Create `.app` bundle:

```bash
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
```

Copy splash image into `.app`:

```bash
cp src/packaging/splash.png target/jpackage/HelloJavaFXWorld.app/Contents/app
```

#### ✅ Re-Sign DMG

```bash
codesign \
  --entitlements src/packaging/entitlements.plist \
  -vvv \
  --options runtime \
  --force \
  --sign "$MAC_SIGNING_KEY_NAME" \
  target/jpackage/HelloJavaFXWorld.app
```

Verify the app 

```bash
open target/jpackage/HelloJavaFXWorld.app
```

#### Create DMG:

```bash
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
  --copyright "Copyright (c) 2026 United-Portal"```
```

---


### ✅ Notarize and Staple

```bash
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
```

---

### ✅ Validate

```bash
spctl --assess --type open --verbose target/jpackage/HelloJavaFXWorld-1.0.0.dmg
```

Expected: `accepted`.


## ✅ Summary

You now have:
- A signed and notarized `.dmg` ready for distribution.
- A JavaFX app that runs without Gatekeeper warnings.
