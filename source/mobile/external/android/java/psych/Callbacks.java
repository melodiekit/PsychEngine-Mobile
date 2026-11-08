package psych;

import android.content.Intent;
import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

public class Callbacks extends Extension
{
    public static final int REQUEST_FILE_SELECT = 1;
    public static final int REQUEST_FILE_SELECT_DIR = 2;
    public static final int REQUEST_FILE_SAVE = 3;

    static HaxeObject haxeObject;

    public static void init(HaxeObject obj) {
        haxeObject = obj;
    }

    public static String getExternalFolderName() {
        return haxeObject.call0("getExternalFolderName").toString();
    }

    @Override
	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
        haxeObject.call3("callActivityResult", requestCode, resultCode, data);
		return true;
	}
}