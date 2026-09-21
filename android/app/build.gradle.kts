plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
import java.util.Properties
        import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.sendly"
    compileSdk = 36
    ndkVersion = "27.0.12077973"
    signingConfigs {
        // توقيع الـ release يحتاج ملف key.properties (غير مرفوع على git).
        // بدونه تعمل بقية أنواع البناء (debug / run) بشكل طبيعي.
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // بدون key.properties يُوقَّع بمفتاح الـ debug (لا يصلح للرفع على المتجر)
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mnrra.sandlyn"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

}

// حماية: لا يُبنى AAB للرفع بمفتاح debug (Google Play ترفضه). أنشئ android/key.properties
// (انظر key.properties.example). بناء APK للتجربة لا يتأثر.
gradle.taskGraph.whenReady {
    if (allTasks.any { it.name == "bundleRelease" } && !keystorePropertiesFile.exists()) {
        throw GradleException(
            "android/key.properties مفقود: لا يمكن بناء AAB للنشر بمفتاح debug. " +
                "انسخ android/key.properties.example إلى key.properties واملأه ببيانات مفتاح الرفع."
        )
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}

flutter {
    source = "../.."
}
dependencies {
    // إضافة مكتبة Material Components
    implementation("com.google.android.material:material:1.9.0")
}
