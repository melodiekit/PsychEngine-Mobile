package mobile.input.touch;

#if FLX_TOUCH
import openfl.Lib;
import openfl.events.TouchEvent;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

import flixel.input.IFlxInputManager;

/**
 * @author Zaphod
 */
 @:allow(mobile.backend.TouchUtil)
 @:access(flixel.input.touch.FlxTouch) // ??????????
class PsychTouchManager implements IFlxInputManager
{
	/**
	 * The maximum number of concurrent touch points supported by the current device.
	 */
	public static var maxTouchPoints:Int = 0;

	/**
	 * The amount of time in milliseconds that a double tap is able to be registered.
	 */
	public static var doubleTapThreshold:Float = 500;

	/**
	 * All active touches including just created, moving and just released.
	 */
	public var list:Array<PsychTouch>;

	/**
	 * Storage for inactive touches (some sort of cache for them).
	 */
	var _inactiveTouches:Array<PsychTouch>;

	/**
	 * Helper storage for active touches (for faster access)
	 */
	var _touchesCache:Map<Int, PsychTouch>;

	var _doubleTapTimer:Float = 0;
	var _doubleTapDistanceThreshold:Float = 50;
	var _lastTouchPos:FlxPoint = FlxPoint.get(0, 0);

	/**
	 * WARNING: can be null if no active touch with the provided ID could be found
	 */
	public inline function getByID(TouchPointID:Int):PsychTouch
	{
		return _touchesCache.get(TouchPointID);
	}

	/**
	 * Return the first touch if there is one, beware of null
	 */
	public function getFirst():PsychTouch
	{
		if (list[0] != null)
		{
			return list[0];
		}
		else
		{
			return null;
		}
	}

	/**
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion
	public function destroy():Void
	{
		for (touch in list)
		{
			touch.destroy();
		}
		list = null;

		for (touch in _inactiveTouches)
		{
			touch.destroy();
		}
		_inactiveTouches = null;

		_touchesCache = null;
	}

	/**
	 * Gets all touches which were just started
	 *
	 * @param	TouchArray	Optional array to fill with touch objects
	 * @return	Array with touches
	 */
	public function justStarted(?TouchArray:Array<PsychTouch>):Array<PsychTouch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<PsychTouch>();
		}

		var touchLen:Int = TouchArray.length;

		if (touchLen > 0)
		{
			TouchArray.splice(0, touchLen);
		}

		for (touch in list)
		{
			if (touch.justPressed)
			{
				TouchArray.push(touch);
			}
		}

		return TouchArray;
	}

	/**
	 * Gets all touches which were just ended
	 *
	 * @param	TouchArray	Optional array to fill with touch objects
	 * @return	Array with touches
	 */
	public function justReleased(?TouchArray:Array<PsychTouch>):Array<PsychTouch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<PsychTouch>();
		}

		var touchLen:Int = TouchArray.length;
		if (touchLen > 0)
		{
			TouchArray.splice(0, touchLen);
		}

		for (touch in list)
		{
			if (touch.justReleased)
			{
				TouchArray.push(touch);
			}
		}

		return TouchArray;
	}

	public function justDoublePressed(?TouchArray:Array<PsychTouch>):Array<PsychTouch>
	{
		if (TouchArray == null)
		{
			TouchArray = new Array<PsychTouch>();
		}

		var touchLen:Int = TouchArray.length;
		if (touchLen > 0)
		{
			TouchArray.splice(0, touchLen);
		}

		for (touch in list)
		{
			if (touch.justDoublePressed)
			{
				TouchArray.push(touch);
			}
		}

		return TouchArray;
	}

	/**
	 * Resets all touches to inactive state.
	 */
	public function reset():Void
	{
		_doubleTapTimer = 0;
		_lastTouchPos = null;

		for (key in _touchesCache.keys())
		{
			_touchesCache.remove(key);
		}

		for (touch in list)
		{
			touch.input.reset();
			_inactiveTouches.push(touch);
		}

		list.splice(0, list.length);
	}

	public function new()
	{
		list = new Array<PsychTouch>();
		_inactiveTouches = new Array<PsychTouch>();
		_touchesCache = new Map<Int, PsychTouch>();
		maxTouchPoints = Multitouch.maxTouchPoints;
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;

		Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, handleTouchBegin);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, handleTouchEnd);
		Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, handleTouchMove);
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchBegin(FlashEvent:TouchEvent):Void
	{
		var touch:PsychTouch = _touchesCache.get(FlashEvent.touchPointID);
		if (touch != null)
		{
			touch.setXY(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY));
			touch.pressure = FlashEvent.pressure;
		}
		else
		{
			touch = recycle(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY), FlashEvent.touchPointID, FlashEvent.pressure);
		}
		touch.updatePreviousPositions();
		touch.input.press();
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchEnd(FlashEvent:TouchEvent):Void
	{
		var touch:PsychTouch = _touchesCache.get(FlashEvent.touchPointID);

		if (touch != null)
		{
			touch.input.release();
			touch.updatePreviousPositions();
		}
	}

	/**
	 * Event handler so FlxGame can update touches.
	 */
	function handleTouchMove(FlashEvent:TouchEvent):Void
	{
		var touch:PsychTouch = _touchesCache.get(FlashEvent.touchPointID);

		if (touch != null)
		{
			touch.updatePreviousPositions();
			touch.setXY(Std.int(FlashEvent.stageX), Std.int(FlashEvent.stageY));
			touch.pressure = FlashEvent.pressure;
			touch._deltaAccumlationX += touch.deltaX;
			touch._deltaAccumlationY += touch.deltaY;
			if (!touch.swiped && (Math.abs(touch._deltaAccumlationX) >= PsychTouch.swipeThreshold || Math.abs(touch._deltaAccumlationY) >= PsychTouch.swipeThreshold)) {
				touch.swiped = true;
			}
		}
	}

	/**
	 * Internal function for adding new touches to the manager
	 *
	 * @param	Touch	A new PsychTouch object
	 * @return	The added PsychTouch object
	 */
	function add(Touch:PsychTouch):PsychTouch
	{
		list.push(Touch);
		_touchesCache.set(Touch.touchPointID, Touch);
		return Touch;
	}

	/**
	 * Internal function for touch reuse
	 *
	 * @param	X			stageX touch coordinate
	 * @param	Y			stageY touch coordinate
	 * @param	PointID		id of the touch
	 * @return	A recycled touch object
	 */
	function recycle(X:Int, Y:Int, PointID:Int, pressure:Float):PsychTouch
	{
		if (_inactiveTouches.length > 0)
		{
			var touch:PsychTouch = _inactiveTouches.pop();
			touch.recycle(X, Y, PointID, pressure);
			return add(touch);
		}
		return add(new PsychTouch(X, Y, PointID, pressure));
	}

	/**
	 * Called by the internal game loop to update the touch position in the game world.
	 * Also updates the just pressed/just released flags.
	 */
	function update():Void
	{
		var i:Int = list.length - 1;
		var touch:PsychTouch;

		while (i >= 0)
		{
			touch = list[i];

			// Touch ended at previous frame
			if (touch.released && !touch.justReleased)
			{
				touch.reset();
				_touchesCache.remove(touch.touchPointID);
				list.splice(i, 1);
				_inactiveTouches.push(touch);
			}
			else // Touch is active currently
			{
				touch.update();
			}

			if (touch.justPressed && _doubleTapTimer <= 0)
			{
				_doubleTapTimer = doubleTapThreshold;
				_lastTouchPos = FlxPoint.get(touch.x, touch.y);
			}
			else if (_doubleTapTimer > 0)
			{
				if (touch.justPressed && Math.abs(_lastTouchPos.x - touch.x) <= _doubleTapDistanceThreshold && Math.abs(_lastTouchPos.y - touch.y) <= _doubleTapDistanceThreshold)
				{
					_doubleTapTimer = 0;
					touch.justDoublePressed = true;
					touch.doublePressed = true;
				}
				else _lastTouchPos = FlxPoint.get(touch.x, touch.y);
			}

			i--;
		}
	}

	function onFocus():Void {}

	function onFocusLost():Void
	{
		reset();
	}
}
#end