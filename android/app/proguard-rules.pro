# Flutter Proguard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.pigeon.** { *; }

# Keep Shared Preferences plugin classes specifically
-keep class com.example.shared_preferences.** { *; }
-keep class dev.flutter.pigeon.shared_preferences_android.** { *; }

# Keep FFmpeg Kit classes
-keep class com.arthenica.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-keep class com.antonkarpenko.ffmpegkit.model.** { *; }
-dontwarn com.arthenica.ffmpegkit.**
-dontwarn com.antonkarpenko.ffmpegkit.**

# Ignore Play Core warnings (R8 missing classes)
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
