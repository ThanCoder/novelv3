package com.example.novel_v3

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity()

/*{
	private val channel = "thancoder.than_pkg"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger,channel).setMethodCallHandler { call, result ->
			when(call.method){
				"get_version" -> getAndroidVersion()
				else ->{
					result.notImplemented()
				}
			}
		}
	}

	private fun getAndroidVersion():String{
		return Build.VERSION.RELEASE
	}
}*/
