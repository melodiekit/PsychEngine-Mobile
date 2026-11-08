package mobile.backend;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.input.FlxPointer;
import flixel.input.mouse.FlxMouse;
import mobile.input.touch.PsychTouch;
import mobile.input.touch.PsychTouchManager;

class TouchUtil
{
	public static var inputs:PsychTouchManager;
	public static var justPressed(get, never):Bool;
	public static var justDoublePressed(get, never):Bool;
	public static var pressed(get, never):Bool;
	public static var doublePressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var swiped(get, never):Bool;
	public static var input(get, never):#if mobile PsychTouch #else FlxMouse #end;

	public static function init() {
		inputs = FlxG.inputs.add(new PsychTouchManager());
		FlxG.signals.postUpdate.add(()->{
			inputs._doubleTapTimer -= FlxG.elapsed * 1000;
			if (inputs._doubleTapTimer < 0) inputs._doubleTapTimer = 0;
		});
	}

	public static function overlaps(object:FlxBasic, ?camera:FlxCamera, ?offset:FlxPoint, touchesToCheck:Array<PsychTouch> = null, touchesToExclude:Array<PsychTouch> = null, checkIfExistsAndVisible:Bool = true):Bool {
		if (offset != null) {
			@:privateAccess {
			var result:Bool = false;
			var group = FlxTypedGroup.resolveGroup(object);
			if (group != null) {
				group.forEachExists(function(basic:FlxBasic) {
					if (TouchUtil.overlaps(basic, camera ?? basic.camera, offset)) {
						result = true;
						return;
					}
				});
			}
			else {
				#if mobile
				for (touch in TouchUtil.inputs.list) {
					if (touchesToExclude != null && touchesToExclude.contains(touch)) continue;
					if (touchesToCheck != null && !touchesToCheck.contains(touch)) continue;
					if (checkIfExistsAndVisible && (!object.exists || !object.visible)) continue;
					touch.getWorldPosition(camera ?? object.camera, FlxPointer._cachedPoint);
					var object:FlxObject = cast object;
					if (TouchUtil.overlapsPoint(object, FlxPointer._cachedPoint, offset, true, camera ?? object.camera)) {
						result = true;
					}
				}
				#else
				if (checkIfExistsAndVisible && (!object.exists || !object.visible)) return false;
				FlxG.mouse.getWorldPosition(camera ?? object.camera, FlxPointer._cachedPoint);
				var object:FlxObject = cast object;
				return TouchUtil.overlapsPoint(object, FlxPointer._cachedPoint, offset, true, camera ?? object.camera);
				#end
			}
			return result;
			}
		}
		else {
			#if mobile
			for (touch in TouchUtil.inputs.list) {
				if (touchesToExclude != null && touchesToExclude.contains(touch)) continue;
				if (touchesToCheck != null && !touchesToCheck.contains(touch)) continue;
				if (checkIfExistsAndVisible && (!object.exists || !object.visible)) continue;
				if (touch.overlaps(object, camera ?? object.camera)) {
					return true;
				}
			}
			#else
			if (checkIfExistsAndVisible && (!object.exists || !object.visible)) return false;
			return FlxG.mouse.overlaps(object, camera ?? object.camera);
			#end
		}

		return false;
	}

	public static function overlapsArray(objects:Array<FlxBasic>, ?camera:FlxCamera, ?offset:FlxPoint, touchesToCheck:Array<PsychTouch> = null, touchesToExclude:Array<PsychTouch> = null):Bool {
		for (obj in objects) {
			if (TouchUtil.overlaps(obj, camera, offset, touchesToCheck, touchesToExclude)) return true;
		}
		return false;
	}

	public static function overlapsPoint(object:FlxObject, point:FlxPoint, ?offset:FlxPoint, inScreenSpace = false, ?camera:FlxCamera, checkIfExistsAndVisible:Bool = true):Bool {
		if (checkIfExistsAndVisible && (!object.exists || !object.visible)) return false;
		if (offset == null) {
			offset = FlxPoint.get(0, 0);
		}
		if (!inScreenSpace) {
			var overlapping:Bool = (point.x >= object.x + offset.x) && (point.x < object.x + object.width + offset.x) && (point.y >= object.y + offset.y) && (point.y < object.y + object.height + offset.y);
			offset.put();
			return overlapping;
		}

		if (camera == null) {
			camera = FlxG.camera;
		}
		@:privateAccess {
		var xPos:Float = point.x - camera.scroll.x;
		var yPos:Float = point.y - camera.scroll.y;
		object.getScreenPosition(object._point, camera);
		point.putWeak();
		var overlapping:Bool = (xPos >= object._point.x + offset.x) && (xPos < object._point.x + object.width + offset.x) && (yPos >= object._point.y + offset.y) && (yPos < object._point.y + object.height + offset.y);
		offset.put();
		return overlapping;
		}
	}

	public static function overlapsCamera(objects:Array<FlxBasic>, camera:FlxCamera, ?offset:FlxPoint, touchesToCheck:Array<PsychTouch> = null, touchesToExclude:Array<PsychTouch> = null):Bool {
		for (obj in objects) {
			if (obj.camera == camera && TouchUtil.overlaps(obj, camera, offset, touchesToCheck, touchesToExclude)) return true;
		}
		return false;
	}

	public static function overlapsChosenCameras(objects:Array<FlxBasic>, cameras:Array<FlxCamera> = null, ?offset:FlxPoint, touchesToCheck:Array<PsychTouch> = null, touchesToExclude:Array<PsychTouch> = null):Bool {
		if (cameras == null) cameras = [];
		var overlapping:Bool = false;
		var overlappingWrongCamera:Bool = false;
		for (cam in FlxG.cameras.list) {
			if (TouchUtil.overlapsCamera(objects, cam, offset, touchesToCheck, touchesToExclude)) {
				if (cameras.contains(cam)) overlapping = true;
				else overlappingWrongCamera = true;
			}
		}
		return (overlapping && !overlappingWrongCamera);
	}

	public static function initiallyOverlapped(objects:Array<FlxBasic>, ?camera:FlxCamera, ?offset:FlxPoint, touchesToCheck:Array<PsychTouch> = null, touchesToExclude:Array<PsychTouch> = null):Bool {
		if (TouchUtil.input == null && (touchesToCheck == null || touchesToCheck.length < 1)) return false;
		for (obj in objects) {
			@:privateAccess
			var group = FlxTypedGroup.resolveGroup(obj);
			if (group != null) {
				for (mem in group) {
					if (TouchUtil.initiallyOverlapped([cast mem], camera, offset, touchesToCheck)) return true;
				}
				continue;
			}
			if (touchesToCheck != null && touchesToCheck.length > 0) {
				for (touch in touchesToCheck) {
					if (TouchUtil.overlapsPoint(cast obj, TouchUtil.getJustPressedPosition(camera, touch), offset, true, camera ?? obj.camera)) return true;
				}
			}
			else if (TouchUtil.overlapsPoint(cast obj, TouchUtil.getJustPressedPosition(camera), offset, true, camera ?? obj.camera)) return true;
		}
		return false;
	}

	public static function getJustPressedPosition(?camera:FlxCamera, touchToCheck:PsychTouch = null):FlxPoint {
		if (TouchUtil.input == null && touchToCheck == null) return null;
		var input:PsychTouch = touchToCheck ?? TouchUtil.input;
		@:privateAccess
		var justPressedPosition:FlxPoint = #if mobile input.justPressedPosition #else TouchUtil.input._leftButton.justPressedPosition #end;
		if (input.justPressed) {
			justPressedPosition.copyFrom(input.getScreenPosition(camera));
		}
		return justPressedPosition;
	}

	static function get_justPressed():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.justPressed) {
				return true;
			}
		}
		#else
		return FlxG.mouse.justPressed;
		#end

		return false;
	}

	static function get_justDoublePressed():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.justDoublePressed) {
				return true;
			}
		}
		#end

		return false;
	}

	static function get_pressed():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.pressed) {
				return true;
			}
		}
		#else
		return FlxG.mouse.pressed;
		#end

		return false;
	}

	static function get_doublePressed():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.doublePressed) {
				return true;
			}
		}
		#end

		return false;
	}

	static function get_justReleased():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.justReleased) {
				return true;
			}
		}
		#else
		return FlxG.mouse.justReleased;
		#end

		return false;
	}

	static function get_released():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.released) {
				return true;
			}
		}
		#else
		return FlxG.mouse.released;
		#end

		return false;
	}

	static function get_swiped():Bool {
		#if mobile
		for (touch in TouchUtil.inputs.list) {
			if (touch.swiped) {
				return true;
			}
		}
		#end

		return false;
	}

	static function get_input():#if mobile PsychTouch #else FlxMouse #end {
		return #if mobile TouchUtil.inputs.getFirst() #else FlxG.mouse #end;
	}
}