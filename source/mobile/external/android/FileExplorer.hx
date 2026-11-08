package mobile.external.android;

#if android
import haxe.io.Path;

import lime.system.JNI;

import mobile.backend.StorageUtil;
import mobile.external.android.Callbacks;

class FileExplorer implements JNISafety
{
    public static var uriAddon(default, set):String = '';

    public static function selectFile(types:Array<String>, onSelect:String->Void, ?onCancel:Void->Void, ?onError:Void->Void) {
        var selectFileJNI = JNI.createStaticMethod('psych/FileExplorer', 'selectFile', '([Ljava/lang/String;)V');

        if (selectFileJNI != null) {
            Callbacks.onActivityResult.addOnce(function(requestCode:Int, resultCode:Int, data:Dynamic) {
                if (requestCode == Callbacks.REQUEST_FILE_SELECT) {
                    if (resultCode == -1) { // successfully picked file
                        if (data != null) {
                            var fileName:String = getFileName(data);
                            onSelect(fileName);
                        }
                        else {
                            if (onError != null) onError();
                        }
                    }
                    else {
                        if (onCancel != null) onCancel();
                    }
                    uriAddon = '';
                }
            });
            if (types == null || types.length < 1) types = [MIMEType.ANY];
            selectFileJNI(types);
        }
    }

    public static function selectDirectory(onSelect:String->Void, ?onCancel:Void->Void, ?onError:Void->Void) {
        var selectDirectoryJNI = JNI.createStaticMethod('psych/FileExplorer', 'selectDirectory', '()V');

        if (selectDirectoryJNI != null) {
            Callbacks.onActivityResult.addOnce(function(requestCode:Int, resultCode:Int, data:Dynamic) {
                if (requestCode == Callbacks.REQUEST_FILE_SELECT_DIR) {
                    if (resultCode == -1) {
                        if (data != null) {
                            var folderName:String = getFileName(data);
                            onSelect(folderName);
                        }
                        else {
                            if (onError != null) onError();
                        }
                    }
                    else {
                        if (onCancel != null) onCancel();
                    }
                    uriAddon = '';
                }
            });
            selectDirectoryJNI();
        }
    }

    public static function saveFile(content:String, ?type:String = 'text/plain', ?defaultName:String = 'file', ?onSave:String->Void, ?onCancel:Void->Void, ?onError:Void->Void) {
        var saveFileJNI = JNI.createStaticMethod('psych/FileExplorer', 'saveFile', '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V');

        if (saveFileJNI != null) {
            Callbacks.onActivityResult.addOnce(function(requestCode:Int, resultCode:Int, data:Dynamic) {
                if (requestCode == Callbacks.REQUEST_FILE_SAVE) {
                    if (resultCode == -1) {
                        if (data != null) {
                            var fileName:String = getFileName(data);
                            try {
                                if (!FileSystem.exists(Path.directory(fileName))) {
                                    FileSystem.createDirectory(Path.directory(fileName));
                                }
                                File.saveContent(fileName, content);
                            }
                            catch(e) {
                                trace('$e');
                                if (onError != null) onError();
                                return;
                            }
                            if (onSave != null) onSave(fileName);
                        }
                        else {
                            if (onError != null) onError();
                        }
                    }
                    else {
                        if (onCancel != null) onCancel();
                    }
                    uriAddon = '';
                }
            });
            saveFileJNI(content, type, defaultName);
        }
    }

    // meant to be used with the Intent type!!!
    public static function getFileName(data:Dynamic) {
        var getFileNameJNI = JNI.createStaticMethod('psych/FileExplorer', 'getFileName', '(Landroid/content/Intent;)Ljava/lang/String;');
        if (getFileNameJNI != null) {
            var fileName:String = getFileNameJNI(data);
            if (fileName.indexOf(StorageUtil.getExternalDir()) <= -1) fileName = StorageUtil.getExternalDir() + fileName;
            return fileName;
        }
        return null;
    }

    static function setUriAddon(path:String = '') {
        var setUriAddonJNI = JNI.createStaticMethod('psych/FileExplorer', 'setUriAddon', '(Ljava/lang/String;)V');
        if (setUriAddonJNI != null) {
            setUriAddonJNI(path);
        }
    }

    static function set_uriAddon(value:String) {
        if (value == null) value = '';
        uriAddon = value;
        setUriAddon(value);
        return value;
    }
}

class MIMEType
{
    public static final ANY:String = '*/*';
    public static final TXT:String = 'text/plain';
    public static final JSON:String = 'application/json';
    public static final XML:String = 'application/xml';
    public static final PNG:String = 'image/png';
    public static final OGG:String = 'audio/ogg';

    public static function filterToMIME(filter:Array<openfl.net.FileFilter>):Array<String> {
        var androidFilters:Array<String> = [];
        for (fil in filter) {
            var split = fil.extension.split(';');
            for (type in split) {
		    	var ext = type.toUpperCase();
		    	if (ext.indexOf('.') != -1) {
			    	ext = ext.substring(ext.indexOf('.') + 1);
			    }
		    	var mime = Reflect.field(MIMEType, ext);
                if (mime != null) androidFilters.push(mime);
            }
		}
        return androidFilters;
    }
}
#end