# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Google Sign-In classes
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep WebView JavaScript interface methods
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep security crypto classes
-keep class androidx.security.crypto.** { *; }

# Standard Android rules
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exception
