package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['KEYBINDS', 'SETTINGS'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBlackShit:FlxSprite;
	public static var menuBG:FlxSprite;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image('settingsmenu/menuOptions'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		menuBlackShit = new FlxSprite().loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));
		menuBlackShit.setGraphicSize(Std.int(menuBlackShit.width * 1.1));
	    menuBlackShit.updateHitbox();
	    menuBlackShit.screenCenter();
		menuBlackShit.alpha = ClientPrefs.bgDim;
		add(menuBlackShit);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;

			grpOptions.add(optionText);
		}

		changeSelection();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			for (item in grpOptions.members) {
				item.alpha = 0;
			}

			switch(options[curSelected]) {
				case 'KEYBINDS':
					openSubState(new ControlsSubstate());

				case 'SETTINGS':
					openSubState(new PreferencesSubstate());
			}
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.2;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}
	}
}

class ControlsSubstate extends MusicBeatSubstate {
	private static var curSelected:Int = 1;
	private static var curAlt:Bool = false;

	private static var defaultKey:String = 'Reset to Default Keys';

	var optionShit:Array<String> = [
		'NOTES',
		ClientPrefs.keyBinds[0][1],
		ClientPrefs.keyBinds[1][1],
		ClientPrefs.keyBinds[2][1],
		ClientPrefs.keyBinds[3][1],
		'',
		'UI',
		ClientPrefs.keyBinds[4][1],
		ClientPrefs.keyBinds[5][1],
		ClientPrefs.keyBinds[6][1],
		ClientPrefs.keyBinds[7][1],
		'',
		'MISCELLANEOUS',
		ClientPrefs.keyBinds[8][1],
		ClientPrefs.keyBinds[9][1],
		ClientPrefs.keyBinds[10][1],
		ClientPrefs.keyBinds[11][1],
		'',
		defaultKey];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpInputs:Array<AttachedText> = [];
	private var controlArray:Array<FlxKey> = [];
	var rebindingKey:Int = -1;
	var nextAccept:Int = 5;

	public function new() {
		super();
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		controlArray = ClientPrefs.lastControls.copy();
		for (i in 0...optionShit.length) {
			var isCentered:Bool = false;
			var isDefaultKey:Bool = (optionShit[i] == defaultKey);
			if(unselectableCheck(i, true)) {
				isCentered = true;
			}

			var optionText:Alphabet = new Alphabet(0, (10 * i), optionShit[i], (!isCentered || isDefaultKey), false);
			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
				optionText.yAdd = -55;
			} else {
				optionText.forceX = 200;
			}
			optionText.yMult = 60;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(!isCentered) {
				addBindTexts(optionText);
			}
		}
		changeSelection();
	}

	var leaving:Bool = false;
	var bindingTime:Float = 0;
	override function update(elapsed:Float) {
		if(rebindingKey < 0) {
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeAlt();
			}

			if (controls.BACK) {
				ClientPrefs.reloadControls(controlArray);
				grpOptions.forEachAlive(function(spr:Alphabet) {
					spr.alpha = 0;
				});
				for (i in 0...grpInputs.length) {
					var spr:AttachedText = grpInputs[i];
					if(spr != null) {
						spr.alpha = 0;
					}
				}
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}

			if(controls.ACCEPT && nextAccept <= 0) {
				if(optionShit[curSelected] == defaultKey) {
					controlArray = ClientPrefs.defaultKeys.copy();
					reloadKeys();
					changeSelection();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				} else {
					bindingTime = 0;
					rebindingKey = getSelectedKey();
					if(rebindingKey > -1) {
						grpInputs[rebindingKey].visible = false;
						buttonSound();
					} else {
						FlxG.log.warn('Error! No input found/badly configured');
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}
				}
			}
		} else {
			var keyPressed:Int = FlxG.keys.firstJustPressed();
			if (keyPressed > -1) {
				controlArray[rebindingKey] = keyPressed;
				var opposite:Int = rebindingKey + (rebindingKey % 2 == 1 ? -1 : 1);
				trace('Rebinded key with ID: ' + rebindingKey + ', Opposite is: ' + opposite);
				if(controlArray[opposite] == controlArray[rebindingKey]) {
					controlArray[opposite] = NONE;
				}

				reloadKeys();
				FlxG.sound.play(Paths.sound('confirmMenu'));
				rebindingKey = -1;
			}

			bindingTime += elapsed;
			if(bindingTime > 5) {
				grpInputs[rebindingKey].visible = true;
				buttonSound();
				rebindingKey = -1;
				bindingTime = 0;
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}
	
	function changeSelection(change:Int = 0) {
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = optionShit.length - 1;
			if (curSelected >= optionShit.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.4;
		}

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.4;
				if (item.targetY == 0) {
					item.alpha = 1;
					for (i in 0...grpInputs.length) {
						if(grpInputs[i].sprTracker == item && grpInputs[i].isAlt == curAlt) {
							grpInputs[i].alpha = 1;
						}
					}
				}
			}
		}
		buttonSound();
	}

	function changeAlt() {
		curAlt = !curAlt;
		for (i in 0...grpInputs.length) {
			if(grpInputs[i].sprTracker == grpOptions.members[curSelected]) {
				grpInputs[i].alpha = 0.4;
				if(grpInputs[i].isAlt == curAlt) {
					grpInputs[i].alpha = 1;
				}
			}
		}
		buttonSound();
	}

	private function unselectableCheck(num:Int, ?checkDefaultKey:Bool = false):Bool {
		if(optionShit[num] == defaultKey) {
			return checkDefaultKey;
		}

		for (i in 0...ClientPrefs.keyBinds.length) {
			if(ClientPrefs.keyBinds[i][1] == optionShit[num]) {
				return false;
			}
		}
		return true;
	}

	private function getSelectedKey():Int {
		var altValue:Int = (curAlt ? 1 : 0);
		for (i in 0...ClientPrefs.keyBinds.length) {
			if(ClientPrefs.keyBinds[i][1] == optionShit[curSelected]) {
				return i*2 + altValue;
			}
		}
		return -1;
	}

	private function addBindTexts(optionText:Alphabet) {
		var text1 = new AttachedText(InputFormatter.getKeyName(controlArray[grpInputs.length]), 400, -55);
		text1.setPosition(optionText.x + 400, optionText.y - 55);
		text1.sprTracker = optionText;
		grpInputs.push(text1);
		add(text1);

		var text2 = new AttachedText(InputFormatter.getKeyName(controlArray[grpInputs.length]), 650, -55);
		text2.setPosition(optionText.x + 650, optionText.y - 55);
		text2.sprTracker = optionText;
		text2.isAlt = true;
		grpInputs.push(text2);
		add(text2);
	}

	function reloadKeys() {
		while(grpInputs.length > 0) {
			var item:AttachedText = grpInputs[0];
			grpInputs.remove(item);
			remove(item);
		}

		for (i in 0...grpOptions.length) {
			if(!unselectableCheck(i, true)) {
				addBindTexts(grpOptions.members[i]);
			}
		}


		var bullShit:Int = 0;
		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.4;
		}

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.4;
				if (item.targetY == 0) {
					item.alpha = 1;
					for (i in 0...grpInputs.length) {
						if(grpInputs[i].sprTracker == item && grpInputs[i].isAlt == curAlt) {
							grpInputs[i].alpha = 1;
						}
					}
				}
			}
		}
	}

	private function buttonSound():Void {
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}



class PreferencesSubstate extends MusicBeatSubstate
{
	private static var curSelected:Int = 0;

	static var unselectableOptions:Array<String> = [
		'GRAPHICS',
		'GAMEPLAY',
		'APPEARANCE',
		'CAMERA EFFECTS',
		'MISCELLANEOUS'
	];
	static var noCheckbox:Array<String> = [
		'Framerate',
		'Note Delay',
		'Erase Save Data',
		'Background Dim',
		'Rating Pop Up Position'
	];

	static var options:Array<String> = [
		//GRAPHICS CATEGORY
		'GRAPHICS',
		'High Quality',
		'Flashing Lights',
		'Background Dim',
		#if !html5
		'Framerate', //Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		#end

		//GAMEPLAY CATEGORY
		'GAMEPLAY',
		'Downscroll',
		'Middlescroll',
		'Ghost Tapping',
		'Miss Sounds',
		'RESET to Game Over',
		'Rating Pop Up Position',
		'Note Delay',

		//APPEARANCE CATEGORY (please tell me i spelled that right please oh please)
		'APPEARANCE',
		#if !mobile
		'FPS Counter',
		#end
		'Note Splashes',
		'Hide HUD',
		'Hide Song Length',
		'Hide Rating Pop Up',
		'New Boyfriend Skin',

		//CAMERA EFFECTS CATEGORY FOR EVENT STUFF
		'CAMERA EFFECTS',
		'Special Effects',
		'Camera Movement',
		'Zoom In And Out',

		//MOD SPECIFIC CATEGORY WHERE WE GET FUNKY AND fun ni lol!!!
		//unii from 11/1/2021 here wtf were you on past unii
		'MISCELLANEOUS',
		'Constant Data Cached',
		'Optimized Mode',
		'Erase Save Data',
		//'Shitish Mode'
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var characterLayer:FlxTypedGroup<Character>;
	private var CharacterBoyfriend:Character;
	private var descText:FlxText;

	private var arrows:FlxSprite;
	private var boyfriendNormal:String;
	private var boyfriendRemaster:String;
	private var boyfriendX:Int;
	private var boyfriendY:Int;

	public function new()
	{
		super();
		characterLayer = new FlxTypedGroup<Character>();
		add(characterLayer);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		//BOYFRIEND INFORMATION BECAUSE I AM LAZY
		boyfriendNormal = 'bf-menu';
		boyfriendRemaster = 'bf-menu-remaster';
		boyfriendX = 900;
		boyfriendY = 302;

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, options[i], false, false);
			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.forceX = optionText.x;
			} else {
				optionText.x += 300;
				optionText.forceX = 300;
			}
			optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(!isCentered) {
				var useCheckbox:Bool = true;
				for (j in 0...noCheckbox.length) {
					if(options[i] == noCheckbox[j]) {
						useCheckbox = false;
						break;
					}
				}

				if(useCheckbox) {
					var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, false);
					checkbox.sprTracker = optionText;
					checkboxArray.push(checkbox);
					checkboxNumber.push(i);
					add(checkbox);
				} else {
					var valueText:AttachedText = new AttachedText('0', optionText.width + 80);
					valueText.sprTracker = optionText;
					grpTexts.add(valueText);
					textNumber.push(i);
				}
			}
		}

		if (ClientPrefs.downScroll) {
			newArrows('downscroll_notes');
		} else {
			newArrows('upscroll_notes');
		}

		if (ClientPrefs.fuckyouavi) {
			OptionsState.menuBG.alpha = 0.2;
		} else {
			if (ClientPrefs.bfreskin)
				newBoyfriend(boyfriendRemaster);
			else
				newBoyfriend(boyfriendNormal);
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		for (i in 0...options.length) {
			if(!unselectableCheck(i)) {
				curSelected = i;
				break;
			}
		}
		changeSelection();
		reloadValues();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK) {
			grpOptions.forEachAlive(function(spr:Alphabet) {
				spr.alpha = 0;
			});
			grpTexts.forEachAlive(function(spr:AttachedText) {
				spr.alpha = 0;
			});
			for (i in 0...checkboxArray.length) {
				var spr:CheckboxThingie = checkboxArray[i];
				if(spr != null) {
					spr.alpha = 0;
				}
			}
			descText.alpha = 0;
			close();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}


		var usesCheckbox = true;
		for (i in 0...noCheckbox.length) {
			if(options[curSelected] == noCheckbox[i]) {
				usesCheckbox = false;
				break;
			}
		}

		if(usesCheckbox) {
			if(controls.ACCEPT && nextAccept <= 0) {
				switch(options[curSelected]) {
					case 'FPS Counter':
						ClientPrefs.showFPS = !ClientPrefs.showFPS;
						if(Main.fpsVar != null)
							Main.fpsVar.visible = ClientPrefs.showFPS;

					case 'High Quality':
						ClientPrefs.globalAntialiasing = !ClientPrefs.globalAntialiasing;
						OptionsState.menuBG.antialiasing = ClientPrefs.globalAntialiasing;
						CharacterBoyfriend.antialiasing = ClientPrefs.globalAntialiasing;
						arrows.antialiasing = ClientPrefs.globalAntialiasing;
						for (item in grpOptions) {
							item.antialiasing = ClientPrefs.globalAntialiasing;
						}
						for (i in 0...checkboxArray.length) {
							var spr:CheckboxThingie = checkboxArray[i];
							if(spr != null) {
								spr.antialiasing = ClientPrefs.globalAntialiasing;
							}
						}

					case 'Note Splashes':
						ClientPrefs.noteSplashes = !ClientPrefs.noteSplashes;

					case 'Flashing Lights':
						ClientPrefs.flashing = !ClientPrefs.flashing;

					case 'Violence':
						ClientPrefs.violence = !ClientPrefs.violence;

					case 'Swearing':
						ClientPrefs.cursing = !ClientPrefs.cursing;

					case 'Downscroll':
						ClientPrefs.downScroll = !ClientPrefs.downScroll;
						if (ClientPrefs.downScroll) {
							newArrows('downscroll_notes');
						} else {
							newArrows('upscroll_notes');
						}

					case 'Middlescroll':
						ClientPrefs.middleScroll = !ClientPrefs.middleScroll;

					case 'Ghost Tapping':
						ClientPrefs.ghostTapping = !ClientPrefs.ghostTapping;

					case 'Hide HUD':
						ClientPrefs.hideHud = !ClientPrefs.hideHud;

					case 'Constant Data Cached':
						ClientPrefs.imagesPersist = !ClientPrefs.imagesPersist;
						FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;

					case 'Hide Song Length':
						ClientPrefs.hideTime = !ClientPrefs.hideTime;

					case 'New Boyfriend Skin':
						ClientPrefs.bfreskin = !ClientPrefs.bfreskin;
						if (!ClientPrefs.fuckyouavi) {
							if (!ClientPrefs.bfreskin) newBoyfriend(boyfriendNormal);
							else if (ClientPrefs.bfreskin) newBoyfriend(boyfriendRemaster);
						}

					/*case 'Shitish Mode':
						ClientPrefs.shitish = !ClientPrefs.shitish;*/

					case 'Miss Sounds':
						ClientPrefs.missSounds = !ClientPrefs.missSounds;

					case 'Optimized Mode':
					    ClientPrefs.fuckyouavi = !ClientPrefs.fuckyouavi;
						if (ClientPrefs.fuckyouavi)
						{
							if (CharacterBoyfriend != null)
							{
								killBoyfriend();
							}
							OptionsState.menuBG.alpha = 0.2;
							OptionsState.menuBlackShit.visible = false;
						}
						else
						{
							if (!ClientPrefs.bfreskin) newBoyfriend(boyfriendNormal);
							else if (ClientPrefs.bfreskin) newBoyfriend(boyfriendRemaster);
							OptionsState.menuBG.alpha = 1;
							OptionsState.menuBlackShit.visible = true;
						}

					case 'RESET to Game Over':
						ClientPrefs.resetDeath = !ClientPrefs.resetDeath;

					case 'Hide Rating Pop Up':
						ClientPrefs.comboShown = !ClientPrefs.comboShown;

					case 'Special Effects':
						ClientPrefs.specialEffects = !ClientPrefs.specialEffects;

					case 'Camera Movement':
						ClientPrefs.cameraShake = !ClientPrefs.cameraShake;

					case 'Zoom In And Out':
						ClientPrefs.camZoomOut = !ClientPrefs.camZoomOut;

				}
				buttonSound();
				reloadValues();
			}
			// wow this looks like shit! anyways...
		} else if (controls.ACCEPT) {
			switch (options[curSelected])
			{
				case 'Erase Save Data':
					ResetTools.resetData();
					FlxG.save.erase();
					System.exit(0);
				case 'Rating Pop Up Position':
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new RatingPopUpMenuState());
			}
		} else {
			if(controls.UI_LEFT || controls.UI_RIGHT) {
				var add:Int = controls.UI_LEFT ? -1 : 1;
				if (options[curSelected] != 'Background Dim' && holdTime > 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)

				switch(options[curSelected]) {
					case 'Framerate':
						ClientPrefs.framerate += add;
						if(ClientPrefs.framerate < 60) ClientPrefs.framerate = 60;
						else if(ClientPrefs.framerate > 240) ClientPrefs.framerate = 240;

						if(ClientPrefs.framerate > FlxG.drawFramerate) {
							FlxG.updateFramerate = ClientPrefs.framerate;
							FlxG.drawFramerate = ClientPrefs.framerate;
						} else {
							FlxG.drawFramerate = ClientPrefs.framerate;
							FlxG.updateFramerate = ClientPrefs.framerate;
						}
					case 'Note Delay':
						var mult:Int = 1;
						if(holdTime > 1.5) { //Double speed after 1.5 seconds holding
							mult = 2;
						}
						ClientPrefs.noteOffset += add * mult;
						if(ClientPrefs.noteOffset < 0) ClientPrefs.noteOffset = 0;
						else if(ClientPrefs.noteOffset > 500) ClientPrefs.noteOffset = 500;
					case 'Background Dim':
						ClientPrefs.bgDim += add * 0.1;
						OptionsState.menuBlackShit.alpha = ClientPrefs.bgDim;

						//Opacity set
						if(OptionsState.menuBlackShit.alpha > 0.9) OptionsState.menuBlackShit.alpha = 0.9;
						if(ClientPrefs.bgDim < 0.01) ClientPrefs.bgDim = 0;
						else if(ClientPrefs.bgDim > 0.9) ClientPrefs.bgDim = 0.9;
				}
				reloadValues();

				if (options[curSelected] != 'Background Dim' || options[curSelected] != 'Erase Save Data' || options[curSelected] != 'Rating Pop Up Position')
					if(holdTime <= 0) buttonSound();
				holdTime += elapsed;
			} else {
				holdTime = 0;
			}
		}

		if(!ClientPrefs.fuckyouavi && CharacterBoyfriend != null && CharacterBoyfriend.animation.curAnim.finished) {
			CharacterBoyfriend.dance();
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = options.length - 1;
			if (curSelected >= options.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var daText:String = '';

		//DESCRIPTIONS

		switch(options[curSelected]) {
			case 'Framerate':
				daText = "Frames per second of the game.\nAdjust with LEFT and RIGHT keys.";
			case 'Note Delay':
				daText = "Changes how late a note is spawned.\nUseful for preventing audio lag and input latency.\nAdjust with LEFT and RIGHT keys.";
			case 'FPS Counter':
				daText = "If unchecked, hides FPS Counter.";
			case 'Constant Data Cached':
				daText = "TURN THIS ON IF YOU HAVE ANY LOADING PROBLEMS!\nIf checked, images loaded will stay in memory\nuntil the game is closed, makes loading times faster.";
			case 'High Quality':
				daText = "If unchecked, disables anti-aliasing, increases performance\nat the cost of the graphics not looking as smooth.";
			case 'Downscroll':
				daText = "If checked, notes go downward instead of upward.";
			case 'Middlescroll':
				daText = "If checked, Your notes get centered similar to most 4k games.";
			case 'Ghost Tapping':
				daText = "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.";
			case 'Swearing':
				daText = "If unchecked, your mom won't be angry at you.";
			case 'Violence':
				daText = "If unchecked, you won't get disgusted as frequently.";
			case 'Note Splashes':
				daText = "If unchecked, hitting \"Perfect!\" won't\nshow particles.";
			case 'Flashing Lights':
				daText = "Uncheck this if you're sensitive to flashing lights.";
			case 'Hide HUD':
				daText = "If checked, hides your HUD.";
			case 'Hide Song Length':
				daText = "If checked, the bar showing how much time is left\nwill be hidden.";
			case 'New Boyfriend Skin':
				daText = "If unchecked, bf will have the normal skin\ninstead of the default \"remastered\" one.";
			/*case 'Shitish Mode':
				daText = '"it\'s not british, it\'s shitish, anyway-"\n
				If checked, the dialogue and story will be FUNNY!!!!\n
				(recommended to turn this on after completing normal story)';*/
			case 'Miss Sounds':
				daText = "If unchecked, miss sounds won't play\nand vocals won't be muted when you miss a note.";
			case 'Background Dim':
			    daText = "Dims the background down with a black tint.\nAdjust opacity with LEFT and RIGHT keys.";
			case 'Optimized Mode':
				daText = "If checked, hides ALL STAGE ELEMENTS.\nOnly notes and HUD will be visible.";
			case 'Erase Save Data':
				daText = "WARNING: THIS WILL CLOSE THE GAME!\nPress your ACCEPT key to clear your VS Cheese save data.";
			case 'Rating Pop Up Position':
				daText = "Press ACCEPT to move around your rating pop up.\nRating pop ups are the \"Sick\", \"Good\", etc...";
			case 'RESET to Game Over':
				daText = "Toggle pressing your RESET key to game over.";
			case 'Hide Rating Pop Up':
				daText = "If checked, the rating pop up showing your combo\nwill be hidden.";
			case 'Special Effects':
				daText = "If unchecked, color changing and mechanic indicator effects\nwill be turned off in songs with camera effects.";
			case 'Camera Movement':
				daText = "If unchecked, won't shake and won't move as much in\nsongs with camera effects.";
			case 'Zoom In And Out':
				daText = "If unchecked, camera will not change zoom amount in\nsongs with camera effects.";
		}
		descText.text = daText;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.2;
				if (item.targetY == 0) {
					item.alpha = 1;
				}

				for (j in 0...checkboxArray.length) {
					var tracker:FlxSprite = checkboxArray[j].sprTracker;
					if(tracker == item) {
						checkboxArray[j].alpha = item.alpha;
						break;
					}
				}
			}
		}
		for (i in 0...grpTexts.members.length) {
			var text:AttachedText = grpTexts.members[i];
			if(text != null) {
				text.alpha = 0.2;
				if(textNumber[i] == curSelected) {
					text.alpha = 1;
				}
			}
		}
		buttonSound();
	}

	function reloadValues() {
		for (i in 0...checkboxArray.length) {
			var checkbox:CheckboxThingie = checkboxArray[i];
			if(checkbox != null) {
				var daValue:Bool = false;
				switch(options[checkboxNumber[i]]) {
					case 'FPS Counter':
						daValue = ClientPrefs.showFPS;
					case 'High Quality':
						daValue = ClientPrefs.globalAntialiasing;
					case 'Note Splashes':
						daValue = ClientPrefs.noteSplashes;
					case 'Flashing Lights':
						daValue = ClientPrefs.flashing;
					case 'Downscroll':
						daValue = ClientPrefs.downScroll;
					case 'Middlescroll':
						daValue = ClientPrefs.middleScroll;
					case 'Ghost Tapping':
						daValue = ClientPrefs.ghostTapping;
					case 'Swearing':
						daValue = ClientPrefs.cursing;
					case 'Violence':
						daValue = ClientPrefs.violence;
					case 'Hide HUD':
						daValue = ClientPrefs.hideHud;
					case 'Constant Data Cached':
						daValue = ClientPrefs.imagesPersist;
					case 'Hide Song Length':
						daValue = ClientPrefs.hideTime;
					case 'New Boyfriend Skin':
						daValue = ClientPrefs.bfreskin;
					/*case 'Shitish Mode':
						daValue = ClientPrefs.shitish;*/
					case 'Miss Sounds':
						daValue = ClientPrefs.missSounds;
					case 'Optimized Mode':
						daValue = ClientPrefs.fuckyouavi;
					case 'RESET to Game Over':
						daValue = ClientPrefs.resetDeath;
					case 'Hide Rating Pop Up':
						daValue = ClientPrefs.comboShown;
					case 'Special Effects':
						daValue = ClientPrefs.specialEffects;
					case 'Camera Movement':
						daValue = ClientPrefs.cameraShake;
					case 'Zoom In And Out':
						daValue = ClientPrefs.camZoomOut;
				}
				checkbox.daValue = daValue;
			}
		}
		for (i in 0...grpTexts.members.length) {
			var text:AttachedText = grpTexts.members[i];
			if(text != null) {
				var daText:String = '';
				switch(options[textNumber[i]]) {
					case 'Framerate':
						daText = '' + ClientPrefs.framerate;
					case 'Note Delay':
						daText = ClientPrefs.noteOffset + 'ms';
					case 'Background Dim':
						daText = Math.round(ClientPrefs.bgDim * 100) + '%';
					case 'Erase Save Data':
						daText = '';
					case 'Rating Pop Up Position':
						daText = '';
				}
				var lastTracker:FlxSprite = text.sprTracker;
				text.sprTracker = null;
				text.changeText(daText);
				text.sprTracker = lastTracker;
			}
		}
	}

	private function unselectableCheck(num:Int):Bool {
		for (i in 0...unselectableOptions.length) {
			if(options[num] == unselectableOptions[i]) {
				return true;
			}
		}
		return options[num] == '';
	}

	private function newBoyfriend(character:String) {
		if (CharacterBoyfriend != null) {
			characterLayer.remove(CharacterBoyfriend);
		}
		CharacterBoyfriend = new Character(boyfriendX, boyfriendY, character, true);
		CharacterBoyfriend.setGraphicSize(Std.int(CharacterBoyfriend.width * 0.8));
		CharacterBoyfriend.updateHitbox();
		CharacterBoyfriend.dance();
		characterLayer.add(CharacterBoyfriend);
	}

	private function killBoyfriend():Void {
		if (CharacterBoyfriend != null)
			characterLayer.remove(CharacterBoyfriend);
	}

	private function newArrows(scrollPref:String) {
		if (arrows != null) {
			remove(arrows);
		}
		arrows = new FlxSprite().loadGraphic(Paths.image('settingsmenu/' + scrollPref));
		arrows.setGraphicSize(Std.int(arrows.width * 1.1));
		arrows.updateHitbox();
		arrows.screenCenter();
		arrows.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrows);
	}

	private function buttonSound():Void {
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}