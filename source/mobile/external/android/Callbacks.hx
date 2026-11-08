package mobile.external.android;

#if android
import lime.system.JNI;

import flixel.util.FlxSignal.FlxTypedSignal;

class Callbacks implements JNISafety
{
    public static final REQUEST_FILE_SELECT:Int = 1;
    public static final REQUEST_FILE_SELECT_DIR:Int = 2;
    public static final REQUEST_FILE_SAVE:Int = 3;

    public static var onActivityResult:FlxTypedSignal<Int->Int->Dynamic->Void> = new FlxTypedSignal<Int->Int->Dynamic->Void>();

    public function new() {}

    public static function init():Void {
        var initJNI = JNI.createStaticMethod('psych/Callbacks', 'init', '(Lorg/haxe/lime/HaxeObject;)V');

        if (initJNI != null) {
            initJNI(new Callbacks());
        }
    }

    public function getExternalFolderName():String {
        return haxe.io.Path.removeTrailingSlashes(mobile.backend.StorageUtil.externalFolder);
    }

    public function callActivityResult(requestCode:Int, resultCode:Int, data:Dynamic):Void {
        onActivityResult.dispatch(requestCode, resultCode, data);
    }
}
#end