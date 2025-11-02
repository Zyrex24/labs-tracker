# Android Signing (Local Only)

1) Generate keystore:
   ```bash
   keytool -genkey -v -keystore labs.jks -keyalg RSA -keysize 2048 -validity 10000 -alias labs
   ```

2) Create `android/key.properties` with your local paths/passwords (see `key.properties.sample`).

3) Do NOT commit `labs.jks` or `key.properties`.

4) Local release build:
   ```bash
   flutter build apk --release
   ```

## Note
The `.gitignore` file already excludes `*.jks` and `key.properties` to prevent accidental commits.

