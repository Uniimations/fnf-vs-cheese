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
import Achievements;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.3.2'; //This is also used for Discord RPC
	public static var cheeseVersion:String = '1.2.0'; //VERSION NUMBER FOR VS CHEESE ONLY CHANGE WHEN NEEDED/UPDATED 
	//note: first version was 1.1.0 and im making it 2.0 since this is an overhaul of everything
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', 'options'];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var targetX:Int;
	public static var prevCharacter:Int = 99;
	private var character:Character = null;

	var bounce:Bool = false;
	var counter:FlxSprite;

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

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		var random = FlxG.random.int(0,2);
		if (random == prevCharacter) {
			random++;
			if (random > 2) 
				random = 0;
		}

		//RANDOM CHARACTER GENERATOR
		switch (random) {
			//placeholder for the new menu
			case 0:
				character = new Character(-86, 10, 'bluecheese', false);
			case 1:
				character = new Character(-86, 10, 'bluecheese', false);
			case 2:
				character = new Character(-86, 10, 'bluecheese', false);
		}
		prevCharacter = random;
		character.debugMode = true;
		character.scale.set(0.8, 0.8);
		character.scrollFactor.set(0, yScroll);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/menu_bg'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var wall:FlxSprite = new FlxSprite(-80, 0);
		wall.frames = Paths.getSparrowAtlas('mainmenu/wall_menu');
		wall.scrollFactor.set(0, yScroll);
		wall.animation.addByPrefix('smoke', "wall menu", 24);
		wall.setGraphicSize(Std.int(bg.width * 1.175));
		wall.updateHitbox();
		wall.screenCenter();
		wall.antialiasing = ClientPrefs.globalAntialiasing;
		add(wall);
		wall.animation.play('smoke');
		add(character);

		counter = new FlxSprite(-80, 0);
		counter.frames = Paths.getSparrowAtlas('mainmenu/counter_menu');
		counter.scrollFactor.set(0, yScroll);
		counter.animation.addByIndices('bouncy', 'counter menu', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13], "", 24, false);
		counter.setGraphicSize(Std.int(bg.width * 1.175));
		counter.updateHitbox();
		counter.screenCenter();
		counter.antialiasing = ClientPrefs.globalAntialiasing;
		add(counter);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
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
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		//VERSION NUMBER
		//if youre gonna do this actually make a string at the top instead of what i did
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "VS Cheese v" + cheeseVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

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

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

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
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

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
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
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
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
			spr.x += 250;
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
	}

	override function beatHit()
	{
		super.beatHit();

		counter.animation.play('bouncy', true);

		character.animation.play('idle', true);
	}
}
