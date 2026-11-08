package mobile.backend;

#if android
import extension.androidtools.Permissions;
import extension.androidtools.Settings;
import extension.androidtools.os.Environment;
import extension.androidtools.os.Build.VERSION;
import extension.androidtools.os.Build.VERSION_CODES;
#end

class StorageUtil
{
	public static var externalFolder:String = '.PsychEngine';

	public static function getExternalDir() {
		return '/storage/emulated/0/';
	}

	public static function getPsychFolder() {
		return haxe.io.Path.addTrailingSlash(StorageUtil.getExternalDir() + externalFolder);
	}

	#if android
	public static function requestPermissions() {
		if (VERSION.SDK_INT < VERSION_CODES.R) {
			Permissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);
		}
		else if (!Environment.isExternalStorageManager()) {
			Settings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		if (!Environment.isExternalStorageManager() || VERSION.SDK_INT < VERSION_CODES.R && !StorageUtil.getGrantedPermissions().contains('android.permission.READ_EXTERNAL_STORAGE')) {
			FlxG.stage.window.alert('Make sure that you have accepted all necessary permissions, expect a crash otherwise.', 'Notice!');
		}
	}

	public static function setupExternalStorage() {
		try {
			if (!FileSystem.exists(StorageUtil.getPsychFolder()) || !FileSystem.isDirectory(StorageUtil.getPsychFolder())) {
				FileSystem.createDirectory(StorageUtil.getPsychFolder());
			}
		}
		catch(e:Dynamic) {
			FlxG.stage.window.alert('Failed to create storage.\nPlease manually create directory ${StorageUtil.getPsychFolder()}.', 'Error!');
			lime.system.System.exit(1);
		}

		try {
			if (!FileSystem.exists(StorageUtil.getPsychFolder() + 'mods/') || !FileSystem.isDirectory(StorageUtil.getPsychFolder() + 'mods/')) {
				FileSystem.createDirectory(StorageUtil.getPsychFolder() + 'mods/');
			}
		}
		catch(e:Dynamic) {
			FlxG.stage.window.alert('Failed to create storage.\nPlease manually create directory ' + StorageUtil.getPsychFolder() + 'mods/.', 'Error!');
			lime.system.System.exit(1);
		}
	}

	// remaking the function because the original function is broken on 2.2.2 lol
	public static inline function getGrantedPermissions():Array<String>
	{
		final getGrantedPermissionsJNI:Null<Dynamic> = extension.androidtools.jni.JNICache.createStaticMethod('org/haxe/extension/Tools', 'getGrantedPermissions', '()[Ljava/lang/String;');

		return getGrantedPermissionsJNI != null ? getGrantedPermissionsJNI() : [];
	}
	#end
}