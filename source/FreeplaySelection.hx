package;

import Song.SwagSong;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FreeplaySelection extends MusicBeatState
{
	public static var category:String = '';

	var songs:Array<SongMetaData> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var accText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;
	var accuracyDisplay:Float = 0;

	private var grpSongs:FlxTypedGroup<AlphabetVCR>;
	private var curPlaying:Bool = false;
	private var cantMove:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	public static var coolColors:Array<Int> = [];

	private var songArray:Array<String> = [];
	private var iconSprite:HealthIcon;

	var grpArsen:FlxTypedGroup<FlxSprite>;

	var roomComputer:FlxSprite;
	var Arsen:FlxSprite;
	var ArsenHand:FlxSprite;

	var pcLight:FlxSprite;
	var intendedColor:Int;
	var vipColor:Int = 0xFF502378;
	var colorTween:FlxTween;

	var disc:FlxSprite = new FlxSprite(1000, 730);
	var discIcon:HealthIcon = new HealthIcon('suzuki');

	var arsenType:Int = 0;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Browsing...", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// pc light colors

		coolColors = [];
		trace('check 1: ' + coolColors);

		var textPath:String = '';

		switch (category)
		{
			case 'STORY SONGS':
				textPath = 'story';
			case 'BONUS SONGS':
				textPath = 'bonus';
			case 'UNFAIR SONGS':
				textPath = 'unfair';
		}

		if (MainMenuState.cursed) textPath = 'easter_egg';

		var colorsList = CoolUtil.coolTextFile(Paths.txt('/freeplay/' + textPath + '_colors'));
		for (i in 0...colorsList.length)
		{
			coolColors.push(Std.parseInt(colorsList[i]));
		}
		trace('check 2: ' + coolColors);

		/*
		var offsetsTxt;
		var file:String = ('assets/images/freeplay/arsen_computer_offsets.txt'); // txt for arsen offsets
		if (OpenFlAssets.exists(file))
		{
			offsetsTxt = CoolUtil.coolTextFile(file);

			for (i in 0...offsetsTxt.length)
				{
					CoolUtil.spriteOffsets.push(Std.parseFloat(offsetsTxt[i]));
				}
			trace('loaded arsen offsets file');
		}
		else // crash prevention
		{
			CoolUtil.spriteOffsets = [
				[0],
				[0],
				[0],
				[0],
				[0],
				[0],
			];
			trace('failed to load txt file');
			trace('arsen offsets set to 0, 0');
		}
		*/

		// LOAD CHARACTERS

		if (MainMenuState.cursed)
		{
			var monster:FlxSprite = new FlxSprite(664, 78);
			monster.frames = Paths.getSparrowAtlas('freeplay/monster');
			monster.antialiasing = ClientPrefs.globalAntialiasing;
			monster.alpha = 0.5;
			monster.flipX = true;
			monster.animation.addByPrefix('idle', 'monster idle', 24, true);
			add(monster);

			monster.animation.play('idle', true);
		}
		else
		{
			var roomBack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('freeplay/FREEPLAY_BG'));
			add(roomBack);
		}

		pcLight = new FlxSprite().loadGraphic(Paths.image('freeplay/light_gray_scale'));
		pcLight.antialiasing = ClientPrefs.globalAntialiasing;

		roomComputer = new FlxSprite().loadGraphic(Paths.image('freeplay/FREEPLAY_PC'));
		roomComputer.antialiasing = ClientPrefs.globalAntialiasing;

		grpArsen = new FlxTypedGroup<FlxSprite>();

		//Arsen = new FlxSprite(CoolUtil.spriteOffsets[1], CoolUtil.spriteOffsets[2]);
		Arsen = new FlxSprite(699, 238);
		Arsen.frames = Paths.getSparrowAtlas('freeplay/arsen_computer');

		Arsen.animation.addByIndices('idle1_left', 'arsen computer week 1', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		Arsen.animation.addByIndices('idle1_right', 'arsen computer week 1', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

		Arsen.animation.addByIndices('idle2_left', 'arsen computer week 2', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		Arsen.animation.addByIndices('idle2_right', 'arsen computer week 2', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

		Arsen.animation.addByIndices('idleVIP_left', 'arsen computer vip', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		Arsen.animation.addByIndices('idleVIP_right', 'arsen computer vip', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

		Arsen.animation.addByIndices('idleGAMING_left', 'arsen computer GAMING', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		Arsen.animation.addByIndices('idleGAMING_right', 'arsen computer GAMING', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);

		Arsen.animation.addByPrefix('monster', 'arsen computer monster', 24, true);

		if (MainMenuState.cursed) Arsen.animation.play('monster', true);

		Arsen.antialiasing = ClientPrefs.globalAntialiasing;
		grpArsen.add(Arsen);

		//ArsenHand = new FlxSprite(CoolUtil.spriteOffsets[4], CoolUtil.spriteOffsets[5]);
		ArsenHand = new FlxSprite(586, 592);
		ArsenHand.frames = Paths.getSparrowAtlas('freeplay/arsen_hand');
		ArsenHand.animation.addByPrefix('normal', 'arsen computer hand0', 24, false);
		ArsenHand.animation.addByPrefix('vip', 'arsen computer hand vip', 24, false);
		ArsenHand.antialiasing = ClientPrefs.globalAntialiasing;

		if (!MainMenuState.cursed) {
			grpArsen.add(ArsenHand);
		}

		// ALL LAYERING

		// adds arsen only after beating week 2
		if (FlxG.save.data.beatWeekEnding == true) {
			add(grpArsen);
		}

		add(pcLight);
		add(roomComputer);

		disc.frames = Paths.getSparrowAtlas('freeplay/cd');
		add(disc);

		// ADD SONGS HERE

		switch (category)
		{
			case 'STORY SONGS':
				addSong('Tutorial', 0, 'suzuki');

				addSong('Restaurante', 1, 'bluecheese');
				addSong('Milkshake', 1, 'bluecheese-tired');
				addSong('Cultured', 1, 'bluecheese');

				if (FlxG.save.data.beatWeekEnding) {
					addSong('Wifi', 2, 'arsen');
					addSong('Casual-Duel', 3, 'dansilot');
				}

			case 'BONUS SONGS':
				if (FlxG.save.data.beatCream)
					addSong('CREAM-CHEESE', 2, 'creamcheese');
				else
					addSong('???', 2, 'creamcheese-fp');

				// MOVE TO EXTRAS MENU

				//addSong('Restaurante-Classic', 1, 'bluecheese');
				// ADD THESE WHEN SONGS ARE MADE FOR THEM !!!!!!!!!!!!! WOHOO YOPEE
				//addSong('Milkshake-Classic', 1, 'bluecheese');
				//addSong('Cultured-Classic', 1, 'bluecheese');

				if (FlxG.save.data.beatWeekEnding) {
					addSong('Dynamic-Duo', 3, 'uniinera');
					addSong('Below-Zero', 4, 'avinera');
					addSong('Above-Zero', 5, 'dad');

					addSong('Mozzarella', 6, 'bluecheese');
				}

				if (FlxG.save.data.beatOnion) {
					addSong('DIRTY-CHEATER', 7, 'onion');
					
					var initSonglist = CoolUtil.coolTextFile(Paths.mods('SONG_LIST.txt'));
					for (i in 0...initSonglist.length)
					{
						if(initSonglist[i] != null && initSonglist[i].length > 0) {
							var songArray:Array<String> = initSonglist[i].split(":");
							coolColors.push(Std.parseInt(songArray[2]));
	
							addSong(songArray[0], 0, songArray[1]);
						}
					}
				}

				/*
				var initSonglist = CoolUtil.coolTextFile(Paths.mods('SONG_LIST.txt'));
				for (i in 0...initSonglist.length)
				{
					if(initSonglist[i] != null && initSonglist[i].length > 0) {
						var songArray:Array<String> = initSonglist[i].split(":");
						coolColors.push(Std.parseInt(songArray[2]));

						addSong(songArray[0], 0, songArray[1]);
					}
				}
				*/

			case 'UNFAIR SONGS':
				addSong('Manager-Strike-Back', 0, 'suzuki-fp');
				//addSong('Relinquish', 1, 'arsen-fp'); bye Avinera :sob
				/**
					REMOVED SONGS: (lol)
				**/
				//addSong('Frosted', 1, 'avinera');
				//addSong('Alter-Ego', 2, 'unii');

			default:
				var luaSongs = CoolUtil.coolTextFile(Paths.mods('SONG_LIST.txt'));
				for (i in 0...luaSongs.length)
				{
					if (luaSongs[i] != null && luaSongs[i].length > 0)
					{
						var songArray:Array<String> = luaSongs[i].split(":");
						coolColors.push(Std.parseInt(songArray[2]));

						addSong(songArray[0], 0, songArray[2]);
					}
					else
					{
						addSong('Restaurante', 0, 'dad');
					}
				}
		}

		grpSongs = new FlxTypedGroup<AlphabetVCR>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:AlphabetVCR = new AlphabetVCR(8, (70 * i) + 100, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			iconSprite = new HealthIcon(songs[i].songCharacter);
			iconSprite.sprTracker = songText;

			iconArray.push(iconSprite);
			add(iconSprite);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(0 - 6, 0).makeGraphic(FlxG.width + 50, 142, 0xFF000000);
		scoreBG.alpha = 0.6;

		accText = new FlxText(FlxG.width * 0.7, scoreText.y + 42, 0, "", 32);
		accText.font = scoreText.font;

		diffText = new FlxText(accText.x - 475, accText.y + 32, 0, "", 42);
		diffText.font = scoreText.font;

		add(scoreBG);
		add(scoreText);
		add(accText);
		add(diffText);

		changeSelection();
		changeDiff();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT);
		text.scrollFactor.set();
		add(text);

		Conductor.changeBPM(120);

		super.create();

		// TWEENS AFTER LOADING (probably)
		new FlxTimer().start(0.50, function(tmr: FlxTimer)
		{
			disc.scale.x = 0;
			FlxTween.tween(disc, { 'scale.x':1, y: -30, x: 1005}, 0.6, { ease: FlxEase.quartInOut});
		});
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetaData(songName, weekNum, songCharacter, coolColors));
	}

	var newColor:Int;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		//SET CAMZOOM
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		scoreText.text = 'HIGH SCORE: ' + intendedScore;
		accText.text = 'ACCURACY: ' + accuracyDisplay + '%';
		reposScoreText();

		newColor = songs[curSelected].color;
		var songLowercase:String = songs[curSelected].songName.toLowerCase();

		//flash and shake function
		function changeShit():Void
		{
			cantMove = true;
			FlxG.camera.shake(0.001, 0.1, function()
			{
				FlxG.camera.shake(0.002, 0.1, function()
				{
					FlxG.camera.shake(0.005, 0.05, function()
					{
						if (ClientPrefs.flashing) {
							FlxG.camera.flash(FlxColor.WHITE, 0.5);
						} else {
							FlxG.camera.flash(FlxColor.BLACK, 0.5);
						}
						cantMove = false;
					});
				});
			});
		}

		// THE BRACKETS IN THESE CASES ARE USELESS BUT IT LOOKS NICE SO I NEVER BOTHERED TO GET RID OF THEM LMAO
		// also I used to be really really proud of this but it looks bad now... sorry hehe :]
		if (!cantMove)
		{
			if (controls.UI_UP_P)
			{
				switch (songLowercase)
				{
					case 'restaurante': //SONGS WITH VIP DIFFICULTY
						{
							if (curDifficulty == 2)
								{
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											changeShit();
										}, 2);
									new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											changeSelection(-1); 
											change_pc_color(songs[curSelected].color);
										});
								}
							else
								{
									changeSelection(-1);
								}
						}
					case 'milkshake':
						{
							changeSelection(-1);
							if (curDifficulty == 2) change_pc_color(vipColor);
						}
					case 'cultured':
						{
							changeSelection(-1);
							if (curDifficulty == 2) change_pc_color(vipColor);
						}
					default:
						changeSelection(-1);
				}
			}

			if (controls.UI_DOWN_P)
			{
				switch (songLowercase)
				{
					case 'restaurante':
						{
							changeSelection(1);
							if (curDifficulty ==  2) change_pc_color(vipColor);
						}
					case 'milkshake':
						{
							if (curDifficulty == 2 && !songLowercase.startsWith('restaurante'))
								{
									changeSelection(1);
									change_pc_color(vipColor);
								}
							else
								{
									changeSelection(1);
								}
						}
					case 'cultured':
						{
							if (curDifficulty == 2 && !songLowercase.startsWith('milkshake'))
								{
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											changeShit();
										}, 2);
									new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											changeSelection(1);
											change_pc_color(newColor);
										});
								}
							else
								{
									changeSelection(1);
								}
						}
					default:
						changeSelection(1);
				}
			}

			//difficulty dependencies
			if (controls.UI_LEFT_P)
			{
				switch (songLowercase)
				{
					case 'restaurante' | 'milkshake' | 'cultured': //SONGS WITH VIP DIFFICULTY
						{
							if (curDifficulty == 0)
								{
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											changeShit();
										}, 2);
									new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											changeDiff(-1);
											if (newColor == intendedColor && songs[curSelected].color != vipColor) {
												change_pc_color(vipColor);
											}
										});
								}
							else if (curDifficulty == 2)
								{
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											changeShit();
										}, 2);
									new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											changeDiff(-1);
											change_pc_color(newColor);
										});
								}
							else
								{
									FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
									changeDiff(-1);
								}
						}
					default:
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						changeDiff(-1);
				}
			}

			if (controls.UI_RIGHT_P)
			{
				switch (songLowercase)
				{
					case 'restaurante' | 'milkshake' | 'cultured': //SONGS WITH VIP DIFFICULTY
						{
							if (curDifficulty == 1)
								{
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											changeShit();
										}, 2);
									new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											changeDiff(1);
											if (songs[curSelected].color == intendedColor && songs[curSelected].color != vipColor) change_pc_color(vipColor);
										});
								}
							else if (curDifficulty == 2)
								{
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
										{
											changeShit();
										}, 2);
									new FlxTimer().start(0.4, function(tmr:FlxTimer)
										{
											changeDiff(1);
											change_pc_color(newColor);
										});
								}
							else
								{
									FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
									changeDiff(1);
								}
						}
					default:
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
						changeDiff(1);
				}
			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));

				if (!MainMenuState.cursed) FlxG.sound.playMusic(Paths.music('freaky_overture'));

				Conductor.changeBPM(120);
				MusicBeatState.switchState(new FreeplayState());
				FlxTween.tween(disc, { alpha:0, 'scale.x':0}, 0.2, { ease: FlxEase.quartInOut});
			}

			if (controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.8);
				FlxTween.tween(FlxG.camera, {y: FlxG.height * 0.5}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.3});

				// load json stuff and fucky if statements
				loadSongInfo(false, true);

				// tween disc
				FlxTween.tween(disc, { alpha:0, 'scale.x':0}, 1, { ease: FlxEase.quartInOut});

				// text alpha bullshit and switch state
				for (i in 0...iconArray.length)
				{
					FlxTween.tween(iconArray[i], { alpha:0}, 1, { ease: FlxEase.smoothStepOut});
				}

				grpSongs.forEach(function(item:AlphabetVCR)
				{
					FlxTween.tween(item, {alpha: 0}, 1, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							item.kill();
						}
					});
	
					FlxFlicker.flicker(item, 1.1, 0.06, false, false, function(flick:FlxFlicker)
					{
						LoadingState.loadAndSwitchState(new PlayState());
						FreeplayState.fadeMenuMusic();
					});
				});
			}
			else if (controls.RESET)
			{
				openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
			}
		}
		super.update(elapsed);

		// MATH SPINNY SHIT!
		disc.angle = disc.angle += 0.6 / (ClientPrefs.framerate / 60);
	}

	function changeDiff(change:Int = 0)
	{
		var songLowercase:String = songs[curSelected].songName.toLowerCase();
		var curNumberStart:Int = 0;
		var curNumberEnd:Int;

		curDifficulty += change;

		//MADE THIS CODE A LOT CLEANER!!!
		//no it aint wtf past unii

		//difficulty dependencies
		switch (songLowercase)
		{
			case 'restaurante' | 'milkshake' | 'cultured':
				curNumberEnd = 2;
			case 'dirty-cheater':
				curNumberStart = 1;
				curNumberEnd = 1;
			case 'manager-strike-back' | 'frosted' | 'alter-ego':
				curNumberStart = 3;
				curNumberEnd = 3;
			default:
				curNumberEnd = 1;
		}

		if (curDifficulty < curNumberStart)
			curDifficulty = curNumberEnd;
		if (curDifficulty > curNumberEnd)
			curDifficulty = curNumberStart;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		accuracyDisplay = Math.floor(intendedRating * 10000) / 100;
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = 'Difficulty: < ' + CoolUtil.difficultyString() + ' >';
		reposScoreText();

		if (category == 'BONUS SONGS' && !FlxG.save.data.beatCream)
		{
			//do nothing
		}
		else if (curNumberEnd == 2)
		{
			danceLeft = !danceLeft;
			listen_to_song();
		}
	}

	var instPlaying:Int = -1;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);

		if (curDifficulty == 2)
			ArsenHand.animation.play('vip', true);
		else
			ArsenHand.animation.play('normal', true);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		accuracyDisplay = Math.floor(intendedRating * 10000) / 100;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.2;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.2;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		changeDiff();

		if (category == 'BONUS SONGS' && !FlxG.save.data.beatCream)
		{
			//do nothing
		}
		else
		{
			listen_to_song();
		}

		if (curDifficulty != 2) {
			new FlxTimer().start(0.05, function(tmr:FlxTimer)
			{
				change_pc_color(newColor);
			});
		}

		// FINISH THIS LATER !!!!
		#if !PLAYTEST_BUILD
		// Updating Discord Rich Presence
		switch (FlxG.random.int(0, 5))
		{
			case 0:
				DiscordClient.changePresence("Vibing to " + songs[curSelected].songName + " for:", null, null, true);
			case 1:
				DiscordClient.changePresence("Sleeping on someone with " + songs[curSelected].songName + " for:", null, null, true);
			case 2:
				DiscordClient.changePresence("Dreaming about " + songs[curSelected].songName + " for:", null, null, true);
			case 3:
				DiscordClient.changePresence("Suckling some " + songs[curSelected].songName + " for:", null, null, true);
			case 4:
				DiscordClient.changePresence("Presenting " + songs[curSelected].songName + " to myself for:", null, null, true);
			case 5:
				DiscordClient.changePresence("Admiring " + songs[curSelected].songName + " for:", null, null, true);
		}
		#end

		disc.animation.addByPrefix(songs[curSelected].songCharacter, songs[curSelected].songCharacter + '0', 24); // 0 just in case it freaks out and flickers between similar animation names.
		disc.animation.play(songs[curSelected].songCharacter);
	}

	private function listen_to_song():Void
	{
		if (!MainMenuState.cursed)
		{
			loadSongInfo(true, false);

			FlxG.sound.music.volume = 0;

			var soundSuffix:String = '';
			if (curDifficulty == 2) soundSuffix = 'VIP';

			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song, soundSuffix), 0.7);
			Conductor.changeBPM(PlayState.SONG.bpm);
			instPlaying = curSelected;

			if (curDifficulty == 2)
			{
				arsenType = 2;
				ArsenHand.animation.play('vip', true);
			}
			else
			{
				switch (songs[curSelected].songName.toLowerCase())
				{
					case 'wifi' | 'casual-duel' | 'dynamic-duo' | 'below-zero':
						arsenType = 1;
					case 'manager-strike-back' | 'frosted' | 'alter-ego':
						arsenType = 3;
					default:
						arsenType = 0;
				}
				ArsenHand.animation.play('normal', true);
			}
			arsenBop();
		}
	}

	private function loadSongInfo(canMove:Bool, displayDifInfo:Bool):Void
	{
		// if you can move
		if (canMove)
			cantMove = false;
		else
			cantMove = true;

		var songLowercase = '';
		var realSong:String = songs[curSelected].songName.toLowerCase();

		if (songs[curSelected].songName == '???')
		{
			songLowercase = 'cream-cheese';
		}
		else
		{
			songLowercase = realSong;
		}

		var ass:String = Highscore.formatSong(songLowercase, curDifficulty);
		if(!OpenFlAssets.exists(Paths.chart(songLowercase + '/' + ass))) {
			ass = songLowercase + '-hard';
			curDifficulty = 1;
		}

		PlayState.SONG = Song.loadFromJson(ass, songLowercase);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = songs[curSelected].week;

		if(colorTween != null) {
			colorTween.cancel();
		}

		if (displayDifInfo)
		{
			trace ('LOADING FREEPLAY SONG');

			// for defining names of the difficulties ONLY in command prompt logs
			var curDifName:String = '';
			switch (curDifficulty) {
				case 0:
					curDifName = 'Easy';
				case 1:
					curDifName = 'Hard';
				case 2:
					curDifName = 'VIP';
				case 3:
					curDifName = 'UNFAIR';
			}
			trace ('CURRENT SONG: ' + songLowercase + ' | CURRENT DIFFICULTY: ' + curDifName + ' | DIFFICULTY INT: ' + curDifficulty); //added new shit here so it tells me wtf im doing
		}
	}

	private function change_pc_color(newColor):Void
	{
		if(colorTween != null) {
			colorTween.cancel();
		}
		intendedColor = newColor;
		colorTween = FlxTween.color(pcLight, 0.3, pcLight.color, newColor, {
			onComplete: function(twn:FlxTween) {
				colorTween = null;
			}
		});
	}

	private function reposScoreText() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		accText.x = FlxG.width - accText.width - 6;
	}

	var danceLeft:Bool = false;
	var rightAnim:String = '';
	var leftAnim:String = '';

	//BEAT HIT SHIT!
	override function beatHit()
    {
        super.beatHit();

        if (!MainMenuState.cursed)
		{
			arsenBop();
			FlxTween.tween(FlxG.camera, {zoom:1.02}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
		}

        FlxG.log.add('beat');
    }

	function arsenBop():Void
	{
		danceLeft = !danceLeft;

		calculateAnims();

		if (danceLeft)
			Arsen.animation.play(rightAnim);
		else
			Arsen.animation.play(leftAnim);
	}

	function calculateAnims():Void
	{
		switch (arsenType)
		{
			case 0:
				rightAnim = 'idle1_right';
				leftAnim = 'idle1_left';
			case 1:
				rightAnim = 'idle2_right';
				leftAnim = 'idle2_left';
			case 2:
				rightAnim = 'idleVIP_right';
				leftAnim = 'idleVIP_left';
			case 3:
				rightAnim = 'idleGAMING_right';
				leftAnim = 'idleGAMING_left';
		}
	}
}
