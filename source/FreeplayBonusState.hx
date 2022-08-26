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

class FreeplayBonusState extends MusicBeatState
{
	static var songIcons:Array<Dynamic> = [
		['bluecheese', 'bluecheese-tired', 'bluecheese'],
		['arsen-fp', 'dansilot-fp'],
		['suzuki-fp'],
	];

	static var bonusIcons:Array<Dynamic> = [
		['avinera', 'unii']
	];

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

	private var grpSongs:FlxTypedGroup<AlphabetVCR>;
	private var curPlaying:Bool = false;
	private var cantMove:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	public static var coolColors:Array<Int> = [];

	private var songArray:Array<String> = [];
	private var iconSprite:HealthIcon;

	var grpRoomBack:FlxTypedGroup<FlxSprite>;
	var grpArsen:FlxTypedGroup<FlxSprite>;

	var roomBack:FlxSprite;
	var roomComputer:FlxSprite;
	var Arsen:FlxSprite;
	var ArsenHand:FlxSprite;

	var pcLight:FlxSprite;
	var intendedColor:Int;
	var exColor:Int = 0xFF502378;
	var colorTween:FlxTween;
	var forcedColor:Bool = false;

	var disc:FlxSprite = new FlxSprite(1000, 730);
	var discIcon:HealthIcon = new HealthIcon('suzuki');

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var initSonglist = ['']; //tracks that are unlocked on default (NONE.. NO!!!! NO UNLOKCS BITCH I HATE YOU GRRRRGRRRR YEAH YOU BITCH I HATE YOU (unless ur diples ilysm <3))
		var colorsList = CoolUtil.coolTextFile(Paths.txt('freeplayCOLORS')); //all bg colors stored in a convenient text file
		for (i in 0...colorsList.length)
		{
			coolColors.push(Std.parseInt(colorsList[i]));
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Browsing Bonus Songs", null);
		#end

		addWeek(['CREAM-CHEESE'], 1, ['creamcheese']);
		addWeek(['Dynamic-Duo'], 2, ['uniinera-fp']);
		addWeek(['Below-Zero'], 2, ['avinera']);

		// LOAD MUSIC

		// LOAD CHARACTERS

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

		roomBack = new FlxSprite().loadGraphic(Paths.image('freeplay/FREEPLAY_BG'));
		roomBack.antialiasing = ClientPrefs.globalAntialiasing;

		pcLight = new FlxSprite().loadGraphic(Paths.image('freeplay/light_gray_scale'));
		pcLight.antialiasing = ClientPrefs.globalAntialiasing;

		if (MainMenuState.cursed)
			roomComputer = new FlxSprite().loadGraphic(Paths.image('freeplay/FREEPLAY_PC_EASTER_EGG'));
		else
			roomComputer = new FlxSprite().loadGraphic(Paths.image('freeplay/FREEPLAY_PC'));
		roomComputer.antialiasing = ClientPrefs.globalAntialiasing;

		grpArsen = new FlxTypedGroup<FlxSprite>();

		//Arsen = new FlxSprite(CoolUtil.spriteOffsets[1], CoolUtil.spriteOffsets[2]);
		if (MainMenuState.cursed) {
			Arsen = new FlxSprite(630, 160);
			Arsen.frames = Paths.getSparrowAtlas('freeplay/arsen_computer_easter_egg');
			Arsen.animation.addByPrefix('eyes', 'arsen computer bob', 24, true);
			Arsen.antialiasing = ClientPrefs.globalAntialiasing;
			Arsen.animation.play('eyes', true);
		} else {
			Arsen = new FlxSprite(632, 202);
			Arsen.frames = Paths.getSparrowAtlas('freeplay/arsen_computer');
			Arsen.animation.addByPrefix('idleBop', 'arsen computer idle', 24, false);
			Arsen.antialiasing = ClientPrefs.globalAntialiasing;
		}
		grpArsen.add(Arsen);

		//ArsenHand = new FlxSprite(CoolUtil.spriteOffsets[4], CoolUtil.spriteOffsets[5]);
		ArsenHand = new FlxSprite(562, 594);
		ArsenHand.frames = Paths.getSparrowAtlas('freeplay/arsen_hand');
		ArsenHand.animation.addByPrefix('idleBop', 'arsen computer hand', 24, false);
		ArsenHand.antialiasing = ClientPrefs.globalAntialiasing;

		if (!MainMenuState.cursed) {
			grpArsen.add(ArsenHand);
		}

		// ALL LAYERING

		add(roomBack);

		// adds arsen only after beating week 2
		if (FlxG.save.data.beatWeekEnding == true) {
			add(grpArsen);
		}

		add(pcLight);
		add(roomComputer);
		//add(grpRoomBack);

		disc.frames = Paths.getSparrowAtlas('freeplay/micd_up_discs');
		disc.animation.addByPrefix('bluecheese', 'bluecheese', 24);
		disc.animation.play('bluecheese');
		add(disc);

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

		pcLight.color = songs[curSelected].color;
		intendedColor = pcLight.color;
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

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['face'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		//

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		//SET CAMZOOM
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		var accuracyDisplay:Float = Math.floor(intendedRating * 10000) / 100;

		scoreText.text = 'HIGH SCORE: ' + intendedScore;
		accText.text = 'ACCURACY: ' + accuracyDisplay + '%';
		reposScoreText();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var newColor:Int = songs[curSelected].color;

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
			if (upP)
			{
				switch (songLowercase)
				{
					case 'dynamic-duo':
						{
							forcedColor = true;
							forceColorChange(0xFFff1f1f);
							changeSelection(-1);
						}
					case 'below-zero':
						{
							forcedColor = true;
							forceColorChange(0xFFc852ff);
							changeSelection(-1);
						}
					default:
						changeSelection(-1);
				}
			}

			if (downP)
			{
				switch (songLowercase)
				{
					case 'dynamic-duo':
						{
							if (FlxG.save.data.beatAlternateEnd) {
								forcedColor = true;
								forceColorChange(0xFF6260bd);
							} else {
								forcedColor = false;
							}

							changeSelection(1);
						}
					case 'below-zero':
						{
							forcedColor = false;
							if (FlxG.save.data.beatBonus)
							{
								new FlxTimer().start(0.1, function(tmr:FlxTimer)
									{
										changeShit();
									}, 2);
								new FlxTimer().start(0.4, function(tmr:FlxTimer)
									{
										changeSelection(1);
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

			//completely rewrote the code for this! I'm proud of myself

			//difficulty dependencies
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				changeDiff(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
				changeDiff(1);
			}

			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new FreeplayState());
				FlxTween.tween(disc, { alpha:0, 'scale.x':0}, 0.2, { ease: FlxEase.quartInOut});
			}

			if (accepted)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.8);
				FlxTween.tween(FlxG.camera, {y: FlxG.height * 0.5}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.3});

				// load json stuff and fucky if statements
				loadSongInfo(false);

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
						fadeMenuMusic();
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

	public static function fadeMenuMusic() {
		new FlxTimer().start(1, function(tmr:FlxTimer) {
			FlxG.sound.music.fadeOut(1, 0);
		});
	}

	function changeDiff(change:Int = 0)
	{
		var songLowercase:String = songs[curSelected].songName.toLowerCase();
		var curNumberStart:Int = 0;
		var curNumberEnd:Int;

		curDifficulty += change;

		//MADE THIS CODE A LOT CLEANER!!!
		//no it aint wtf past unii

		curNumberEnd = 1;

		if (curDifficulty < curNumberStart)
			curDifficulty = curNumberEnd;
		if (curDifficulty > curNumberEnd)
			curDifficulty = curNumberStart;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = 'Difficulty: < ' + CoolUtil.difficultyString() + ' >';
		reposScoreText();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);
		ArsenHand.animation.play('idleBop', true);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if (forcedColor == false && newColor != intendedColor && curDifficulty == 0 || curDifficulty == 1 || curDifficulty == 3) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(pcLight, 1, pcLight.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
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

		disc.animation.addByPrefix(songs[curSelected].songCharacter, songs[curSelected].songCharacter + '0', 24); // 0 just in case it freaks out and flickers between similar animation names.
		disc.animation.play(songs[curSelected].songCharacter);
	}

	private function loadSongInfo(?canMove:Bool = true):Void
	{
		// if you can move
		if (canMove)
			cantMove = false;
		else
			cantMove = true;

		var songLowercase = '';
		var realSong:String = songs[curSelected].songName.toLowerCase();

		if (realSong == '') {
			songLowercase = 'CREAM-CHEESE';
		} else {
			songLowercase = realSong;
		}

		var ass:String = Highscore.formatSong(songLowercase, curDifficulty);
		if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + ass))) {
			ass = songLowercase;
			curDifficulty = 1;
		}
		trace ('LOADING FREEPLAY SONG');

		PlayState.SONG = Song.loadFromJson(ass, songLowercase);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = songs[curSelected].week;

		if(colorTween != null) {
			colorTween.cancel();
		}

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

		// to fix loading problems force graphic image persist (it works for some reason, its a shitty way to optimize but... eh what can u do sex mod aint open source ...i think?)
		StoryMenuState.forceImagesPersist = true;

		if (StoryMenuState.forceImagesPersist)
			FlxGraphic.defaultPersist = true;
		else
			FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;
	}

	private function reposScoreText() {
		scoreText.x = FlxG.width - scoreText.width - 6;
		accText.x = FlxG.width - accText.width - 6;
	}

	private function forceColorChange(ColorToChange:Int) {
		if(colorTween != null) {
			colorTween.cancel();
		}
		new FlxTimer().start(0.01, function(tmr:FlxTimer) {
			colorTween = FlxTween.color(pcLight, 1, pcLight.color, ColorToChange, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		});
	}

	//BEAT HIT SHIT!
	override function beatHit()
    {
        super.beatHit();

		//sorry for this lol
        if (!MainMenuState.cursed) {
			if (curBeat % 2 == 0)
				Arsen.animation.play('idleBop', true);

			/*
			if (FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
				FlxG.camera.zoom += 0.030;
			}
			*/

			FlxTween.tween(FlxG.camera, {zoom:1.02}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
		}

        FlxG.log.add('beat');
    }
}
