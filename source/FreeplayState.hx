package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flash.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
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
	I CODED THIS REALLY WEIRD PLEASE DONT LOOK AT THI S
**/

class FreeplayState extends MusicBeatState
{
	var options:Array<String> = ['STORY SONGS', 'BONUS SONGS', 'UNFAIR SONGS'];
	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private var grpSelections:FlxTypedGroup<FlxSprite>;
	private static var curSelected:Int = 0;
	public var storySpr:FlxSprite;
	public var bonusSpr:FlxSprite;
	public var unfairSpr:FlxSprite;
	public var categoryText:FlxText;
	private var canMove:Bool = false;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Browsing Freeplay Menu", null);
		#end

		grpSelections = new FlxTypedGroup<FlxSprite>();
		add(grpSelections);

		storySpr = new FlxSprite(0, 0);
		bonusSpr = new FlxSprite(0, 0);
		unfairSpr = new FlxSprite(0, 0);

		storySpr = new FlxSprite().loadGraphic(Paths.image('freeplay/MAIN_FP_STORY'));
		storySpr.antialiasing = ClientPrefs.globalAntialiasing;
	    storySpr.updateHitbox();
	    storySpr.screenCenter();
		grpSelections.add(storySpr);

		bonusSpr = new FlxSprite().loadGraphic(Paths.image('freeplay/MAIN_FP_BONUS'));
		bonusSpr.antialiasing = ClientPrefs.globalAntialiasing;
	    bonusSpr.updateHitbox();
	    bonusSpr.screenCenter();
		grpSelections.add(bonusSpr);

		unfairSpr = new FlxSprite().loadGraphic(Paths.image('freeplay/MAIN_FP_UNFAIR'));
		unfairSpr.antialiasing = ClientPrefs.globalAntialiasing;
	    unfairSpr.updateHitbox();
	    unfairSpr.screenCenter();
		grpSelections.add(unfairSpr);

		categoryText = new FlxText(700, 30, 0, "< DIPLES >");
		categoryText.setFormat(Paths.font("vcr.ttf"), 60, FlxColor.WHITE, RIGHT);
		add(categoryText);

		var Freeplay = new FlxSprite(0, 0);
		Freeplay.frames = Paths.getSparrowAtlas('freeplay/menu_freeplay');
		Freeplay.animation.addByPrefix('idle', 'freeplay basic', 24, true);
		Freeplay.antialiasing = ClientPrefs.globalAntialiasing;
		Freeplay.animation.play('idle', true);
		Freeplay.setGraphicSize(Std.int(Freeplay.width * 0.6));
		add(Freeplay);

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

		changeSelection();

		switch(options[curSelected])
		{
			case 'STORY SONGS':
				categoryText.text = "< STORY SONGS >";
				storySpr.alpha = 1;
				bonusSpr.alpha = 0.5;
				unfairSpr.alpha = 0.5;
				FlxTween.tween(storySpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
				FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
				FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});

			case 'BONUS SONGS':
				categoryText.text = "< BONUS SONGS >";
				storySpr.alpha = 0.5;
				bonusSpr.alpha = 1;
				unfairSpr.alpha = 0.5;
				FlxTween.tween(bonusSpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
				FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
				FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});

			case 'UNFAIR SONGS':
				categoryText.text = "< UNFAIR SONGS >";
				storySpr.alpha = 0.5;
				bonusSpr.alpha = 0.5;
				unfairSpr.alpha = 1;
				FlxTween.tween(unfairSpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
				FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
				FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
		}
		canMove = true;

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (canMove)
		{
			if (controls.UI_LEFT_P)
			{
				switch(options[curSelected])
				{
					case 'STORY SONGS':
						categoryText.text = "< UNFAIR SONGS >";
						storySpr.alpha = 0.5;
						bonusSpr.alpha = 0.5;
						unfairSpr.alpha = 1;
						FlxTween.tween(unfairSpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});

					case 'BONUS SONGS':
						categoryText.text = "< STORY SONGS >";
						storySpr.alpha = 1;
						bonusSpr.alpha = 0.5;
						unfairSpr.alpha = 0.5;
						FlxTween.tween(storySpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});

					case 'UNFAIR SONGS':
						categoryText.text = "< BONUS SONGS >";
						storySpr.alpha = 0.5;
						bonusSpr.alpha = 1;
						unfairSpr.alpha = 0.5;
						FlxTween.tween(bonusSpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
				}
				changeSelection(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				switch(options[curSelected])
				{
					case 'STORY SONGS':
						categoryText.text = "< BONUS SONGS >";
						storySpr.alpha = 0.5;
						bonusSpr.alpha = 1;
						unfairSpr.alpha = 0.5;
						FlxTween.tween(bonusSpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});

					case 'BONUS SONGS':
						categoryText.text = "< UNFAIR SONGS >";
						storySpr.alpha = 0.5;
						bonusSpr.alpha = 0.5;
						unfairSpr.alpha = 1;
						FlxTween.tween(unfairSpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(storySpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});

					case 'UNFAIR SONGS':
						categoryText.text = "< STORY SONGS >";
						storySpr.alpha = 1;
						bonusSpr.alpha = 0.5;
						unfairSpr.alpha = 0.5;
						FlxTween.tween(storySpr, {'scale.x': 1, 'scale.y': 1}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(bonusSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
						FlxTween.tween(unfairSpr, {'scale.x': 0.9, 'scale.y': 0.9}, 0.2, {ease: FlxEase.cubeInOut});
				}
				changeSelection(1);
			}

			if (controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				canMove = false;

				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTween.tween(FlxG.camera, { zoom: 1.5}, 1.5, { ease: FlxEase.expoIn });

				FreeplaySelection.category = options[curSelected];
				trace('FREEPLAY SELECTION CATEGORY: ' + FreeplaySelection.category);

				grpSelections.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 1.5, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							MusicBeatState.switchState(new FreeplaySelection());
						}
					});
				});
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
		}

		if (change != 0) FlxG.sound.play(Paths.sound('clickMenu'));
	}

	public static function fadeMenuMusic() {
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxG.sound.music.fadeOut(1, 0);
		});
	}
}
