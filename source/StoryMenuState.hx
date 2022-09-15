package;

import flixel.addons.plugin.taskManager.FlxTask;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.graphics.FlxGraphic;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	//name display
	var weekNames:Array<String> = [
		"How To Rap",
		"Restaurante De Fromage Bleu",
		"Self Insert",
		"Bonus Week",

		"Unlock Weeks",
		"Lock Weeks"
	];

	//main image back display
	var weekImageBack:Array<String> = [
		'tutorial',		
		'week1',
		'week2',
		'heart',

		'error',
		'error'
	];

	//week tag or code name (only used in code)
	var weekTag:Array<Dynamic> = [
		['tutorial'],
		['week_1'],
		['week_2'],
		['manager'],

		['unlock'],
		['lock']
	];

	public var animOffsets:Map<String, Array<Dynamic>>;
	public static var weekUnlockedItems:Array<Bool> = [];

	var weekDefaultItems:Array<Bool> = [
		true,	//Tutorial
		false,	//Week 1
		false,  //Week 2
		false, 	//Manager Strike Back

		true, 	//debug
		true 	//debug
	];

	var weekDebugItems:Array<Bool> = [
		true,	//Tutorial
		true,	//Week 1
		true,   //Week 2
		true, 	//Manager Strike Back

		true, 	//debug
		true 	//debug
	];

	var weekTutorialItems:Array<Bool> = [
		true,	//Tutorial
		true,	//Week 1
		false,  //Week 2
		false, 	//Manager Strike Back

		true, 	//debug
		true 	//debug
	];

	var weekCulturedItems:Array<Bool> = [
		true,	//Tutorial
		true,	//Week 1
		true,   //Week 2
		false, 	//Manager Strike Back

		true, 	//debug
		true 	//debug
	];

	var weekBonusItems:Array<Bool> = [
		true,	//Tutorial
		true,	//Week 1
		true,  	//Week 2
		true, 	//Manager Strike Back

		true, 	//debug
		true 	//debug
	];

	var scoreText:FlxText;
	var resetText:FlxText;

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var weekImage:FlxSprite;
	var weekLock:FlxSprite;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		animOffsets = new Map<String, Array<Dynamic>>();

		#if !debug
		if (FlxG.save.data.beatTutorial)
			{
				weekUnlockedItems = weekTutorialItems;
			}
		else
			{
				weekUnlockedItems = weekDefaultItems;
			}

		if (FlxG.save.data.beatCulturedWeek)
			{
				weekUnlockedItems = weekCulturedItems;
			}

		if (FlxG.save.data.beatWeekEnding)
			{
				weekUnlockedItems = weekBonusItems;
			}
		#else
		weekUnlockedItems = weekDebugItems;
		#end

		var blackBack:FlxSprite = new FlxSprite().loadGraphic(Paths.image('storymenu/black_stuff_scuffed'));
		blackBack.antialiasing = ClientPrefs.globalAntialiasing;

		scoreText = new FlxText(10, 60, 0, "SCORE: PLACEHOLDER SCORE TEXT", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		resetText = new FlxText(scoreText.x, 680, 0, "Press RESET to Reset the weeks Score and Accuracy.", 36);
		resetText.setFormat("VCR OSD Mono", 20);
		resetText.alpha = 0.5;

		txtWeekTitle = new FlxText(10, 25, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('storymenu/campaign_menu_UI_assets');

		weekImage = new FlxSprite(0, 0);
		weekImage.alpha = 1;
		weekImage.antialiasing = ClientPrefs.globalAntialiasing;
		weekLock = new FlxSprite(0, 0);
		weekLock.antialiasing = ClientPrefs.globalAntialiasing;

		grpWeekText = new FlxTypedGroup<MenuItem>();

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);

		grpLocks = new FlxTypedGroup<FlxSprite>();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Browsing Story Menu", null);
		#end

		for (i in 0...WeekData.songsNames.length)
		{
			var weekThing:MenuItem = new MenuItem(0, 56 + 396, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = ClientPrefs.globalAntialiasing;

			if (i < weekUnlockedItems.length && !weekUnlockedItems[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		difficultySelectors = new FlxGroup();

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 40, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('leftIdle', "arrow left", 24, true);
		//leftArrow.animation.addByPrefix('leftPress', "arrow push left", 24, false);
		leftArrow.animation.addByIndices('leftPress', "arrow push left", [1], '', 24, false);
		leftArrow.animation.play('leftIdle');
		addOffset('leftIdle', 0, 0);
		addOffset('leftPress', -10, 0);
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite(leftArrow.x + 12, leftArrow.y + 80).loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.x += (308 - sprDifficulty.width) / 2;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 300, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('rightIdle', "arrow right", 24, true);
		//rightArrow.animation.addByPrefix('rightPress', "arrow push right", 24, false);
		rightArrow.animation.addByIndices('rightPress', "arrow push right", [1], '', 24, false);
		rightArrow.animation.play('rightIdle');
		addOffset('rightIdle', 0, 0);
		addOffset('rightPress', -15, 0);
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		var tracksSprite:FlxSprite = new FlxSprite(FlxG.width * 0.07, weekImage.y + 524.2).loadGraphic(Paths.image('storymenu/Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;

		txtTracklist = new FlxText(FlxG.width * 0.05, tracksSprite.y + 60, 0, "", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFF9CF51;

		//ALL LAYERING

		//WEEK LAYER
		add(grpWeekText);
		add(grpLocks);
		add(blackBarThingie);

		//BACKGROUND LAYER
		add(weekImage);
		add(weekLock);
		add(blackBack);

		//DIFFICULTY LAYER
		add(difficultySelectors);
		add(sprDifficultyGroup);

		//TEXT LAYER
		add(tracksSprite);
		add(txtTracklist);
		add(scoreText);
		add(resetText);
		add(txtWeekTitle);

		changeWeek();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		//

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "HIGH SCORE:" + lerpScore;

		if (curWeek == 4 || curWeek == 5) {
			sprDifficultyGroup.visible = false;
			difficultySelectors.visible = false;
		} else {
			sprDifficultyGroup.visible = weekUnlockedItems[curWeek];
			difficultySelectors.visible = sprDifficultyGroup.visible;
		}

		//shitty if statement
		if (weekUnlockedItems[curWeek])
			weekLock.visible = false;
		else
			weekLock.visible = true;

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				changeDifficulty(0, false); //changes the difficulty to the set ones
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				changeDifficulty(0, false); //changes the difficulty to the set ones
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('rightPress')
			else
				rightArrow.animation.play('rightIdle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('leftPress');
			else
				leftArrow.animation.play('leftIdle');

			if (controls.UI_RIGHT_P)
				changeDifficulty(1);
			if (controls.UI_LEFT_P)
				changeDifficulty(-1);

			if (controls.ACCEPT)
			{
				selectWeek();
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (curWeek >= weekUnlockedItems.length || weekUnlockedItems[curWeek])
		{
			switch (curWeek)
			{
				case 4:
					if (stopspamming == false)
						{
							FlxG.sound.play(Paths.sound('confirmMenu'));
							FlxG.camera.flash(FlxColor.WHITE, 1);
							stopspamming = true;

							new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								stopspamming = false;
								if (FlxG.save.data.beatTutorial == null || FlxG.save.data.beatTutorial == false) {
									FlxG.save.data.beatTutorial = true;
								}
								if (FlxG.save.data.beatCulturedWeek == null || FlxG.save.data.beatCulturedWeek == false) {
									FlxG.save.data.beatCulturedWeek = true;
								}
								if (FlxG.save.data.beatWeekEnding == null || FlxG.save.data.beatWeekEnding == false) {
									FlxG.save.data.beatWeekEnding = true;
								}
								if (FlxG.save.data.beatNormalEnd == null || FlxG.save.data.beatNormalEnd == false) {
									FlxG.save.data.beatNormalEnd = true;
								}
								if (FlxG.save.data.beatAlternateEnd == null || FlxG.save.data.beatAlternateEnd == false) {
									FlxG.save.data.beatAlternateEnd = true;
								}
								if (FlxG.save.data.beatBonus == null || FlxG.save.data.beatBonus == false) {
									FlxG.save.data.beatBonus = true;
								}
								if (FlxG.save.data.beatBNB == null || FlxG.save.data.beatBNB == false) {
									FlxG.save.data.beatBNB = true;
								}
								if (FlxG.save.data.diedTwiceFrosted == null || FlxG.save.data.diedTwiceFrosted == false) {
									FlxG.save.data.diedTwiceFrosted = true;
								}
							});
						}

				case 5:
					if (stopspamming == false)
						{
							FlxG.sound.play(Paths.sound('confirmMenu'));
							FlxG.camera.flash(FlxColor.WHITE, 1);
							stopspamming = true;

							new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								stopspamming = false;
								if (FlxG.save.data.beatTutorial == null || FlxG.save.data.beatTutorial == true) {
									FlxG.save.data.beatTutorial = false;
								}
								if (FlxG.save.data.beatCulturedWeek == null || FlxG.save.data.beatCulturedWeek == true) {
									FlxG.save.data.beatCulturedWeek = false;
								}
								if (FlxG.save.data.beatWeekEnding == null || FlxG.save.data.beatWeekEnding == true) {
									FlxG.save.data.beatWeekEnding = false;
								}
								if (FlxG.save.data.beatBonus == null || FlxG.save.data.beatBonus == true) {
									FlxG.save.data.beatBonus = false;
								}
								if (FlxG.save.data.beatBNB == null || FlxG.save.data.beatBNB == true) {
									FlxG.save.data.beatBNB = false;
								}
								if (FlxG.save.data.diedTwiceFrosted == null || FlxG.save.data.diedTwiceFrosted == true) {
									FlxG.save.data.diedTwiceFrosted = false;
								}
							});
						}

				default:
					if (stopspamming == false)
						{
							FlxG.sound.play(Paths.sound('confirmMenu'));
							FlxTween.tween(FlxG.camera, {y: FlxG.height}, 1.6, {ease: FlxEase.expoIn, startDelay: 0.3});
							grpWeekText.members[curWeek].startFlashing();

							stopspamming = true;
						}

						var songArray:Array<String> = [];
						var leWeek:Array<Dynamic> = [];

						if (curWeek == 2) {
							leWeek = ['Wifi', 'Casual-Duel'];
						} else {
							leWeek = WeekData.songsNames[curWeek];
						}

						for (i in 0...leWeek.length) {
							songArray.push(leWeek[i]);
						}

						PlayState.storyPlaylist = songArray;
						PlayState.isStoryMode = true;
						selectedWeek = true;

						var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
						if(diffic == null) diffic = '';

						PlayState.storyDifficulty = curDifficulty;

						switch (curWeek)
						{
							case 3: // forces easy mode if pussy mode
								if (ClientPrefs.pussyMode)
									PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + '-easy', PlayState.storyPlaylist[0].toLowerCase());
								else
									PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
							default:
								PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
						}
						PlayState.storyWeek = curWeek;
						PlayState.campaignScore = 0;
						PlayState.campaignMisses = 0;

						LoadingState.target = new PlayState();

						//MP4 INTRO CUTSCENES
						#if WINDOWS_BUILD
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							addMP4Intro('wifi', 2);
							FreeplayState.fadeMenuMusic();
						});
						#else
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							MusicBeatState.switchState(new LoadingState());
							FreeplayState.fadeMenuMusic();
						});
						#end
			}
		}
	}

	function changeDifficulty(change:Int = 0, ?playTrans:Bool = true):Void
	{
		var daWeek:Int = curWeek;
		var curNumberStart:Int = 0;
		var curNumberEnd:Int = 1;

		curDifficulty += change;

		//difficulty dependencies
		switch (daWeek)
		{
			case 3:
				curNumberStart = 3;
				curNumberEnd = 3;
			default:
				curNumberEnd = 1;
		}

		if (curDifficulty < curNumberStart)
			curDifficulty = curNumberEnd;
		if (curDifficulty > curNumberEnd)
			curDifficulty = curNumberStart;

		sprDifficultyGroup.forEach(function(spr:FlxSprite) {
			spr.visible = false;
			if(curDifficulty == spr.ID) {
				spr.visible = true;
				spr.alpha = 0;
				spr.y = leftArrow.y - 15;
				FlxTween.tween(spr, {y: leftArrow.y + 15, alpha: 1}, 0.07);
			}
		});

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.getWeekNumber(curWeek), curDifficulty);
		#end
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= WeekData.songsNames.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.songsNames.length - 1;

		var leName:String = '';
		if(curWeek < weekNames.length) {
			leName = weekNames[curWeek];
		}

		txtWeekTitle.text = leName;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlockedItems[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.4;
			bullShit++;
		}

		var assetName:String = weekImageBack[0];
		if(curWeek < weekImageBack.length) assetName = weekImageBack[curWeek];

		//weekImage.loadGraphic(Paths.image('storymenu/menuimages/' + assetName));

		weekImage.alpha = 1;
		weekImage.loadGraphic(Paths.image('storymenu/menuimages/' + assetName));

		weekLock.loadGraphic(Paths.image('storymenu/story_lock'));
		updateText();
	}

	function updateText()
	{
		var weekArray:Array<String> = weekTag[0];
		if(curWeek < weekTag.length) weekArray = weekTag[curWeek];

		var stringThing:Array<String> = WeekData.songsNames[curWeek];

		txtTracklist.text = '';
		for (i in 0...stringThing.length)
		{
			txtTracklist.text += stringThing[i] + '\n';
		}

		txtTracklist.text = StringTools.replace(txtTracklist.text, '-', ' ');
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.getWeekNumber(curWeek), curDifficulty);
		#end
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function addMP4Intro(videoName:String, weekNum:Int)
	{
		#if WINDOWS_BUILD
		var video:VideoMP4State = new VideoMP4State();

		if (curWeek == weekNum && !PlayState.isCutscene)
		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			{
				video.playMP4(Paths.video('mp4/' + videoName + '/' + videoName));
				video.finishCallback = function()
				{
					MusicBeatState.switchState(new LoadingState());
				}
				PlayState.isCutscene = true;
			}
		});
		else // fix for crash after going into another week after week 2.
		{
			PlayState.isCutscene = false;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new LoadingState());
			});
		}
		#end
	}
}
