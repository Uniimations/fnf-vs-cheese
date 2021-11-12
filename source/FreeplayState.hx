package;

import Song.SwagSong;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//Character head icons for your songs
	static var songIcons:Array<Dynamic> = [
		['bluecheese'],						//Week 1
		['arsen-fp', 'dansilot-fp'],		//Week 2
		['bob'],							//Week 3
		['suzuki-fp'],						//Week 4
	];

	static var bonusIcons:Array<Dynamic> = [
		['avinera'],						//frosted
		['dad']								//alter ego
	];

	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	public static var coolColors:Array<Int> = [];

	private var songArray:Array<String> = [];
	var bg:FlxSprite;
	var intendedColor:Int;
	var exColor:Int = 0xFF502378;
	var colorTween:FlxTween;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplayUnlockedTRACKS')); //tracks that are unlocked on default
		for (i in 0...initSonglist.length)
		{
			songArray = initSonglist[i].split(":");
			addSong(songArray[0], 0, songArray[1]);
			songs[songs.length-1].color = Std.parseInt(songArray[2]);
		}
		var colorsList = CoolUtil.coolTextFile(Paths.txt('freeplayCOLORS')); //all bg colors stored in a convenient text file
		for (i in 0...colorsList.length)
		{
			coolColors.push(Std.parseInt(colorsList[i]));
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (TitleState.isDebug)
			{
				addWeek(WeekData.songsNames[1], 1, songIcons[0]);
				addWeek(WeekData.songsNames[2], 2, songIcons[1]);
				addWeek(WeekData.songsNames[4], 4, songIcons[3]);
				addWeek(WeekData.bonusNames[0], 0, bonusIcons[0]);
			}
			else
			{
				if (FlxG.save.data.beatCulturedWeek)
					{
						addWeek(WeekData.songsNames[1], 1, songIcons[0]); // unlocked week 1 songs
					}
	
				if (FlxG.save.data.beatWeekEnding)
					{
						addWeek(WeekData.songsNames[2], 2, songIcons[1]); // unlocked week 2 songs
					}
				if (FlxG.save.data.beatBonus) // unlocked bonus songs
					{
						addWeek(WeekData.songsNames[4], 4, songIcons[3]);
						addWeek(WeekData.bonusNames[0], 0, bonusIcons[0]);
					}
			}

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		changeSelection();
		changeDiff();

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press P to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + Math.floor(lerpRating * 100) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var PP = FlxG.keys.justPressed.P; //it says it's unused but it is used if you preload all
		var newColor:Int = songs[curSelected].color;

		var songLowercase:String = songs[curSelected].songName.toLowerCase();

		//flash and shake function
		function changeShit():Void
		{
			FlxG.camera.shake(0.001, 0.1, function()
			{
				FlxG.camera.shake(0.002, 0.1, function()
				{
					FlxG.camera.shake(0.005, 0.05, function()
					{
						if (ClientPrefs.flashing) {
							FlxG.camera.flash(FlxColor.WHITE, 0.5);
						}
						FlxG.camera.shake(0.002, 0.1, function() {
							FlxG.camera.shake(0.001, 0.1, function(){
								
							});
						});
					});
				});
			});
		}

		if (upP)
		{
			switch (songLowercase)
			{
				case 'tutorial':
					{
						if (FlxG.save.data.beatBonus) {
							new FlxTimer().start(0.1, function(tmr:FlxTimer)
							{
								changeShit();
							}, 2);
							new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								changeSelection(-1);
							});
						}
					}
				case 'restaurante': //SONGS WITH EX DIFFICULTY
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
										if(colorTween != null) {
											colorTween.cancel();
										}
										intendedColor = 0xFF8B3551;
										colorTween = FlxTween.color(bg, 1, bg.color, 0xFF8B3551, {
											onComplete: function(twn:FlxTween) {
												colorTween = null;
											}
										});
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
						if (curDifficulty == 2) {
							if(colorTween != null) {
								colorTween.cancel();
							}
							intendedColor = exColor;
							colorTween = FlxTween.color(bg, 1, bg.color, exColor, {
								onComplete: function(twn:FlxTween) {
									colorTween = null;
								}
							});
						}
					}
				case 'cultured':
					{
						changeSelection(-1);
						if (curDifficulty == 2) {
							if(colorTween != null) {
								colorTween.cancel();
							}
							intendedColor = exColor;
							colorTween = FlxTween.color(bg, 1, bg.color, exColor, {
								onComplete: function(twn:FlxTween) {
									colorTween = null;
								}
							});
						}
					}
				case 'manager-strike-back':
					{
						if (curDifficulty == 3)
							{
								new FlxTimer().start(0.1, function(tmr:FlxTimer)
									{
										changeShit();
									}, 2);
								new FlxTimer().start(0.4, function(tmr:FlxTimer)
									{
										changeSelection(-1);
									});
							}
					}
				default:
					changeSelection(-1);
			}
		}
		if (downP)
		{
			switch (songLowercase)
			{
				case 'restaurante':
					{
						changeSelection(1);
						if (curDifficulty ==  2)
							{
								if(colorTween != null) {
									colorTween.cancel();
								}
								intendedColor = exColor;
								colorTween = FlxTween.color(bg, 1, bg.color, exColor, {
									onComplete: function(twn:FlxTween) {
										colorTween = null;
									}
								});
							}
					}
				case 'milkshake':
					{
						if (curDifficulty == 2 && !songLowercase.startsWith('restaurante'))
							{
								changeSelection(1);
								if(colorTween != null) {
									colorTween.cancel();
								}
								intendedColor = exColor;
								colorTween = FlxTween.color(bg, 1, bg.color, exColor, {
									onComplete: function(twn:FlxTween) {
										colorTween = null;
									}
								});
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
										if(colorTween != null) {
											colorTween.cancel();
										}
										intendedColor = newColor;
										colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
											onComplete: function(twn:FlxTween) {
												colorTween = null;
											}
										});
									});
							}
						else
							{
								changeSelection(1);
							}
					}
				case 'casual-duel':
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
				case 'frosted':
					{
						if (curDifficulty == 3)
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
					}
				default:
					changeSelection(1);
			}
		}

		/*if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);*/

		//completely rewrote the code for this! I'm proud of myself
		//difficulty dependencies
		if (controls.UI_LEFT_P)
		{
			switch (songLowercase)
			{
				case 'restaurante' | 'milkshake' | 'cultured': //SONGS WITH EX DIFFICULTY
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
										if (newColor == intendedColor && songs[curSelected].color != exColor) {
											if(colorTween != null) {
												colorTween.cancel();
											}
											intendedColor = exColor;
											colorTween = FlxTween.color(bg, 1, bg.color, exColor, {
												onComplete: function(twn:FlxTween) {
													colorTween = null;
												}
											});
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
										if(colorTween != null) {
											colorTween.cancel();
										}
										intendedColor = newColor;
										colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
											onComplete: function(twn:FlxTween) {
												colorTween = null;
											}
										});
									});
							}
						else
							{
								FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);
								changeDiff(-1);
							}
					}
				case 'manager-strike-back'  | 'frosted':
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.6); //manager strike back doesn't change
				default:
					FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);
					changeDiff(-1);
			}
		}

		if (controls.UI_RIGHT_P)
		{
			switch (songLowercase)
			{
				case 'restaurante' | 'milkshake' | 'cultured': //SONGS WITH EX DIFFICULTY
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
										if (songs[curSelected].color == intendedColor && songs[curSelected].color != exColor) {
											if(colorTween != null) {
												colorTween.cancel();
											}
											intendedColor = exColor;
											colorTween = FlxTween.color(bg, 1, bg.color, exColor, {
												onComplete: function(twn:FlxTween) {
													colorTween = null;
												}
											});
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
										changeDiff(1);
										if(colorTween != null) {
											colorTween.cancel();
										}
										intendedColor = newColor;
										colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
											onComplete: function(twn:FlxTween) {
												colorTween = null;
											}
										});
									});
							}
						else
							{
								FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);
								changeDiff(1);
							}
					}
				case 'manager-strike-back' | 'frosted':
					FlxG.sound.play(Paths.sound('cancelMenu'), 0.6); //manager strike back doesn't change
				default:
					FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);
					changeDiff(1);
			}
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		#if PRELOAD_ALL
		//pp as in p player not PP!!!
		if(PP)
		{
			destroyFreeplayVocals();
			var ass:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(ass, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				if (curDifficulty == 2) {
					vocals = new FlxSound().loadEmbedded(Paths.voicesex(PlayState.SONG.song));
				} else {
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				}
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			if (curDifficulty == 2) {
				FlxG.sound.playMusic(Paths.instex(PlayState.SONG.song), 0.7);
			} else {
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			}
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
		}
		else #end if (accepted)
		{
			var songLowercase:String = songs[curSelected].songName.toLowerCase();
			var ass:String = Highscore.formatSong(songLowercase, curDifficulty);
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + ass))) {
				ass = songLowercase;
				curDifficulty = 1;
			}
			trace ('ass initialized');
			trace ('LOADING FREEPLAY SONG');

			PlayState.SONG = Song.loadFromJson(ass, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;

			//for defining names of the difficulties
			var curDifName:String = '';

			switch (curDifficulty) {
				case 0:
					curDifName = 'Easy';
				case 1:
					curDifName = 'Hard';
				case 2:
					curDifName = 'EX';
				case 3:
					curDifName = 'UNFAIR';
			}
			trace ('CURRENT SONG: ' + songLowercase + ' | CURRENT DIFFICULTY: ' + curDifName + ' | DIFFICULTY INT: ' + curDifficulty); //added new shit here so it tells me wtf im doing
			if(colorTween != null) {
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.sound.music.volume = 0;
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		var songLowercase:String = songs[curSelected].songName.toLowerCase();
		var curNumberStart:Int = 0;
		var curNumberEnd:Int;

		curDifficulty += change;

		//MADE THIS CODE A LOT CLEANER!!!
		//difficulty dependencies
		switch (songLowercase)
		{
			case 'restaurante' | 'milkshake' | 'cultured':
				curNumberEnd = 2;
			case 'manager-strike-back' | 'frosted':
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
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = 'Difficulty: < ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMouse'), 0.6);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor && curDifficulty == 0 || curDifficulty == 1 || curDifficulty == 3) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		changeDiff();
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		if(week < FreeplayState.coolColors.length) {
			this.color = FreeplayState.coolColors[week];
		}
	}
}
