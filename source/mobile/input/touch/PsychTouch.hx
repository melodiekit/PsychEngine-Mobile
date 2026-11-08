package mobile.input.touch;

import flixel.input.touch.FlxTouch;

@:allow(mobile.input.touch.PsychTouchManager)
class PsychTouch extends FlxTouch
{
	public static var swipeThreshold:Int = 10;

	public var justDoublePressed:Bool = false;
	public var doublePressed:Bool = false;

	public var swiped:Bool = false;
	public var justMoved(get, never):Bool;
	public var deltaX(get, never):Int;
	public var deltaY(get, never):Int;
	public var deltaScreenX(get, never):Int;
	public var deltaScreenY(get, never):Int;

	var _prevX:Int = 0;
	var _prevY:Int = 0;
	var _prevScreenX:Int = 0;
	var _prevScreenY:Int = 0;
	var _deltaAccumlationX:Int = 0;
	var _deltaAccumlationY:Int = 0;

	public function reset() {
		swiped = false;
		doublePressed = false;
		input.reset();
	}

	override function update():Void {
		super.update();
		if (pressed && justDoublePressed) {
			justDoublePressed = false;
		}
	}

	function updatePreviousPositions():Void {
		_prevX = x;
		_prevY = y;
		_prevScreenX = screenX;
		_prevScreenY = screenY;
	}

	inline function get_justMoved():Bool {
		return _prevX !=x || _prevY != y;
	}

	inline function get_deltaX():Int {
		return x - _prevX;
	}

	inline function get_deltaY():Int {
		return y - _prevY;
	}

	inline function get_deltaScreenX():Int {
		return screenX - _prevScreenX;
	}

	inline function get_deltaScreenY():Int {
		return screenY - _prevScreenY;
	}
}