package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var hideTime:Bool = false;

	// EXTRA MOD SPECIFIC OPTIONS
	public static var shit:Bool = true;
	public static var bfreskin:Bool = true;
	public static var shitish:Bool = false;
	public static var missSounds:Bool = true;
	public static var bgDim:Float = 0;
	public static var fuckyouavi:Bool = false;
	public static var resetDeath:Bool = true;
	public static var comboShown:Bool = false;
	public static var inputSystem:String = "Kade Engine";

	public static var poggersMode:Bool = false;
	public static var pussyMode:Bool = false;

	public static var showWatermark:Bool = true;

	// EXTRA EFFECTS OPTIONS
	public static var specialEffects:Bool = true;
	public static var cameraShake:Bool = true;
	public static var camZoomOut:Bool = true;

	public static var autoP:Bool = false;

	public static var defaultKeys:Array<FlxKey> = [
		A, LEFT,			//Note Left
		S, DOWN,			//Note Down
		W, UP,				//Note Up
		D, RIGHT,			//Note Right

		A, LEFT,			//UI Left
		S, DOWN,			//UI Down
		W, UP,				//UI Up
		D, RIGHT,			//UI Right

		R, NONE,			//Reset
		SPACE, ENTER,		//Accept
		BACKSPACE, ESCAPE,	//Back
		ENTER, ESCAPE		//Pause
	];
	//Every key has two binds, these binds are defined on defaultKeys! If you want your control to be changeable, you have to add it on ControlsSubState (inside OptionsState)'s list
	public static var keyBinds:Array<Dynamic> = [
		//Key Bind, Name for ControlsSubState
		[Control.NOTE_LEFT, 'Left'],
		[Control.NOTE_DOWN, 'Down'],
		[Control.NOTE_UP, 'Up'],
		[Control.NOTE_RIGHT, 'Right'],

		[Control.UI_LEFT, 'Left '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_DOWN, 'Down '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_UP, 'Up '],			//Added a space for not conflicting on ControlsSubState
		[Control.UI_RIGHT, 'Right '],	//Added a space for not conflicting on ControlsSubState

		[Control.RESET, 'Reset'],
		[Control.ACCEPT, 'Accept'],
		[Control.BACK, 'Back'],
		[Control.PAUSE, 'Pause']
	];
	public static var lastControls:Array<FlxKey> = defaultKeys.copy();

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.cursing = cursing;
		FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.hideTime = hideTime;

		FlxG.save.data.shit = shit;
		FlxG.save.data.bfreskin = bfreskin;
		FlxG.save.data.shitish = shitish;
		FlxG.save.data.missSounds = missSounds;
		FlxG.save.data.bgDim = bgDim;
		FlxG.save.data.fuckyouavi = fuckyouavi;
		FlxG.save.data.resetDeath = resetDeath;
		FlxG.save.data.comboShown = comboShown;
		FlxG.save.data.inputSystem = inputSystem;

		FlxG.save.data.poggersMode = poggersMode;
		FlxG.save.data.pussyMode = pussyMode;

		FlxG.save.data.showWatermark = showWatermark;

		FlxG.save.data.specialEffects = specialEffects;
		FlxG.save.data.cameraShake = cameraShake;
		FlxG.save.data.camZoomOut = camZoomOut;

		FlxG.autoPause = autoP;
 
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'vscheese'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = lastControls;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.imagesPersist != null) {
			imagesPersist = FlxG.save.data.imagesPersist;
			FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.hideTime != null) {
			hideTime = FlxG.save.data.hideTime;
		}



		if(FlxG.save.data.shit != null) {
			shit = FlxG.save.data.shit;
		}
		if(FlxG.save.data.bfreskin != null) {
			bfreskin = FlxG.save.data.bfreskin;
		}
		if(FlxG.save.data.shitish != null) {
			shitish = FlxG.save.data.shitish;
		}
		if(FlxG.save.data.missSounds != null) {
			missSounds = FlxG.save.data.missSounds;
		}
		if(FlxG.save.data.bgDim != null) {
			bgDim = FlxG.save.data.bgDim;
		}
		if(FlxG.save.data.fuckyouavi != null) {
			fuckyouavi = FlxG.save.data.fuckyouavi;
		}
		if(FlxG.save.data.resetDeath != null) {
			resetDeath = FlxG.save.data.resetDeath;
		}
		if(FlxG.save.data.comboShown != null) {
			comboShown = FlxG.save.data.comboShown;
		}
		if(FlxG.save.data.inputSystem != null) {
			inputSystem = FlxG.save.data.inputSystem;
		}

		if(FlxG.save.data.poggersMode != null) {
			poggersMode = FlxG.save.data.poggersMode;
		}
		if(FlxG.save.data.pussyMode != null) {
			pussyMode = FlxG.save.data.pussyMode;
		}

		if(FlxG.save.data.showWatermark != null) {
			showWatermark = FlxG.save.data.showWatermark;
			if(Main.watermarkCheese != null) {
				Main.watermarkCheese.visible = showWatermark;
			}
		}



		if(FlxG.save.data.specialEffects != null) {
			specialEffects = FlxG.save.data.specialEffects;
		}
		if(FlxG.save.data.cameraShake != null) {
			cameraShake = FlxG.save.data.cameraShake;
		}
		if(FlxG.save.data.camZoomOut != null) {
			camZoomOut = FlxG.save.data.camZoomOut;
		}

		// flixel automatically saves your volume! (from psych 4.2)
		if(FlxG.save.data.volume != null) {
			FlxG.sound.volume = FlxG.save.data.volume;
		}

		autoP = FlxG.autoPause;

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'vscheese');
		if(save != null && save.data.customControls != null) {
			reloadControls(save.data.customControls);
		}
	}

	public static function reloadControls(newKeys:Array<FlxKey>) {
		ClientPrefs.removeControls(ClientPrefs.lastControls);
		ClientPrefs.lastControls = newKeys.copy();
		ClientPrefs.loadControls(ClientPrefs.lastControls);
	}

	private static function removeControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToRemove:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToRemove.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToRemove.length > 0) {
				PlayerSettings.player1.controls.unbindKeys(keyBinds[i][0], controlsToRemove);
			}
		}
	}
	private static function loadControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToAdd:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToAdd.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToAdd.length > 0) {
				PlayerSettings.player1.controls.bindKeys(keyBinds[i][0], controlsToAdd);
			}
		}
	}
}