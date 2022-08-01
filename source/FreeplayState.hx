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

class FreeplayState extends MusicBeatState
{
	var options:Array<String> = ['WEEK SONGS', 'BONUS SONGS', 'UNFAIR SONGS'];
	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private static var curSelected:Int = 0;
	public var menuBG:FlxSprite;
	public var storySpr:FlxSprite;
	public var bonusSpr:FlxSprite;
	public var unfairSpr:FlxSprite;
	public var categoryText:FlxText;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Browsing Freeplay Menu", null);
		#end

		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:AlphabetWhite = new AlphabetWhite(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			optionText.visible = false;

			grpOptions.add(optionText);
		}

		storySpr = new FlxSprite(0, 0);
		bonusSpr = new FlxSprite(0, 0);
		unfairSpr = new FlxSprite(0, 0);

		menuBG = new FlxSprite(0, 0); // fix for wrong positions!

		menuBG.loadGraphic(Paths.image('BLACK_AND_NOTHING_ELSE'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		add(menuBG);

		storySpr = new FlxSprite().loadGraphic(Paths.image('freeplay/MAIN_FP_STORY'));
		storySpr.antialiasing = ClientPrefs.globalAntialiasing;
	    storySpr.updateHitbox();
	    storySpr.screenCenter();
		add(storySpr);

		bonusSpr = new FlxSprite().loadGraphic(Paths.image('freeplay/MAIN_FP_BONUS'));
		bonusSpr.antialiasing = ClientPrefs.globalAntialiasing;
	    bonusSpr.updateHitbox();
	    bonusSpr.screenCenter();
		add(bonusSpr);

		unfairSpr = new FlxSprite().loadGraphic(Paths.image('freeplay/MAIN_FP_UNFAIR'));
		unfairSpr.antialiasing = ClientPrefs.globalAntialiasing;
	    unfairSpr.updateHitbox();
	    unfairSpr.screenCenter();
		add(unfairSpr);

		categoryText = new FlxText(500, 4, 0, "< DIPLES >", 50);
		categoryText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(categoryText);

		var Freeplay = new FlxSprite(0, 0);
		Freeplay.frames = Paths.getSparrowAtlas('freeplay/menu_freeplay');
		Freeplay.animation.addByPrefix('idle', 'freeplay basic', 24, true);
		Freeplay.antialiasing = ClientPrefs.globalAntialiasing;
		Freeplay.animation.play('idle', true);
		Freeplay.setGraphicSize(Std.int(Freeplay.width * 0.6));
		add(Freeplay);

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

		if (controls.UI_UP_P)
		{
			switch(options[curSelected])
			{
				case 'WEEK SONGS':
					categoryText.text = "< UNFAIR SONGS >";
					storySpr.alpha = 0.5;
					bonusSpr.alpha = 0.5;
					unfairSpr.alpha = 1;
					FlxTween.tween(unfairSpr, {'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});

				case 'BONUS SONGS':
					categoryText.text = "< STORY SONGS >";
					storySpr.alpha = 1;
					bonusSpr.alpha = 0.5;
					unfairSpr.alpha = 0.5;
					FlxTween.tween(storySpr, {'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});

				case 'UNFAIR SONGS':
					categoryText.text = "< BONUS SONGS >";
					storySpr.alpha = 0.5;
					bonusSpr.alpha = 1;
					unfairSpr.alpha = 0.5;
					FlxTween.tween(bonusSpr, {'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
			}
			changeSelection(-1);
		}

		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
			switch(options[curSelected])
			{
				case 'WEEK SONGS':
					categoryText.text = "< BONUS SONGS >";
					storySpr.alpha = 0.5;
					bonusSpr.alpha = 1;
					unfairSpr.alpha = 0.5;
					FlxTween.tween(bonusSpr, {'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});

				case 'BONUS SONGS':
					categoryText.text = "< UNFAIR SONGS >";
					storySpr.alpha = 0.5;
					bonusSpr.alpha = 0.5;
					unfairSpr.alpha = 1;
					FlxTween.tween(unfairSpr, {'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});

				case 'UNFAIR SONGS':
					categoryText.text = "< STORY SONGS >";
					storySpr.alpha = 1;
					bonusSpr.alpha = 0.5;
					unfairSpr.alpha = 0.5;
					FlxTween.tween(storySpr, {'scale.x': 1, 'scale.y': 1}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
					FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 1, {ease: FlxEase.expoInOut});
			}
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			for (item in grpOptions.members) {
				item.alpha = 0;
			}

			switch(options[curSelected])
			{
				case 'WEEK SONGS':
					MusicBeatState.switchState(new FreeplayWeekState());

				case 'BONUS SONGS':
					MusicBeatState.switchState(new FreeplayBonusState());
				
				case 'UNFAIR SONGS':
					MusicBeatState.switchState(new FreeplayUnfairState());
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

	public static function fadeMenuMusic() {
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxG.sound.music.fadeOut(1, 0);
		});
	}
}
