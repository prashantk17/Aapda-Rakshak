import org.gradle.api.tasks.Delete
import java.io.File

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // use add("classpath", ...) to avoid unresolved reference to `classpath(...)` in some Kotlin DSL setups
        add("classpath", "com.google.gms:google-services:4.4.1")
        // if you also need Android Gradle Plugin here, add it similarly:
        // add("classpath", "com.android.tools.build:gradle:7.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Use the default Gradle build directories so Flutter tooling can
// reliably locate the generated APKs (e.g. `android/app/build/...`).
// If you previously changed `rootProject.buildDir`, that can move
// outputs and break Flutter's post-build file lookup.

// Provide a clean task that removes this project's build directory.
tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
