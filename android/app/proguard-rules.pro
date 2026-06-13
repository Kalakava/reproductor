# Keep just_audio classes
-keep class com.ryanheise.just_audio.** { *; }

# Keep Android audio-related classes for Equalizer and platform-specific features
-keep class android.media.audiofx.** { *; }
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }
