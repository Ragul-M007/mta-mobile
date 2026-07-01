package com.multicorp.mtaarch

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    // Revoke only permissions that the user granted as "Allow once" (FLAG_PERMISSION_ONE_TIME).
    // Permanent grants ("While using the app") are left untouched so the dialog
    // does not appear again on the next launch.
    override fun onStop() {
        super.onStop()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val candidates = listOf(
                Manifest.permission.CAMERA,
                Manifest.permission.RECORD_AUDIO
            )
            val oneTimeGrants = candidates.filter { perm ->
                try {
                    val flags = packageManager.getPermissionFlags(
                        perm, packageName, Process.myUserHandle()
                    )
                    (flags and PackageManager.FLAG_PERMISSION_ONE_TIME) != 0
                } catch (_: Exception) {
                    false
                }
            }
            if (oneTimeGrants.isNotEmpty()) {
                revokeSelfPermissionsOnKill(oneTimeGrants)
            }
        }
    }
}
