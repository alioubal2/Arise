package com.arise.arise

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

/// Activité principale d'Arise.
///
/// Configurée pour pouvoir s'afficher par-dessus l'écran verrouillé et allumer
/// l'écran lorsque l'alarme se déclenche (full-screen intent). Comportement
/// attendu d'une application d'alarme dédiée.
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
    }
}
