package mobile.options;

import options.*;

import mobile.backend.MobileData;

class MobileSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = Language.getPhrase('mobile_menu', 'Mobile Settings');
		rpcTitle = 'Mobile Settings Menu';

		var option:Option = new Option('Control Alpha',
			'How transparent should the controls be?',
			'controlAlpha',
			FLOAT);
		option.defaultValue = 0.6;
		option.changeValue = 0.1;
		option.minValue = 0;
		option.maxValue = 1;
		option.scrollSpeed = 1;
		option.onChange = onChangeControlAlpha;
		addOption(option);

		var option:Option = new Option('Hitbox Style',
			'Which hitbox style should be used?',
			'hitboxStyle',
			STRING,
			MobileData.hitboxStyles);
		addOption(option);

		var option:Option = new Option('Show Hitbox Hints',
			'Shows the hitbox borders at all times.',
			'hitboxHints',
			BOOL);
		addOption(option);

		super();
	}

	function onChangeControlAlpha() {
		virtualPad.alpha = ClientPrefs.data.controlAlpha;
	}
}