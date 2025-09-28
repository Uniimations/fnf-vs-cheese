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

/**
	MENU FOR MOST CONTROLS INCLUDING THEIR CATEGORIES
**/

class SettingsSubState extends MusicBeatSubstate
{
	public static var category:String = '';

	static var unselectableOptions:Array<String> = ['oops'];

	static var noCheckbox:Array<String> = [
		'Input System:',
		'Erase Save Data',
		'Background Dim',
		'Safe Frames',
		'FPS Cap',
		'Note Offset'
	];

	private static var curSelected:Int = 0;

	private var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private var checkboxArray:Array<CheckboxThingie> = [];
	private var checkboxNumber:Array<Int> = [];
	private var grpTexts:FlxTypedGroup<AttachedText>;
	private var textNumber:Array<Int> = [];

	private var characterLayer:FlxTypedGroup<Character>;
	private var CharacterBoyfriend:Character;
	private var descText:FlxText;
	private var pauseText:FlxText;

	private var arrows:FlxSprite;
	private var boyfriendNormal:String;
	private var boyfriendRemaster:String;
	private var boyfriendX:Int;
	private var boyfriendY:Int;

	public function new()
	{
		// FINISH TOMORROW
		switch (category)
		{
			case 'GAMEPLAY':
				options = [
					'Downscroll',
					'Middlescroll',
					'Ghost Tapping',
					#if PLAYTEST_BUILD
					'Botplay',
					#end
					'RESET to Game Over',
					'Miss Sounds',
					'Note Offset',
					'Safe Frames'
				];
			case 'APPEARANCE':
				options = [
					'New Boyfriend Skin',
					'Note Splashes',
					'Hide Combo Rating',
					'Hide HUD',
					'Background Dim'
				];
			case 'PERFORMANCE':
				options = [
					'Flashing Lights',
					'Special Effects',
					'Camera Shake',
					'Camera Zoom',
					'High Quality'
				];
			case 'WINDOW':
				options = [
					'Window Pause',
					'Auto Pause',
					#if !mobile
					'FPS Counter',
					#end

					#if !html5
					'FPS Cap' //Apparently 120FPS isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
					#end
				];
			case 'ACCESSIBILITY':
				options = [
					'Pussy Mode',
					'Optimized Mode',
					'Input System:',
					'Erase Save Data'
				];
			default:
				options = ['Error'];
		}

		super();

		characterLayer = new FlxTypedGroup<Character>();
		add(characterLayer);

		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		//BOYFRIEND INFORMATION BECAUSE I AM LAZY
		boyfriendNormal = 'bf-menu';
		boyfriendRemaster = 'bf-menu-remaster';
		boyfriendX = 800;
		boyfriendY = 350;

		for (i in 0...options.length)
		{
			var isCentered:Bool = unselectableCheck(i);
			var optionText:AlphabetWhite = new AlphabetWhite(0, 70 * i, options[i], false, false);
			optionText.tweenType = "standard";

			if(isCentered) {
				optionText.screenCenter(X);
				optionText.xAdd = optionText.x;
			} else {
				optionText.x += 60;
				optionText.xAdd = 60;
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
			//do nothing
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

		pauseText = new FlxText(50, 120, 1180, "", 32);
		pauseText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pauseText.scrollFactor.set();
		pauseText.borderSize = 2.4;
		pauseText.alpha = 0;
		add(pauseText);

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
		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			OptionsState.canDoShit = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));

			new FlxTimer().start(0.05, function(tmr:FlxTimer) close()); // add delay
		}


		var usesCheckbox = true;
		for (i in 0...noCheckbox.length) {
			if(options[curSelected] == noCheckbox[i]) {
				usesCheckbox = false;
				break;
			}
		}

		if(usesCheckbox)
		{
			if(controls.ACCEPT && nextAccept <= 0)
			{
				switch(options[curSelected]) {
					case 'FPS Counter':
						ClientPrefs.showFPS = !ClientPrefs.showFPS;
						if (Main.fpsVar != null)
							Main.fpsVar.visible = ClientPrefs.showFPS;

					case 'Watermark Icon':
						ClientPrefs.showWatermark = !ClientPrefs.showWatermark;
						if (Main.watermarkCheese != null)
							Main.watermarkCheese.visible = ClientPrefs.showWatermark;

					case 'High Quality':
						ClientPrefs.globalAntialiasing = !ClientPrefs.globalAntialiasing;
						OptionsState.menuBG.antialiasing = ClientPrefs.globalAntialiasing;
						arrows.antialiasing = ClientPrefs.globalAntialiasing;

						if (CharacterBoyfriend != null) {
							CharacterBoyfriend.antialiasing = ClientPrefs.globalAntialiasing;
						}

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

					case 'New Boyfriend Skin':
						if (!OptionsState.inPause)
						{
							ClientPrefs.bfreskin = !ClientPrefs.bfreskin;
							if (!ClientPrefs.fuckyouavi) {
								if (!ClientPrefs.bfreskin) newBoyfriend(boyfriendNormal);
								else if (ClientPrefs.bfreskin) newBoyfriend(boyfriendRemaster);
							}
						}
						else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
						}

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
							//OptionsState.menuBG.alpha = 0.2;
							OptionsState.menuBG.loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));
							OptionsState.menuBlackShit.visible = false;
						}
						else
						{
							if (!ClientPrefs.bfreskin) newBoyfriend(boyfriendNormal);
							else if (ClientPrefs.bfreskin) newBoyfriend(boyfriendRemaster);
							//OptionsState.menuBG.alpha = 1;
							OptionsState.menuBG.loadGraphic(Paths.image('settingsmenu/menuOptions'));
							OptionsState.menuBlackShit.visible = true;
						}

					case 'RESET to Game Over':
						ClientPrefs.resetDeath = !ClientPrefs.resetDeath;

					case 'Hide Combo Rating':
						ClientPrefs.comboShown = !ClientPrefs.comboShown;

					case 'Special Effects':
						ClientPrefs.specialEffects = !ClientPrefs.specialEffects;

					case 'Camera Shake':
						ClientPrefs.cameraShake = !ClientPrefs.cameraShake;

					case 'Camera Zoom':
						ClientPrefs.camZoomOut = !ClientPrefs.camZoomOut;

					case 'Window Pause':
						ClientPrefs.windowPause = !ClientPrefs.windowPause;

					case 'Auto Pause':
						ClientPrefs.gamePause = !ClientPrefs.gamePause;

					case 'Botplay':
						ClientPrefs.botplay = !ClientPrefs.botplay;

					case 'Pussy Mode':
						ClientPrefs.pussyMode = !ClientPrefs.pussyMode;
				}
				reloadValues();
				ClientPrefs.saveSettings(); //saves whenever you change an option (because like why didnt it do that before ???)

				FlxG.sound.play(Paths.sound('clickMenu'));
			}
		}
		else if (controls.ACCEPT)
		{
			if (options[curSelected] == 'Erase Save Data') {
				openSubState(new ResetPromptSubState());
				FlxG.sound.play(Paths.sound('clickMenu'));
			}
		}
		else
		{
			if(controls.UI_LEFT || controls.UI_RIGHT)
			{
				var add:Int = controls.UI_LEFT ? -1 : 1;
				var changeString:String = "changeString";

				switch (ClientPrefs.inputSystem)
				{
					case "Kade Engine":
						changeString = "Kade Engine";
					case "Psych Engine":
						changeString = "Psych Engine";
					case "Vanilla":
						changeString = "Vanilla";
				}

				if (holdTime > 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)
				{
					switch(options[curSelected])
					{
						case 'FPS Cap':
							{
								ClientPrefs.framerate += add;
								if(ClientPrefs.framerate < 60) ClientPrefs.framerate = 60;
								else if(ClientPrefs.framerate > 360) ClientPrefs.framerate = 360;

								//changed the cap back because i hate optimizing it for higher framerate lol, better than 60 fps tho ??? so whatever ratio
								// shut the fuck up past unii fuck you fuck YOU!! ! !!!

								FlxG.log.add('changed fps');

								if(ClientPrefs.framerate > FlxG.drawFramerate) {
									FlxG.updateFramerate = ClientPrefs.framerate;
									FlxG.drawFramerate = ClientPrefs.framerate;
								} else {
									FlxG.drawFramerate = ClientPrefs.framerate;
									FlxG.updateFramerate = ClientPrefs.framerate;
								}
							}
						case 'Note Offset':
							{
								var mult:Int = 1;
								if(holdTime > 1.5) { //Double speed after 1.5 seconds holding
									mult = 2;
								}
								ClientPrefs.noteOffset += add * mult;
								if(ClientPrefs.noteOffset < 0) ClientPrefs.noteOffset = 0;
								else if(ClientPrefs.noteOffset > 500) ClientPrefs.noteOffset = 500;
							}
						case 'Background Dim':
							{
								ClientPrefs.bgDim += add * 0.1;
								OptionsState.menuBlackShit.alpha = ClientPrefs.bgDim;
								FlxG.log.add('changed bg dim opacity');

								//Opacity set
								if(OptionsState.menuBlackShit.alpha > 0.9)
									OptionsState.menuBlackShit.alpha = 0.9;

								if (ClientPrefs.bgDim < 0.01)
									ClientPrefs.bgDim = 0;
								else if(ClientPrefs.bgDim > 0.9)
									ClientPrefs.bgDim = 0.9;
							}
						case 'Safe Frames':
							{
								ClientPrefs.safeFrames += add;
								if(ClientPrefs.safeFrames < 1) ClientPrefs.safeFrames = 1;
								else if(ClientPrefs.safeFrames > 20) ClientPrefs.safeFrames = 20;
							}
						case 'Input System:':
							{
								// I SHOULDVE DONE THIS IN AN ARRAY FUUUCK
								switch (changeString)
								{
									case "Kade Engine":
										if (controls.UI_LEFT)
											changeString = "Vanilla";
										else if (controls.UI_RIGHT)
											changeString = "Psych Engine";
									case "Psych Engine":
										if (controls.UI_LEFT)
											changeString = "Kade Engine";
										else if (controls.UI_RIGHT)
											changeString = "Vanilla";
									case "Vanilla":
										if (controls.UI_LEFT)
											changeString = "Psych Engine";
										else if (controls.UI_RIGHT)
											changeString = "Kade Engine";
								}
								ClientPrefs.inputSystem = changeString;

								// short timer just in case it displays the wrong string (it does)
								new FlxTimer().start(0.02, function(tmr:FlxTimer) {
									ClientPrefs.inputSystem = changeString;
									FlxG.log.add('timer completed, changed string to: ' + ClientPrefs.inputSystem);
									//trace('working: ' + ClientPrefs.inputSystem);
								});
							}
					}
					reloadValues();
					ClientPrefs.saveSettings();
				}

				// BETTER THAN THE IF STATEMENT (slightly)
				var soundShouldPlay:Bool = true;

				if (options[curSelected] == 'Erase Save Data') soundShouldPlay = false;

				if (holdTime <= 0 && soundShouldPlay) FlxG.sound.play(Paths.sound('clickMenu'));
				holdTime += elapsed;
			}
			else
			{
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
			case 'FPS Cap':
				daText = "Frames per second of the game.\nAdjust with LEFT and RIGHT keys.";
			case 'Note Offset':
				daText = "Adjust your offset.\nUseful for preventing audio lag from wireless earphones.";
			case 'FPS Counter':
				daText = "If unchecked, hides FPS Counter.";
			case 'Watermark Icon':
				daText = "If unchecked, hides the VS Cheese watermark.";
			case 'High Quality':
				daText = "If unchecked, disables anti-aliasing, increases performance\nat the cost of the graphics not looking as smooth.";
			case 'Downscroll':
				daText = "If checked, notes go downward instead of upward\nuse this if you're a REAL rhythm gamer. B)"; // i added it back idk why it was removed B)
			case 'Middlescroll':
				daText = "If checked, your notes get centered\nsimilar to most 4k games.";
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
			case 'New Boyfriend Skin':
				daText = "If unchecked, bf will have the normal skin\ninstead of the default \"remastered\" one.";
			case 'Miss Sounds':
				daText = "If unchecked, miss sounds won't play and vocals\nwon't be muted when you miss a note.";
			case 'Background Dim':
			    daText = "Dims the background down with a black tint.\nAdjust opacity with LEFT and RIGHT keys.";
			case 'Optimized Mode':
				daText = "If checked, hides ALL backgrounds and characters.\nAlso disables distractions.";
			case 'Erase Save Data':
				daText = "WARNING: THIS WILL CLOSE THE GAME!\nPress your ACCEPT key to clear your VS Cheese save data.";
			case 'RESET to Game Over':
				daText = "Toggle pressing your RESET key to game over.";
			case 'Hide Combo Rating':
				daText = "If checked, the rating pop up showing your combo\nwill be hidden.";
			case 'Special Effects':
				daText = "If unchecked, mechanic indicators and visual effects\nwill be turned off.";
			case 'Camera Shake':
				daText = "If unchecked, camera will not shake or move to the notes\npressed in songs with camera effects.";
			case 'Camera Zoom':
				daText = "If unchecked, camera will not zoom in and out in\nsongs with camera effects.";
			case 'Input System:':
				daText = "Choose input systems from other Friday Night Funkin' Engines.\nAdjust with LEFT and RIGHT keys.";
			case 'Window Pause':
				daText = "If checked, freezes the game when clicking off of the window.";
			case 'Auto Pause':
				daText = "If unchecked, doesn't pause the game when\nclicking off the window during a song.";
			case 'Botplay':
				daText = "BE A NERDDDD LOLL, this is only in playtest buuilds of the game hi diples hi diples hi di";
			case 'Safe Frames':
				daText = "Customize how many frames you have for\nhitting a note earlier or late.";
			case 'Pussy Mode':
				daText = "Turns off mechanics in UNFAIR songs.";
		}
		descText.text = daText;

		// switch in case i wanna add more options that are untogglable when using the pause menu options (it is the same state/substates)
		switch (options[curSelected])
		{
			case 'New Boyfriend Skin':
				if (OptionsState.inPause)
					pauseText.alpha = 1;
				else
					pauseText.alpha = 0;
			default:
				pauseText.alpha = 0;
		}
		pauseText.text = "This option cannot be toggled in the pause menu.\nPlease visit options on the main menu to toggle.";

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
		buttonSound(change != 0);
	}

	function reloadValues() {
		for (i in 0...checkboxArray.length) {
			var checkbox:CheckboxThingie = checkboxArray[i];
			if(checkbox != null) {
				var daValue:Bool = false;
				switch(options[checkboxNumber[i]]) {
					case 'FPS Counter':
						daValue = ClientPrefs.showFPS;
					case 'Watermark Icon':
						daValue = ClientPrefs.showWatermark;
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
					case 'New Boyfriend Skin':
						daValue = ClientPrefs.bfreskin;
					case 'Miss Sounds':
						daValue = ClientPrefs.missSounds;
					case 'Optimized Mode':
						daValue = ClientPrefs.fuckyouavi;
					case 'RESET to Game Over':
						daValue = ClientPrefs.resetDeath;
					case 'Hide Combo Rating':
						daValue = ClientPrefs.comboShown;
					case 'Special Effects':
						daValue = ClientPrefs.specialEffects;
					case 'Camera Shake':
						daValue = ClientPrefs.cameraShake;
					case 'Camera Zoom':
						daValue = ClientPrefs.camZoomOut;
					case 'Window Pause':
						daValue = ClientPrefs.windowPause;
					case 'Auto Pause':
						daValue = ClientPrefs.gamePause;
					case 'Botplay':
						daValue = ClientPrefs.botplay;
					case 'Pussy Mode':
						daValue = ClientPrefs.pussyMode;
				}
				checkbox.daValue = daValue;
			}
		}
		for (i in 0...grpTexts.members.length) {
			var text:AttachedText = grpTexts.members[i];
			if(text != null) {
				var daText:String = '';
				switch(options[textNumber[i]]) {
					case 'FPS Cap':
						daText = '' + ClientPrefs.framerate;
					case 'Note Offset':
						daText = ClientPrefs.noteOffset + 'ms';
					case 'Background Dim':
						daText = Math.round(ClientPrefs.bgDim * 100) + '%';
					case 'Safe Frames':
						daText = '' + ClientPrefs.safeFrames;
					case 'Input System:':
						daText = ClientPrefs.inputSystem;
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
		CharacterBoyfriend.setGraphicSize(Std.int(CharacterBoyfriend.width * 0.65));
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
		arrows.screenCenter();
		arrows.antialiasing = ClientPrefs.globalAntialiasing;
		add(arrows);
	}

	private function buttonSound(?playSound:Bool = true) {
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function traceLog(log:String) {
		FlxG.log.add(log);
	}
}