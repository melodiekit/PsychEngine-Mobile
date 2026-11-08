package states;

#if android
import mobile.backend.StorageUtil;
#end

import haxe.io.Path;

import openfl.utils.Assets;
import openfl.utils.ByteArray;

import flixel.ui.FlxBar;

class CopyState extends MusicBeatState
{
	public static var saveExtensions:Array<String> = ['txt', 'json', 'xml'];
	public static var assetFolders:Array<String> = ['assets/', 'mods/']; // Folders to copy
	public static var ignoreFolders:Array<String> = ['embed']; // Don't include a slash at the end when putting folders in here
	public static var filesToAdd:Array<String> = [];

	public var bg:FlxSprite;
	public var progressBar:FlxBar;
	public var progressText:FlxText;
	public var filesCopied:Int = 0;
	public var filesTotal:Int = 0;
	public var failedFiles:Array<String> = [];
	public var failedStack:Array<String> = [];

	override function create() {
		if (!findNewFiles()) {
			MusicBeatState.switchState(new states.TitleState());
			return;
		}

		var msg:String = 'Found new files that are necessary to start the game.';

		FlxG.stage.window.alert('$msg Press OK to start the copying process.', 'Notice!');

		filesTotal = filesToAdd.length;

		bg = new FlxSprite(0, 0, Paths.image('funkay'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		add(bg);

		progressBar = new FlxBar(0, FlxG.height - 30, LEFT_TO_RIGHT, FlxG.width, 30);
		add(progressBar);

		progressText = new FlxText(0, progressBar.y + 7, FlxG.width, '', 16);
		progressText.setFormat('VCR OSD Mono', 16, 0xFFFFFFFF, CENTER, OUTLINE);
		add(progressText);

		sys.thread.Thread.create(startCopyProcess);

		super.create();
	}

	override function update(elapsed:Float) {
		if (progressText != null && progressText.text != 'Completed!') progressText.text = filesCopied == filesTotal ? 'Completed!' : '$filesCopied/$filesTotal';
		if (progressBar != null) progressBar.percent = (filesCopied / filesTotal) * 100;
		super.update(elapsed);
	}

	public static function findNewFiles():Bool {
		filesToAdd = Assets.list().filter(file->{
			var startsWith:Bool = false;
			for (folder in assetFolders) {
				if (file.startsWith(folder)) startsWith = true;
			}
			if (!startsWith) return false;
			for (folder in file.split('/')) {
				if (ignoreFolders.contains(folder)) return false;
			}
			if (#if android file.startsWith('mods/') && !FileSystem.exists(StorageUtil.getPsychFolder() + file) || #end !FileSystem.exists(file)) return true;
			return false;
		});
		trace('files found: $filesToAdd');
		return filesToAdd.length > 0;
	}

	function startCopyProcess() {
		for (file in filesToAdd) {
			var name:String = Path.withoutDirectory(file);
			var dir:String = Path.directory(file);
			#if android
			if (file.startsWith('mods/')) dir = StorageUtil.getPsychFolder() + dir;
			#end
			try {
				if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir)) {
					FileSystem.createDirectory(dir);
				}
				if (saveExtensions.contains(Path.extension(file).toLowerCase())) {
					File.saveContent(Path.join([dir, name]), Assets.getText(file));
				}
				else File.saveBytes(Path.join([dir, name]), getBytes(file));
			}
			catch(e:Dynamic) {
				failedFiles.push(file);
				failedStack.push('$file $e');
				trace('failed to copy file $file\n$e');
			}
			filesCopied++;
		}
		if (failedFiles.length > 0) {
			var dateNow:String = Date.now().toString();

			dateNow = dateNow.replace(" ", "_");
			dateNow = dateNow.replace(":", "'");

			var path = "./crash/" + "CopyState_" + dateNow + ".txt";

			if (!FileSystem.exists("./crash/"))
				FileSystem.createDirectory("./crash/");

			File.saveContent(path, failedStack.join('\n'));

			FlxG.stage.window.alert(failedFiles.join('\n'), 'Failed to copy ${failedFiles.length} files');
		}
		FlxG.sound.play(Paths.sound('confirmMenu')).onComplete = ()->MusicBeatState.switchState(new states.TitleState());
	}

	static function getBytes(file:String, embedded:Bool = true) {
		switch(Path.extension(file).toLowerCase()) {
			case 'ttf', 'otf': return ByteArray.fromFile(file);
			default: return embedded ? Assets.getBytes(file) : File.getBytes(file);
		}
	}
}