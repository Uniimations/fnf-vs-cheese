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
	FOR KEYBINDS MENU, JUST NABBED FROM ORIGINAL PSYCH LMFAO
**/
class KeybindsSubState extends MusicBeatSubstate
{
	private static var curSelected:Int = 1;
	private static var curAlt:Bool = false;

	private static var defaultKey:String = 'RESET ALL KEYBINDS';

	var optionShit:Array<String> = [
		'NOTE KEYBINDS',
		ClientPrefs.keyBinds[0][1],
		ClientPrefs.keyBinds[1][1],
		ClientPrefs.keyBinds[2][1],
		ClientPrefs.keyBinds[3][1],
		'',
		'HUD KEYBINDS',
		ClientPrefs.keyBinds[4][1],
		ClientPrefs.keyBinds[5][1],
		ClientPrefs.keyBinds[6][1],
		ClientPrefs.keyBinds[7][1],
		'',
		ClientPrefs.keyBinds[8][1],
		'',
		'',
		defaultKey
	];

	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private var grpInputs:Array<AttachedText> = [];
	private var controlArray:Array<FlxKey> = [];
	var rebindingKey:Int = -1;
	var nextAccept:Int = 5;

	public function new() {
		super();
		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		controlArray = ClientPrefs.lastControls.copy();
		for (i in 0...optionShit.length) {
			var isCentered:Bool = false;
			var isDefaultKey:Bool = (optionShit[i] == defaultKey);
			if(unselectableCheck(i, true)) {
				isCentered = true;
			}

			var optionText:AlphabetWhite = new AlphabetWhite(0, (10 * i), optionShit[i], (!isCentered || isDefaultKey), false);
			optionText.tweenType = "standard";
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
		if(rebindingKey < 0)
		{
			if (controls.UI_UP_P) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
			}
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				changeAlt();
			}

			if (controls.BACK)
			{
				OptionsState.canDoShit = true;
				ClientPrefs.reloadControls(controlArray);
				FlxG.sound.play(Paths.sound('cancelMenu'));

				new FlxTimer().start(0.05, function(tmr:FlxTimer) close());
			}

			if(controls.ACCEPT && nextAccept <= 0)
			{
				if(optionShit[curSelected] == defaultKey)
				{
					if (ClientPrefs.flashing) {
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
					}

					controlArray = ClientPrefs.defaultKeys.copy();
					reloadKeys();
					changeSelection();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
				else
				{
					bindingTime = 0;
					rebindingKey = getSelectedKey();

					if(rebindingKey > -1)
					{
						grpInputs[rebindingKey].visible = false;
						buttonSound();
					}
					else
					{
						FlxG.log.warn('Error! No input found/badly configured');
						FlxG.sound.play(Paths.sound('cancelMenu'));
					}
				}
			}
		}
		else
		{
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
		buttonSound(change != 0);
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

	private function addBindTexts(optionText:AlphabetWhite) {
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

	private function buttonSound(?playSound:Bool = true) {
		if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
