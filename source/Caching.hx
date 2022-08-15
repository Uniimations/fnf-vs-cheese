package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import sys.thread.Thread;

using StringTools;

#if cpp
import Discord.DiscordClient;
#end

/**
 * @author BrightFyre
 */
class Caching extends MusicBeatState
{
	var calledDone = false;
	var screen:LoadingScreen;
	var debug:Bool = false;

	public function new()
	{
		super();

		enableTransIn = false;
		enableTransOut = false;
	}

	override function create()
	{
		super.create();

		screen = new LoadingScreen();
		add(screen);

		trace("Starting caching...");

		initSettings();
	}

	function initSettings()
	{
		#if debug
			debug = true;
		#end

		FlxG.save.bind(Main.curSave, 'indiecross');

		#if cpp
		DiscordClient.initialize();
		#end

		PlayerSettings.init();
		KadeEngineData.initSave();

		Highscore.load();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		FXHandler.UpdateColors();

		Application.current.onExit.add(function(exitCode)
		{
			FlxG.save.flush();
			DiscordClient.shutdown();
			Sys.exit(0);
		});

		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
		FlxG.sound.volume = 1;
		FlxG.sound.muted = false;
		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.console.autoPause = false;
		FlxG.autoPause = FlxG.save.data.focusfreeze;

		FlxG.worldBounds.set(0, 0);

		FlxG.save.data.optimize = false;

		if (FlxG.save.data.cachestart)
		{
			Thread.create(() ->
			{
				cache();
			});
		}
		else
		{
			end();
		}
	}

	function cache()
	{
		screen.max = 9;
		
		trace("Caching images...");

		screen.setLoadingText("Loading images...");

		// store this or else nothing will be saved
		// Thanks Shubs -sqirra
		FlxGraphic.defaultPersist = true;

		var splashes:FlxGraphic = FlxG.bitmap.add(Paths.image("AllnoteSplashes", "notes"));
		var sinSplashes:FlxGraphic = FlxG.bitmap.add(Paths.image("sinSplashes", "notes"));
		var parryAssets:FlxGraphic = FlxG.bitmap.add(Paths.image("Parry_assets", "notes"));
		var bounceAssets:FlxGraphic = FlxG.bitmap.add(Paths.image("NOTE_bounce", "notes"));
		var noteAssets:FlxGraphic = FlxG.bitmap.add(Paths.image("NOTE_assets", "notes"));

		Main.persistentAssets.push(splashes);
		screen.progress = 1;
		
		Main.persistentAssets.push(sinSplashes);
		screen.progress = 2;

		Main.persistentAssets.push(parryAssets);
		Main.persistentAssets.push(bounceAssets);
		Main.persistentAssets.push(noteAssets);
		screen.progress = 3;

		// CachedFrames.loadEverything();

		/* var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
			for (i in 0...3)
			{
				switch (i)
				{
					case 0:
						initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
					case 1:
						initSonglist = CoolUtil.coolTextFile(Paths.txt('nightmareSonglist'));
					case 2:
						initSonglist = CoolUtil.coolTextFile(Paths.txt('extraSonglist'));
				}

				for (i in 0...initSonglist.length)
				{
					var data:Array<String> = initSonglist[i].split(':');
					// FlxG.sound.cache(Paths.inst(data[0]));
					FlxG.sound.cache(Paths.voices(data[0]));
					trace("cached " + data[0]);
				}
		}*/

		screen.setLoadingText("Loading sounds...");

		FlxG.sound.cache(Paths.sound('hitsounds', 'shared'));
		screen.progress = 8;

		screen.setLoadingText("Loading cutscenes...");
		
		if (!debug)
		{
			trace('starting vid cache');
			var video = new VideoHandler();
			var vidSprite = new FlxSprite(0, 0);
			video.finishCallback = null;
	
			video.playMP4(Paths.video('bendy/1.5'), false, vidSprite, false, false, true);
			video.kill();
			trace('finished vid cache');
		}

		screen.progress = 9;

		FlxGraphic.defaultPersist = false;

		screen.setLoadingText("Done!");
		trace("Caching done!");

		end();
	}

	function end()
	{
		FlxG.camera.fade(FlxColor.BLACK, 1, false);
		
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.switchState(new TitleState());
		});
	}
}
