package com.example.frontoned

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.ViewGroup
import android.widget.ImageView

class SplashActivity : Activity() {
    companion object {
        private var activeActivity: SplashActivity? = null

        fun finishIfVisible() {
            activeActivity?.finish()
            activeActivity = null
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        activeActivity = this

        val splashImage = ImageView(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
            scaleType = ImageView.ScaleType.CENTER_CROP
            setImageResource(R.drawable.peace_player_splash)
        }
        setContentView(splashImage)

        splashImage.postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            overridePendingTransition(0, 0)
        }, 500)
    }

    override fun onDestroy() {
        if (activeActivity === this) activeActivity = null
        super.onDestroy()
    }
}
