plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai_productivity_super_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.ai_productivity_super_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Enable multidex
        multiDexEnabled = true

        // Set manifest placeholders using mutableMapOf
        manifestPlaceholders.putAll(mutableMapOf(
            "appIcon" to "@mipmap/ic_launcher",
            "notificationChannelId" to "task_channel",
            "notificationChannelName" to "Task Reminders"
        ))
    }

    buildTypes {
        release {
            // Using debug keys for now (no signing config added as per request)
            signingConfig = signingConfigs.getByName("debug")

            // Minify and optimize
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // Keep debug build unminified
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // AAPT options
    aaptOptions {
        additionalParameters.addAll(listOf("--no-version-vectors"))
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.24")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2")

    // Add dependency for notification compatibility
    implementation("androidx.core:core:1.12.0")
}