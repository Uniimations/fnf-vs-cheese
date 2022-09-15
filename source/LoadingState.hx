package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import sys.thread.Thread;

using StringTools;

class LoadingState extends MusicBeatState
{
	public static var target:FlxState;
	public static var stopMusic:Bool = false;

	static var soundsToCache:Array<String> = [];
	static var imagesToCache:Array<String> = [];
	static var spritesToCache:Array<String> = [];

	static var soundLibrary:String = '';
	static var imageLibrary:String = '';
	static var spriteLibrary:String = '';

	var screen:LoadingScreen;

	override function create()
	{
		super.create();

		var daSong:String = PlayState.SONG.song.toLowerCase();

		soundLibrary = 'shared';
		imageLibrary = 'shared';
		spriteLibrary = 'preload';

		switch (daSong)
		{
			case 'tutorial':
				if (PlayState.isStoryMode)
				{
					soundsToCache = ['dialogue/bluecheeseText', 'dialogue/suzukiText', 'dialogue/clickText'];
				}

				imagesToCache = [
					'cheese/kitchen/background_main',
					'cheese/kitchen/cheeese_nevr_uses_that_frying_pan_on_that_shelf',
					'cheese/kitchen/counter_strike_source',
					'cheese/kitchen/SILLY_TRAMSHCANSH',
					'cheese/kitchen/Sink',
					'cheese/kitchen/THEE_AWESIOME_STOBEVE'
				];

				spritesToCache = ['characters/bluecheese_kitchen', 'characters/oisuzuki_kitchen'];

			case 'restaurante' | 'milkshake' | 'cultured':
				if (PlayState.isStoryMode)
				{
					soundsToCache = ['dialogue/bluecheeseText', 'dialogue/boyfriendText', 'dialogue/suzukiText', 'dialogue/clickText'];
				}

				imagesToCache = [
					'cheese/floor',
					'cheese/tableA',
					'cheese/tableB',
					'cheese/wall_suzuki',
					'cheese/char/boppers',
					'cheese/counter'
				];

				spritesToCache = [
					'characters/Cheese_Assets',
					'characters/Cheese_Exausted',
					'characters/BOYFRIEND',
					'characters/BOYFRIEND_ALT',
					'characters/GF_assets'
				];

			case 'cream-cheese':

				imagesToCache = [
					'bonus/cream/floor',
					'bonus/cream/tableA',
					'bonus/cream/tableB',
					'bonus/cream/t-side_mod',
					'cheese/wall_suzuki',
					'bonus/cream/counter'
				];

				spritesToCache = [
					'characters/CREAM_CHEESE',
					'characters/BOYFRIEND',
					'characters/BOYFRIEND_ALT',
					'characters/GF_assets',
					'characters/GF_Ghostoru'
				];

			case 'wifi':

				imagesToCache = [
					'cheese/floor_week2',
					'cheese/t-side_mod',
					'cheese/tableA',
					'cheese/tableB',
					'cheese/char/stickmin',
					'cheese/char/joey_new',
					'cheese/char/circle_bop',
					'cheese/char/ralsei_bop',
					'cheese/wall',
					'cheese/counter'
				];

				spritesToCache = [
					'characters/Cheese_Assets',
					'characters/ARSEN_EXPRESSIVE',
					'characters/oisuzuki'
				];

			case 'casual-duel':

				imagesToCache = [
					'cheese/floor_week2',
					'cheese/tableB',
					'cheese/char/fun_gang_latest',
					'cheese/char/sussy_table',
					'cheese/char/DELTARUNE',
					'cheese/wall',
					'cheese/counter',
					'cheese/char/avinera_counter',
					'cheese/char/crowdindie_big'
				];

				spritesToCache = [
					'characters/Cheese_Assets',
					'characters/DANSILOT',
					'characters/oisuzuki'
				];

			case 'dynamic-duo':
		}

		screen = new LoadingScreen();
		add(screen);

		screen.max = soundsToCache.length + imagesToCache.length + spritesToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;

		Thread.create(() ->
		{
			for (sound in soundsToCache)
			{
				trace("caching sound " + sound);
				FlxG.sound.cache(Paths.sound(sound, soundLibrary));
				screen.progress += 1;
			}

			for (image in imagesToCache)
			{
				trace("caching image " + image);
				FlxG.bitmap.add(Paths.image(image, imageLibrary, true));
				screen.progress += 1;
			}

			for (character in spritesToCache)
			{
				trace("caching character " + character);
				FlxG.bitmap.add(Paths.image(character, spriteLibrary, true));
				screen.progress += 1;
			}

			FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;

			trace("done caching");

			FlxG.camera.fade(FlxColor.BLACK, 1.5, false);

			new FlxTimer().start(2, function(_:FlxTimer)
			{
				screen.kill();
				screen.destroy();
				loadAndSwitchState(target, false);
			});
		});
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		MusicBeatState.switchState(getNextState(target, stopMusic));
	}

	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		Paths.setCurrentLevel(WeekData.getWeekDirectory());
		
		#if NO_PRELOAD_ALL
		var directory:String = WeekData.getWeekDirectory();
		var loaded:Bool = false;
		if (PlayState.SONG != null) {
			loaded = isSoundLoaded(getSongPath())
				&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
				&& isLibraryLoaded("shared") && isLibraryLoaded(directory);
		}
		
		if (!loaded)
			return new LoadingState(target, stopMusic);
		#end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}

	public static function dumpAdditionalAssets()
	{
		for (image in imagesToCache)
		{
			trace("dumped image " + image);
			FlxG.bitmap.removeByKey(Paths.image(image, imageLibrary, true));
		}

		for (character in spritesToCache)
		{
			trace("dumped character " + character);
			FlxG.bitmap.removeByKey(Paths.image(character, spriteLibrary, true));
		}

		soundsToCache = [];
		imagesToCache = [];
		spritesToCache = [];
	}
}
