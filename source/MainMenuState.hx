package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flash.system.System;
import flixel.util.FlxTimer;
import openfl.utils.Assets as OpenFlAssets;
import Achievements;

using StringTools;

class MainMenuState extends MusicBeatState
{
	// STRINGS AND MISC

	public static var psychEngineVersion:String = '0.3.2'; //This is also used for Discord RPC
	public static var cheeseVersion:String = '2.0.0'; //VERSION NUMBER FOR VS CHEESE ONLY CHANGE WHEN NEEDED/UPDATED
	public var modificationString:String = '';
	public var defaultCamZoom:Float = 0.9;

	//	MENU ITEMS

	public static var curSelected:Int = 0;
	public static var curTrophySelect:Bool = false;

	var trophy:FlxSprite;
	var trophyFloat:Float = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;

	// STUFF

	public static var cursed:Bool = false;
	private var jumpscareChance:Int;
	private var cheesePats:Int;

	var CheeseVersionShit:FlxText;
	var versionShit:FlxText;

	var wallBack:FlxSprite;
	var wallGlow:FlxSprite;
	var cheeseScrunkly:FlxSprite;
	private var grpBACKGROUND:FlxTypedGroup<FlxSprite>;

	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	private var camHUD:FlxCamera;

	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		curTrophySelect = false;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		Conductor.changeBPM(120);
		persistentUpdate = true;

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		defaultCamZoom = 0.80;

		var yScroll:Float = Math.max(0.12 - (0.02 * (optionShit.length - 2.5)), 0.1);

		if (MainMenuState.cursed)
			modificationString = " | YOU CAN'T RUN.";
		else
			modificationString = " modified by Uniimations";

		cheesePats = 0;

		// BACKGROUND VARIABLES

		// OFFSETS
		/*
		var offsetsTxt;
		var file:String = ('assets/images/mainmenu/menuOffsets.txt'); // txt for arsen offsets
		if (OpenFlAssets.exists(file))
		{
			offsetsTxt = CoolUtil.coolTextFile(file);

			for (i in 0...offsetsTxt.length)
				{
					CoolUtil.spriteOffsets.push(Std.parseFloat(offsetsTxt[i]));
				}
			trace('loaded main menu offset txt');
		}
		else // crash prevention
		{
			CoolUtil.spriteOffsets = [
				['Empty String'],
				[0],
				[0]
			];
			trace('failed to load txt file');
			trace('all offsets set to 0, 0');
		}
		*/

		//WallGroup = new FlxTypedGroup<FlxSprite>();

		wallBack = new FlxSprite(0, 0);
		wallBack.loadGraphic(Paths.image('mainmenu/wall_back'));
		wallBack.scrollFactor.set(0, yScroll);
		wallBack.antialiasing = ClientPrefs.globalAntialiasing;
		if (!MainMenuState.cursed)
			add(wallBack);

		//cheeseScrunkly = new FlxSprite(CoolUtil.spriteOffsets[1], CoolUtil.spriteOffsets[2]);
		cheeseScrunkly = new FlxSprite(402, 392); //adjusted offsets a TAAAAD bit
		cheeseScrunkly.frames = Paths.getSparrowAtlas('mainmenu/cheese_head');
		cheeseScrunkly.scrollFactor.set(0, yScroll);

		// ADD CHEESE ANIMS
		cheeseScrunkly.animation.addByPrefix('intro', 'cheese head intro', 24, false);
		cheeseScrunkly.animation.addByPrefix('idleLoop', 'cheese head loop idle', true);
		cheeseScrunkly.animation.addByPrefix('headpat', 'cheese head petting0', 24, false);
		cheeseScrunkly.animation.addByPrefix('headpatScary', 'JUMPSCARE', 24, true);

		cheeseScrunkly.alpha = 0;
		cheeseScrunkly.antialiasing = ClientPrefs.globalAntialiasing;
		cheeseScrunkly.updateHitbox();
		add(cheeseScrunkly);

		wallGlow = new FlxSprite(0, 0);
		wallGlow.loadGraphic(Paths.image('mainmenu/glow_effect'));
		wallGlow.antialiasing = ClientPrefs.globalAntialiasing;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length) //woa this is long
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			if (FlxG.save.data.beatCulturedWeek == false && optionShit[i] == 'freeplay')
			{
				menuItem.animation.addByPrefix('idle', "LOCKED freeplay", 24);
				menuItem.animation.addByPrefix('selected', "LOCKED freeplay", 24);
			}
			else
			{
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			}
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
			menuItem.cameras = [camHUD];
		}

		trophy = new FlxSprite(10, -10);
		trophy.frames = Paths.getSparrowAtlas('mainmenu/TROPHY_GLOWY');
		trophy.animation.addByIndices('unselected', "unselected trophy", [0], '', 0, false);
		trophy.animation.addByPrefix('selectOPEN', "select trophy", 24, false);
		trophy.animation.addByIndices('selected', "trophy", [0], '', 0, false);
		trophy.animation.play('unselected');
		trophy.scrollFactor.set(0, 0);
		trophy.antialiasing = ClientPrefs.globalAntialiasing;
		trophy.updateHitbox();
		add(trophy);

		FlxG.camera.follow(camFollowPos, null, 1);
		FlxG.camera.zoom = defaultCamZoom;
		//MENU ITEM ZOOM
		camHUD.zoom -= 0.25;

		versionShit = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion + modificationString, 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.borderSize = 1.25;
		versionShit.alpha = 0;
		add(versionShit);

		//VERSION NUMBER
		CheeseVersionShit = new FlxText(12, FlxG.height - 24, 0, "VS Cheese v" + cheeseVersion /*#if debug + " Headpats: " + cheesePats #end*/, 12);
		CheeseVersionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		CheeseVersionShit.borderSize = 1.25;
		CheeseVersionShit.alpha = 0;
		add(CheeseVersionShit);

		versionShit.cameras = [camAchievement];
		CheeseVersionShit.cameras = [camAchievement];

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0;
			spr.y -= 180;
		});

		// adjust zoom tween
		new FlxTimer().start(0.25, function(tmr: FlxTimer)
		{
			if (!MainMenuState.cursed)
				defaultCamZoom = 1.12;
		});

		// tween shit after loading (i hope)
		new FlxTimer().start(0.56, function(tmr: FlxTimer)
		{
			cheeseScrunkly.alpha = 1;
			if (MainMenuState.cursed)
				cheeseScrunkly.animation.play('headpatScary', true);
			else
				cheeseScrunkly.animation.play('intro', true);

			menuItems.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 1}, 0.5, {
					ease: FlxEase.quadOut,
				});
			});

			if (versionShit != null && versionShit.alpha != 1)
			{
				PlayState.phillyBlackTween = FlxTween.tween(versionShit, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween) {
						PlayState.phillyBlackTween = null;
					}
				});
			}

			if (CheeseVersionShit != null && CheeseVersionShit.alpha != 1)
			{
				PlayState.phillyBlackTween = FlxTween.tween(CheeseVersionShit, {alpha: 1}, 0.5, {ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween) {
						PlayState.phillyBlackTween = null;
					}
				});
			}
		});

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveFridayAchievement();
			}
		}
		#end

		super.create();

		FlxG.mouse.visible = true;
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveFridayAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('ITS FUCKING FRIDAY BITCHES WOOOOOO!');
	}

	function giveScrunklyAchievement() {
		add(new AchievementObject('scrunkly', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('double tap if youd scrunkly the when :pleading_face:');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F11)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		trophyFloat += 0.05;

		//SET CAM ZOOM
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		//SET CAM POSITION
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		//CHEESE HEAD PAT STUFF

		if (!MainMenuState.cursed && FlxG.mouse.overlaps(cheeseScrunkly) && FlxG.mouse.pressed)
        {
			if (FlxG.save.data.petCheese)
			{
				if (FlxG.random.bool(1))
				{
					trace('1% chance easter egg');
					trace('you are now cursed.');
					MainMenuState.cursed = true;
					if (MainMenuState.cursed) {
						cheeseScrunkly.animation.play('headpatScary', true);
						FlxG.sound.music.fadeOut(1.5, 0);

						new FlxTimer().start(0.30, function(tmr: FlxTimer)
						{
							// STUFF
							defaultCamZoom = 0.80;
							FlxG.sound.playMusic(Paths.music('freakyMenuDisturbing'), 0);
							FlxG.sound.music.fadeIn(6, 0, 0.8);

							// TWEENS
							FlxTween.tween(wallBack, {alpha: 0}, 2, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									wallBack.kill();
								}
							});
						});
					}
				}
				else
				{
					//trace('easter egg passed!');
					//trace('you\'re temporarily safe!');
					if (!MainMenuState.cursed)
						cheeseScrunkly.animation.play('headpat', true);
				}
			}
			else
			{
				cheeseScrunkly.animation.play('headpat', true);
				if (FlxG.save.data.petCheese == null || FlxG.save.data.petCheese == false) {
					FlxG.save.data.petCheese = true;
					trace('you pet cheese, you risk being cursed!');
				}
			}
			curTrophySelect = false;

			var daChoice:String = optionShit[curSelected];
			switch (daChoice)
			{
				case 'story_mode':
					changeItem(-1);
				case 'freeplay':
					changeItem(2);
				case 'credits':
					changeItem(1);
				default:
					//FlxG.sound.play(Paths.sound('fnafNoseHonk'));
			}

			//cheesePats++;
        }

		//FlxG.sound.play(Paths.sound('scrollMenu'));

		//plays honk if youre not cursed :)
		if (!MainMenuState.cursed && FlxG.mouse.overlaps(cheeseScrunkly) && FlxG.mouse.justReleased) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			FlxG.sound.play(Paths.sound('fnafNoseHonk'));

			// GIVES ACHIEVEMENT
			#if ACHIEVEMENTS_ALLOWED
			Achievements.loadAchievements();
			var achieveID:Int = Achievements.getAchievementIndex('scrunkly');

			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveScrunklyAchievement();
			}
			#end
		}

		// MENU SELECTING INTERACTION
		if (!selectedSomethin)
		{
			changeItem(0);
			if (curTrophySelect == true)
			{
				changeItem(0);
			}

			if (controls.UI_UP_P)
			{
				if (curTrophySelect == false)
				{
					if (FlxG.save.data.beatCulturedWeek == false && optionShit[curSelected] == 'credits')
					{
						changeItem(-2);
					}
					else
					{
						changeItem(-1);
					}
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}

			if (controls.UI_DOWN_P)
			{
				if (curTrophySelect == false)
				{
					if (FlxG.save.data.beatCulturedWeek == false && optionShit[curSelected] == 'story_mode')
					{
						changeItem(2);
					}
					else
					{
						changeItem(1);
					}
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (curTrophySelect == false)
				{
					curTrophySelect = true;
				}
				else
				{
					curTrophySelect = false;
				}
			}

			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				if (curTrophySelect == false)
				{
					curTrophySelect = true;
				}
				else
				{
					curTrophySelect = false;
				}
			}

			if (controls.BACK)
			{
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				PressACCEPT();
			}
		}

		checkAnimFinish(cheeseScrunkly, 'intro', 'idleLoop');
		checkAnimFinish(cheeseScrunkly, 'headpat', 'idleLoop');
		//checkAnimFinish(trophy, 'selectOPEN', 'selected');

		if (trophy.animation.curAnim != null)
		{
			if (trophy.animation.curAnim.name == 'selectOPEN' && trophy.animation.curAnim.finished)
			{
				new FlxTimer().start(0.2, function(tmr: FlxTimer)
				{
					trophy.animation.play('selected', true);
				});
			}
		}
		super.update(elapsed);

		// POSITIONING OF MENU ITEMS
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			//spr.x += 250;
		});
		trophy.y += Math.sin(trophyFloat);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curTrophySelect == false)
		{
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		else
		{
			curSelected = menuItems.length + 1;
		}

		if (curTrophySelect == true)
		{
			trophy.animation.play('selected');
		}
		else
		{
			trophy.animation.play('unselected');
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}

	private function PressACCEPT():Void
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		FlxG.mouse.visible = false;
		selectedSomethin = true;

		//idk lol
		FlxTween.tween(FlxG.camera, { zoom: 5}, 0.9, { ease: FlxEase.expoIn });
		FlxTween.tween(wallBack, { angle: 50}, 0.9, { ease: FlxEase.expoIn });
		//FlxTween.tween(FlxG.camera, { zoom: 5}, 3, { ease: FlxEase.expoInOut });

		if (curTrophySelect)
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
				FlxFlicker.flicker(trophy, 0.76, 0.06, false, false, function(flick:FlxFlicker)
				{
					MusicBeatState.switchState(new AchievementsMenuState());
				});
				if (versionShit != null && versionShit.alpha != 0)
				{
					PlayState.phillyBlackTween = FlxTween.tween(versionShit, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween) {
							PlayState.phillyBlackTween = null;
						}
					});
				}
				if (CheeseVersionShit != null && CheeseVersionShit.alpha != 0)
				{
					PlayState.phillyBlackTween = FlxTween.tween(CheeseVersionShit, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween) {
							PlayState.phillyBlackTween = null;
						}
					});
				}
			});
		}
		else
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					//FlxTween.tween(FlxG.camera, { angle: 40}, 3, { ease: FlxEase.expoInOut });
					FlxFlicker.flicker(spr, 0.76, 0.06, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[curSelected];

						switch (daChoice)
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
						}
					});
				}
				if (versionShit != null && versionShit.alpha != 0)
				{
					PlayState.phillyBlackTween = FlxTween.tween(versionShit, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween) {
							PlayState.phillyBlackTween = null;
						}
					});
				}
				if (CheeseVersionShit != null && CheeseVersionShit.alpha != 0)
				{
					PlayState.phillyBlackTween = FlxTween.tween(CheeseVersionShit, {alpha: 0}, 0.4, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween) {
							PlayState.phillyBlackTween = null;
						}
					});
				}
			});
		}
	}

	/*
	* NO BEAT HIT FUNCTION!
	override function beatHit()
	{
		super.beatHit();

		if (FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.030;
		}
	}
	*/
}
