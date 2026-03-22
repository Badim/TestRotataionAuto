package plugin.orientation;

import android.content.pm.ActivityInfo;

import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaEnvironment;
import com.naef.jnlua.JavaFunction;
import com.naef.jnlua.LuaState;
import com.naef.jnlua.NamedJavaFunction;

/**
 * Runtime screen orientation for Solar2D (Android).
 *
 * Lua:
 *   local o = require("plugin.orientation")
 *   o.set("landscape")           -- fixed landscape (sensor off)
 *   o.set("landscapeSensor")     -- either landscape, follows sensor
 *   o.set("portrait")
 *   o.set("sensor")              -- all orientations
 *   o.set("user")                -- respect user / app policy
 *
 * Build this class into plugin.orientation.jar using the Solar2D Native
 * Android "plugin" module (see README in native_plugin_orientation).
 */
public class LuaLoader implements JavaFunction {

	public LuaLoader() {
	}

	@Override
	public int invoke(LuaState L) {
		NamedJavaFunction[] luaFunctions = new NamedJavaFunction[] {
			new SetWrapper(),
		};
		String libName = L.toString(1);
		L.register(libName, luaFunctions);
		return 1;
	}

	private static final class SetWrapper implements NamedJavaFunction {
		@Override
		public String getName() {
			return "set";
		}

		@Override
		public int invoke(LuaState L) {
			String mode = "user";
			if (L.getTop() >= 1 && L.isString(-1)) {
				mode = L.toString(-1);
			}
			final int orientation = mapMode(mode);
			final CoronaActivity activity = CoronaEnvironment.getCoronaActivity();
			if (activity != null) {
				activity.runOnUiThread(new Runnable() {
					@Override
					public void run() {
						try {
							activity.setRequestedOrientation(orientation);
						} catch (Throwable ignored) {
						}
					}
				});
			}
			return 0;
		}
	}

	/**
	 * Maps Solar2D / common names to {@link ActivityInfo} screen orientation constants.
	 */
	static int mapMode(String mode) {
		if (mode == null) {
			return ActivityInfo.SCREEN_ORIENTATION_USER;
		}
		switch (mode) {
			case "landscape":
			case "landscapeRight":
				return ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
			case "landscapeLeft":
			case "landscapeReverse":
				return ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
			case "landscapeSensor":
				return ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE;
			case "portrait":
				return ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
			case "portraitUpsideDown":
			case "portraitReverse":
				return ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
			case "portraitSensor":
				return ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
			case "sensor":
			case "fullSensor":
				return ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
			case "unspecified":
				return ActivityInfo.SCREEN_ORIENTATION_UNSPECIFIED;
			case "behind":
				return ActivityInfo.SCREEN_ORIENTATION_BEHIND;
			case "nosensor":
				return ActivityInfo.SCREEN_ORIENTATION_NOSENSOR;
			case "user":
			default:
				return ActivityInfo.SCREEN_ORIENTATION_USER;
		}
	}
}
