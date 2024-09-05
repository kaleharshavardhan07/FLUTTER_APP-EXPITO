# Keep all classes and methods from the google_generative_ai package
-keep class com.google.** { *; }
-keep class com.google.api.** { *; }

# Keep all classes and methods from the json_encode library
-keep class com.google.gson.** { *; }
-keep class com.fasterxml.jackson.** { *; }

# Keep all classes and methods from your app's package
-keep class com.example.** { *; }

# Keep the Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }

# Keep the generated plugin registrant
-keep class io.flutter.plugin.GeneratedPluginRegistrant { *; }
