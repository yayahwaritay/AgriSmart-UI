package com.sl.agrismart;

import io.flutter.embedding.android.FlutterFragmentActivity;

// FlutterFragmentActivity (not FlutterActivity) is required by biometric_signature's use of
// androidx.biometric.BiometricPrompt, which needs a FragmentActivity host.
public class MainActivity extends FlutterFragmentActivity {
}
