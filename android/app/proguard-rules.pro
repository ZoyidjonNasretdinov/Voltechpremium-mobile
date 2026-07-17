-keep class com.google.mlkit.** { *; }
-keep interface com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class androidx.camera.** { *; }
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}
