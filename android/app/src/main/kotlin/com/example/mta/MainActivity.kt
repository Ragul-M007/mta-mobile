package com.multicorp.mtaarch

import android.Manifest
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    // Mark CAMERA permission for revocation when the process terminates.
    // This ensures that "Allow once" grants are cleared on every app close,
    // so the next fresh launch always prompts the permission dialog again.
    override fun onStop() {
        super.onStop()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            revokeSelfPermissionsOnKill(listOf(Manifest.permission.CAMERA))
        }
    }
}
