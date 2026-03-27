buildscript {
    repositories {
        google()       // لازم موجود
        mavenCentral() // لازم موجود
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// تغيير مكان بناء المشروع (اختياري حسب إعدادك)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}