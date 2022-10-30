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
	MENU FOR OPTION SELECTION
**/

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['KEYBINDS', 'OFFSETS & PREVIEW', 'GAMEPLAY', 'APPEARANCE', 'PERFORMANCE', 'WINDOW', 'ACCESSIBILITY'];
	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private static var curSelected:Int = 0;
	public static var menuBlackShit:FlxSprite;
	public static var menuBG:FlxSprite;
	public static var inPause:Bool = false;
	public static var canDoShit:Bool = true;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		menuBG = new FlxSprite(0, 0); // fix for wrong positions!

		if (!ClientPrefs.fuckyouavi)
			menuBG.loadGraphic(Paths.image('settingsmenu/menuOptions'));
		else
			menuBG.loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));

		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		menuBG.alpha = 0.85;
		add(menuBG);

		menuBlackShit = new FlxSprite().loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));
		menuBlackShit.setGraphicSize(Std.int(menuBlackShit.width * 1.1));
	    menuBlackShit.updateHitbox();
	    menuBlackShit.screenCenter();
		menuBlackShit.alpha = ClientPrefs.bgDim;
		add(menuBlackShit);

		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:AlphabetWhite = new AlphabetWhite(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;

			grpOptions.add(optionText);
		}

		changeSelection();

		super.create();

		canDoShit = true;
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (canDoShit)
		{
			if (controls.UI_UP_P) {
				changeSelection(-1);
				FlxG.sound.play(Paths.sound('clickMenu'));
			}
			if (controls.UI_DOWN_P) {
				changeSelection(1);
				FlxG.sound.play(Paths.sound('clickMenu'));
			}

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));

				if (!inPause) {
					MusicBeatState.switchState(new MainMenuState());
				} else {
					MusicBeatState.switchState(new PlayState());
					FlxG.sound.music.volume = 0;
					inPause = false;
				}
			}

			if (controls.ACCEPT)
			{
				var selected = options[curSelected];

				SettingsSubState.category = selected; // select category
				canDoShit = false; // prevent player input

				new FlxTimer().start(0.05, function(tmr:FlxTimer)
				{
					if (selected != 'OFFSETS & PREVIEW') {
						for (item in grpOptions.members) {
							item.alpha = 0;
						}
					}

					switch(selected)
					{
						case 'KEYBINDS':
							openSubState(new KeybindsSubState());

						case 'OFFSETS & PREVIEW':
							MusicBeatState.switchState(new OffsetState());

						case 'GAMEPLAY' | 'APPEARANCE' | 'PERFORMANCE' | 'WINDOW' | 'ACCESSIBILITY':
							openSubState(new SettingsSubState());
					}
					trace('picked category: ' + SettingsSubState.category);
				});
				FlxG.sound.play(Paths.sound('clickMenu'));
			}
		}
	}

	function changeSelection(change:Int = 0)
	{
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
