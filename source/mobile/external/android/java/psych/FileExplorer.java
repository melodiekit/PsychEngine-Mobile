package psych;

import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.DocumentsContract;
import android.provider.OpenableColumns;
import android.os.storage.StorageManager;

import org.haxe.extension.Extension;

import psych.Callbacks;

public class FileExplorer {
	public static String uriAddon = "";

	public static void selectFile(String[] types) {
		Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
		intent.setType(types[0]);
		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
		intent.addCategory(Intent.CATEGORY_OPENABLE);
		intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, getPsychUri());
		if (types.length > 1) {
			intent.setType("*/*");
			intent.putExtra(Intent.EXTRA_MIME_TYPES, types);
		}
		Extension.mainActivity.startActivityForResult(intent, Callbacks.REQUEST_FILE_SELECT);
	}

	public static void selectDirectory() {
		Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT_TREE);
		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
		intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, getPsychUri());
		Extension.mainActivity.startActivityForResult(intent, Callbacks.REQUEST_FILE_SELECT_DIR);
	}

	public static void saveFile(String content, String type, String defaultName) {
		// do these null checks work? idfk lol
		if (type == null) type = "text/plain";
		if (defaultName == null) defaultName = "file";
		Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
		intent.setType(type);
		intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
		intent.addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
		intent.addCategory(Intent.CATEGORY_OPENABLE);
		intent.putExtra(Intent.EXTRA_TITLE, defaultName);
		intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, getPsychUri());
		Extension.mainActivity.startActivityForResult(intent, Callbacks.REQUEST_FILE_SAVE);
	}

	public static String getFileName(Intent data) {
		if (data == null) return null;
		Uri uri = data.getData();
		if (uri == null) return null;
		String result = null;
		result = uri.getPath();
		int index = result.indexOf("primary:") + 8;
		if (index < 0) {
			index = result.indexOf("/storage");
			// might happen on sdcard path idk i can't test
			if (index < 0) {
				index = 0;
			}
		}
		result = result.substring(index);
		return result;
	}

	public static Uri getPsychUri() {
		// Source - https://stackoverflow.com/a/67554693
		// Posted by blackapps, modified by community. See post 'Timeline' for change history
		// Retrieved 2026-11-06, License - CC BY-SA 4.0
		// Thx

		if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
    		StorageManager sm = (StorageManager) Extension.mainContext.getSystemService(Context.STORAGE_SERVICE);

   			Intent intent = sm.getPrimaryStorageVolume().createOpenDocumentTreeIntent();
  		  	String startDir = Callbacks.getExternalFolderName() + uriAddon;
    		Uri uri = intent.getParcelableExtra(DocumentsContract.EXTRA_INITIAL_URI);
    		String scheme = uri.toString();
    		scheme = scheme.replace("/root/", "/document/");
    		scheme += "%3A" + startDir;
    		uri = Uri.parse(scheme);
			return uri;
		}
		return null;
	}

	public static void setUriAddon(String path) {
		uriAddon = path;
	}
}