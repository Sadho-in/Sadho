import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: the upload key's details live in android/key.properties,
// which is git-ignored (never committed). Without it, or with its passwords
// still empty, release builds fall back to the debug key (so
// `flutter run --release` keeps working) and Gradle says so loudly: such a
// build must not be uploaded to Play. See README "Releasing".
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
val uploadKeyReady = listOf("storePassword", "keyPassword", "keyAlias", "storeFile")
    .all { !keystoreProperties.getProperty(it).isNullOrBlank() } &&
    file(keystoreProperties.getProperty("storeFile")).exists()

if (!uploadKeyReady) {
    gradle.taskGraph.whenReady {
        if (allTasks.any { it.name.contains("Release") }) {
            logger.warn(
                "WARNING: release build is NOT upload-signed (android/key.properties " +
                    "is missing, incomplete or its storeFile does not exist). It is " +
                    "signed with the DEBUG key and must not be uploaded to Google Play.",
            )
        }
    }
}

android {
    namespace = "in.sadho.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications needs desugaring for scheduled reminders.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // PERMANENT: this ID can never change after the first Play Store upload.
        applicationId = "in.sadho.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (uploadKeyReady) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            // The upload key when android/key.properties is filled in; the
            // debug key otherwise (with the warning above). Resource shrinking
            // keeps the ringtones and the notification icon (res/raw/keep.xml).
            signingConfig = if (uploadKeyReady) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Mala screen-off counting (MalaCounterService): MediaSessionCompat and
    // VolumeProviderCompat receive the volume keys; NotificationCompat /
    // ServiceCompat for the foreground notification.
    implementation("androidx.media:media:1.7.0")
    implementation("androidx.core:core-ktx:1.13.1")
}

flutter {
    source = "../.."
}
