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
	public static var psychEngineVersion:String = '0.3.2'; //This is also used for Discord RPC
	public static var cheeseVersion:String = '1.2.0'; //VERSION NUMBER FOR VS CHEESE ONLY CHANGE WHEN NEEDED/UPDATED
	public static var curSelected:Int = 0;
	public var defaultCamZoom:Float = 0.9;
	
	var CheeseVersionShit:FlxText;
	var versionShit:FlxText;

	var wallBack:FlxSprite;
	var wallGlow:FlxSprite;
	var cheeseScrunkly:FlxSprite;
	private var grpBACKGROUND:FlxTypedGroup<FlxSprite>;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	private var camHUD:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', 'options'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		Conductor.changeBPM(120);
		persistentUpdate = true;
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

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
		add(wallBack);

		//cheeseScrunkly = new FlxSprite(CoolUtil.spriteOffsets[1], CoolUtil.spriteOffsets[2]);
		cheeseScrunkly = new FlxSprite(410, 400);
		cheeseScrunkly.frames = Paths.getSparrowAtlas('mainmenu/cheese_head');
		cheeseScrunkly.scrollFactor.set(0, yScroll);

		// ADD CHEESE ANIMS
		cheeseScrunkly.animation.addByPrefix('intro', 'cheese head intro', 24, false);
		cheeseScrunkly.animation.addByPrefix('idleLoop', 'cheese head loop idle', true);
		cheeseScrunkly.animation.addByPrefix('headpat', 'cheese head petting0', 24, false);
		cheeseScrunkly.animation.addByPrefix('headpatScary', 'cheese head petting jumpscare0', 24, false);

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
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
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

		FlxG.camera.follow(camFollowPos, null, 1);
		FlxG.camera.zoom = defaultCamZoom;
		//MENU ITEM ZOOM
		camHUD.zoom -= 0.25;

		versionShit = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion + " modified by Uniimations", 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.borderSize = 1.25;
		versionShit.alpha = 0;
		add(versionShit);

		//VERSION NUMBER
		CheeseVersionShit = new FlxText(12, FlxG.height - 24, 0, "VS Cheese v" + cheeseVersion, 12);
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

		new FlxTimer().start(0.25, function(tmr: FlxTimer)
		{
			defaultCamZoom = 1.12;
		});

		//plays after loading (i hope)
		new FlxTimer().start(0.55, function(tmr: FlxTimer)
		{
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
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		super.create();

		FlxG.mouse.visible = true;
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
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

		//SET CAMZOOM
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		var jumpscareChance:Int;
		jumpscareChance = FlxG.random.int(1, 10);

		if (FlxG.mouse.overlaps(cheeseScrunkly) && FlxG.mouse.pressed)
        {
            if (jumpscareChance == 1)
				cheeseScrunkly.animation.play('headpatScary', true);
			else
				cheeseScrunkly.animation.play('headpat', true);
        }

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxG.mouse.visible = false;
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				//FlxTween.tween(FlxG.camera, { zoom: 5}, 3, { ease: FlxEase.expoInOut });

				menuItems.forEach(function(spr:FlxSprite)
				{
					//idk lol
					FlxTween.tween(FlxG.camera, { zoom: 5}, 0.9, { ease: FlxEase.expoIn });
					FlxTween.tween(wallBack, { angle: 50}, 0.9, { ease: FlxEase.expoIn });
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
						FlxFlicker.flicker(spr, 0.85, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story_mode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());
								case 'awards':
									MusicBeatState.switchState(new AchievementsMenuState());
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

		if (cheeseScrunkly.animation.curAnim != null)
		{
			if (cheeseScrunkly.animation.curAnim.name == 'intro' && cheeseScrunkly.animation.curAnim.finished || cheeseScrunkly.animation.curAnim.name == 'headpat' && cheeseScrunkly.animation.curAnim.finished || 
			cheeseScrunkly.animation.curAnim.name == 'headpatScary' && cheeseScrunkly.animation.curAnim.finished)
			{
				cheeseScrunkly.animation.play('idleLoop');
			}
		}

		super.update(elapsed);

		// POSITIONING OF MENU ITEMS
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			//spr.x += 250;
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

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

		FlxG.camera.zoom += 0.030;
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
