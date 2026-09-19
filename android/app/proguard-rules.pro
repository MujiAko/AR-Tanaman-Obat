# TensorFlow Lite & R8 / Proguard rules
-dontwarn org.tensorflow.lite.**
-dontwarn org.tensorflow.lite.gpu.**

-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }

# Ignore missing optional GPU delegate classes
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.GpuDelegate**

# General Keep Rules for TFLite Flutter
-keepclassmembers class * {
    *** native* (...);
}
