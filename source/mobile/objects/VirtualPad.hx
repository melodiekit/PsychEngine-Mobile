package mobile.objects;

import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;
import mobile.backend.MobileData;
import mobile.input.MobileInputID;
import mobile.input.MobileInputManager;
import mobile.objects.TouchButton;

/**
 * A gamepad which contains 4 directional buttons and 4 action buttons.
 * It's easy to set the callbacks and to customize the layout.
 *
 * @author Ka Wing Chin
 * @modification melodiekit
 */
class VirtualPad extends MobileInputManager
{
	public var buttonLeft:TouchButton = new TouchButton(0, 0, [MobileInputID.LEFT, MobileInputID.NOTE_LEFT]);
	public var buttonDown:TouchButton = new TouchButton(0, 0, [MobileInputID.DOWN, MobileInputID.NOTE_DOWN]);
	public var buttonUp:TouchButton = new TouchButton(0, 0, [MobileInputID.UP, MobileInputID.NOTE_UP]);
	public var buttonRight:TouchButton = new TouchButton(0, 0, [MobileInputID.RIGHT, MobileInputID.NOTE_RIGHT]);
	public var buttonA:TouchButton = new TouchButton(0, 0, [MobileInputID.A]);
	public var buttonB:TouchButton = new TouchButton(0, 0, [MobileInputID.B]);
	public var buttonC:TouchButton = new TouchButton(0, 0, [MobileInputID.C]);
	public var buttonD:TouchButton = new TouchButton(0, 0, [MobileInputID.D]);
	public var buttonE:TouchButton = new TouchButton(0, 0, [MobileInputID.E]);
	public var buttonF:TouchButton = new TouchButton(0, 0, [MobileInputID.F]);
	public var buttonG:TouchButton = new TouchButton(0, 0, [MobileInputID.G]);
	public var buttonS:TouchButton = new TouchButton(0, 0, [MobileInputID.S]);
	public var buttonV:TouchButton = new TouchButton(0, 0, [MobileInputID.V]);
	public var buttonX:TouchButton = new TouchButton(0, 0, [MobileInputID.X]);
	public var buttonY:TouchButton = new TouchButton(0, 0, [MobileInputID.Y]);
	public var buttonZ:TouchButton = new TouchButton(0, 0, [MobileInputID.Z]);

	public var allowSwiping(default, set):Bool = true;

	/**
	 * Create a gamepad which contains 4 directional buttons and 4 action buttons.
	 *
	 * @param   DPadMode     The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */
	public function new(?DPad:FlxDPadMode, ?Action:FlxActionMode)
	{
		super();
		scrollFactor.set();

		#if !mobile return; #end

		if (DPad == null)
			DPad = LEFT_FULL;
		if (Action == null)
			Action = A_B_C;

		var storedKeys:Map<String, MobileInputID> = [];
		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) storedKeys.set(button, spr.IDs);
		}

		addDPad(DPad);
		addAction(Action);

		for (button in Reflect.fields(this)) {
			var spr = Reflect.field(this, button);
			if (spr is TouchButton) spr.IDs = storedKeys.get(button);
		}
		updateTrackedButtons();
	}

	override public function destroy():Void
	{
		super.destroy();

		buttonA = null;
		buttonB = null;
		buttonC = null;
		buttonD = null;
		buttonE = null;
		buttonF = null;
		buttonG = null;
		buttonS = null;
		buttonV = null;
		buttonX = null;
		buttonY = null;
		buttonX = null;
		buttonLeft = null;
		buttonUp = null;
		buttonDown = null;
		buttonRight = null;
	}

	/**
	 * @param   DPad   The DPad mode to add.
	*/
	public function addDPad(?DPad:FlxDPadMode = NONE) {
		#if !mobile return; #end
		switch (DPad)
		{
			case UP_DOWN:
				add(buttonUp = createButton(0, FlxG.height - 248, 132, 127, "up", 0xFF12FA05));
				add(buttonDown = createButton(0, FlxG.height - 124, 132, 127, "down", 0xFF00FFFF));
			case LEFT_RIGHT:
				add(buttonLeft = createButton(0, FlxG.height - 133, 132, 127, "left", 0xFFC24B99));
				add(buttonRight = createButton(127, FlxG.height - 133, 132, 127, "right", 0xFFF9393F));
			case LEFT_FULL:
				add(buttonUp = createButton(98, FlxG.height - 315, 132, 127, "up", 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 220, 132, 127, "left", 0xFFC24B99));
				add(buttonRight = createButton(196, FlxG.height - 220, 132, 127, "right", 0xFFF9393F));
				add(buttonDown = createButton(98, FlxG.height - 124, 132, 127, "down", 0xFF00FFFF));
			case RIGHT_FULL:
				add(buttonUp = createButton(FlxG.width - 225, FlxG.height - 316, 132, 127, "up", 0xFF12FA05));
				add(buttonLeft = createButton(FlxG.width - 328, FlxG.height - 220, 132, 127, "left", 0xFFC24B99));
				add(buttonRight = createButton(FlxG.width - 132, FlxG.height - 220, 132, 127, "right", 0xFFF9393F));
				add(buttonDown = createButton(FlxG.width - 225, FlxG.height - 124, 132, 127, "down", 0xFF00FFFF));
			case CUSTOM:
				add(buttonUp = createButton(98, FlxG.height - 315, 132, 127, "up", 0xFF12FA05));
				add(buttonLeft = createButton(0, FlxG.height - 220, 132, 127, "left", 0xFFC24B99));
				add(buttonRight = createButton(196, FlxG.height - 220, 132, 127, "right", 0xFFF9393F));
				add(buttonDown = createButton(98, FlxG.height - 124, 132, 127, "down", 0xFF00FFFF));
				MobileData.loadCustomPad(this);
			case NONE:
		}
	}

	/**
	 * @param   Action   The Action mode to add.
	*/
	public function addAction(?Action:FlxActionMode = NONE) {
		#if !mobile return; #end
		switch (Action)
		{
			case A:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a", 0xFFFF0000));
			case B:
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
			case C:
				add(buttonC = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "c", 0xFF44FF00));
			case D:
				add(buttonD = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "d", 0xFF0078FF));
			case E:
				add(buttonE = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "e", 0xFFFF7D00));
			case F:
				add(buttonF = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "f", 0xFFB1FC00));
			case G:
				add(buttonG = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "g", 0xFFFF009D));
			case S:
				add(buttonS = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "s", 0xFFEA00FF));
			case V:
				add(buttonV = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "v", 0xFF49A9B2));
			case X:
				add(buttonX = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "x", 0xFF99062D));
			case Y:
				add(buttonY = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "y", 0xFF4A35B9));
			case Z:
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "z", 0xFFCCB98E));
			case A_B:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a", 0xFFFF0000));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
			case B_C:
				add(buttonB = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
				add(buttonC = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "c", 0xFF44FF00));
			case A_B_C:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a", 0xFFFF0000));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
				add(buttonC = createButton(FlxG.width - 396, FlxG.height - 127, 132, 127, "c", 0xFF44FF00));
			case A_B_X_Y:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a", 0xFFFF0000));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
				add(buttonX = createButton(FlxG.width - 396, FlxG.height - 127, 132, 127, "x", 0xFF99062D));
				add(buttonY = createButton(FlxG.width - 528, FlxG.height - 127, 132, 127, "y", 0xFF4A35B9));
			case A_B_C_X_Y:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a", 0xFFFF0000));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
				add(buttonC = createButton(FlxG.width - 396, FlxG.height - 127, 132, 127, "c", 0xFF44FF00));
				add(buttonX = createButton(FlxG.width - 264, FlxG.height - 254, 132, 127, "x", 0xFF99062D));
				add(buttonY = createButton(FlxG.width - 132, FlxG.height - 254, 132, 127, "y", 0xFF4A35B9));
			case A_B_C_X_Y_Z:
				add(buttonA = createButton(FlxG.width - 132, FlxG.height - 127, 132, 127, "a", 0xFFFF0000));
				add(buttonB = createButton(FlxG.width - 264, FlxG.height - 127, 132, 127, "b", 0xFFFFCB00));
				add(buttonC = createButton(FlxG.width - 396, FlxG.height - 127, 132, 127, "c", 0xFF44FF00));
				add(buttonX = createButton(FlxG.width - 396, FlxG.height - 254, 132, 127, "x", 0xFF99062D));
				add(buttonY = createButton(FlxG.width - 264, FlxG.height - 254, 132, 127, "y", 0xFF4A35B9));
				add(buttonZ = createButton(FlxG.width - 132, FlxG.height - 254, 132, 127, "z", 0xFFCCB98E));
			case NONE:
		}
	}

	/**
	 * @param   X          The x-position of the button.
	 * @param   Y          The y-position of the button.
	 * @param   Width      The width of the button.
	 * @param   Height     The height of the button.
	 * @param   Graphic    The image of the button. It must contains 3 frames (`NORMAL`, `HIGHLIGHT`, `PRESSED`).
	 * @return  The button
	 */
	public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, Color:FlxColor = FlxColor.WHITE):TouchButton
	{
		var button = new TouchButton(X, Y);
		button.frames = FlxTileFrames.fromFrame(Paths.getSparrowAtlas('virtualpad').getByName(Graphic), FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.color = Color;
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();

		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end

		button.onDown.callback = function() {
			onPressed.dispatch(button);
		}

		button.onOut.callback = button.onUp.callback = function() {
			onReleased.dispatch(button);
		}

		return button;
	}

	function set_allowSwiping(value:Bool) {
		for (button in this) {
			if (button is TouchButton) {
				button.allowSwiping = value;
			}
		}
		return allowSwiping = value;
	}
}

enum FlxDPadMode
{
	NONE;
	UP_DOWN;
	LEFT_RIGHT;
	LEFT_FULL;
	RIGHT_FULL;
	CUSTOM;
}

enum FlxActionMode
{
	NONE;
	A;
	B;
	C;
	D;
	E;
	F;
	G;
	S;
	V;
	X;
	Y;
	Z;
	A_B;
	B_C;
	A_B_C;
	A_B_X_Y;
	A_B_C_X_Y;
	A_B_C_X_Y_Z;
}