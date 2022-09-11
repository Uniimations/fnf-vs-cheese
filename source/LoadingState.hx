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

	static var soundLibrary:String = '';
	static var imageLibrary:String = '';

	var screen:LoadingScreen;

	override function create()
	{
		super.create();

		var daSong:String = PlayState.SONG.song.toLowerCase();

		soundLibrary = 'shared';
		imageLibrary = 'shared';

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

			case 'restaurante' | 'milkshake' | 'cultured':
				if (PlayState.isStoryMode)
				{
					soundsToCache = ['dialogue/bluecheeseText', 'dialogue/boyfriendText', 'dialogue/suzukiText', 'dialogue/clickText'];
				}

				if (PlayState.isStoryMode)
				{
					imagesToCache = [
						'cheese/counter',
						'cheese/floor',
						'cheese/tableA',
						'cheese/tableB',
						'cheese/wall_suzuki',
						'cheese/char/boppers',
						'cheese/front_boppers',

						'dialogue/Bluecheese_Dialogue',
						'dialogue/BOYFRIEND_Dialogue',
						'dialogue/gf_cheer',
						'dialogue/gf_Dialogue',
						'dialogue/OiSuzuki',
						'dialogue/cooltextboxes'
					];
				}
				else
				{
					imagesToCache = [
						'cheese/counter',
						'cheese/floor',
						'cheese/tableA',
						'cheese/tableB',
						'cheese/wall_suzuki',
						'cheese/char/boppers',
						'cheese/front_boppers'
					];
				}

			case 'cream-cheese':

				imagesToCache = [
					'bonus/cream/counter',
					'bonus/cream/floor',
					'bonus/cream/tableA',
					'bonus/cream/tableB',
					'bonus/cream/t-side_mod',
					'cheese/wall_suzuki'
				];

		}

		screen = new LoadingScreen();
		add(screen);

		screen.max = soundsToCache.length + imagesToCache.length;

		FlxG.camera.fade(FlxG.camera.bgColor, 0.5, true);

		FlxGraphic.defaultPersist = true;

		Thread.create(() ->
		{
			for (sound in soundsToCache)
			{
				trace("Caching sound " + sound);
				FlxG.sound.cache(Paths.sound(sound, soundLibrary));
				screen.progress += 1;
			}

			for (image in imagesToCache)
			{
				trace("Caching image " + image);
				FlxG.bitmap.add(Paths.image(image, imageLibrary, true));
				screen.progress += 1;
			}

			FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;

			trace("Done caching");

			new FlxTimer().start(1.5, function(_:FlxTimer)
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
			trace("dumped " + image);
			FlxG.bitmap.removeByKey(Paths.image(image, imageLibrary, true));
		}

		soundsToCache = [];
		imagesToCache = [];
	}
}
