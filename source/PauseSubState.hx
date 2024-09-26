package;

import PlayState.PlayState;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.graphics.FlxGraphic;
import Controls;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = [];
	var menuItemsPRESSED:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var warningText:FlxText;

	var bg:FlxSprite;
	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var blueballedTxt:FlxText;
	var songText:Alphabet;

	var canDoStuff:Bool = true;
	var loaded:Bool = false;

	public var char:Character;
	public var randomChance:Int = 0;
	public var startNum:Int = 0;
	public var endNum:Int = 2;

	public var isBFchar:Bool = false;
	public var hasNoPoses:Bool = false;
	public var hasTwoDances:Bool = false;

	public static var psChartingMode:Bool = false;
	public static var pauseSong:String;

	public function new(x:Float, y:Float)
	{
		super();

		menuItemsOG = ['Resume', 'Restart Song', 'Options',#if PLAYTEST_BUILD 'Toggle Cheats', #end 'Exit to menu'];
		menuItemsPRESSED = ['Resume ', 'Restart Song', 'Options',#if PLAYTEST_BUILD 'Toggle Cheats', #end 'Exit to menu']; //extra space on 'Resume' for bug fix

		menuItems = menuItemsOG;
		canDoStuff = true;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'below-zero' | 'frosted':
				pauseSong = 'avi.';
			case 'above-zero':
				pauseSong = 'afternoon';
			default:
				pauseSong = 'distant';
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseSong), true, true);
		pauseMusic.play(true);

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);
		bg.alpha = 0.8;

		canDoStuff = true;
		loaded = false;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'tutorial' | 'manager-strike-back':
				endNum = 1;
			case 'mozzarella':
				endNum = 4;
			case 'frosted':
				startNum = 1;
				endNum = 3;
			default:
				startNum = 0;
				endNum = 2;
		}

		randomChance = FlxG.random.int(startNum, endNum);

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'tutorial':
				switch (randomChance)
				{
					case 0:
						newCharacter(740, 340, "bluecheese", false, true);
					case 1:
						newCharacter(838, 320, "gf-oisuzuki-kitchen", false, true);
						hasTwoDances = true;
				}
			case 'restaurante' | 'milkshake' | 'cultured':
				if (CoolUtil.difficultyString() == 'VIP')
				{
					if (PlayState.SONG.song.toLowerCase() == 'cultured') {
						switch (randomChance)
						{
							case 0:
								newCharacter(740, 390, "vip-bluecheese", false, true);
							case 1:
								newCharacter(822, 420, "vip-bf", true);
							case 2:
								newCharacter(630, 150, "vip-gf-take-over");
								hasNoPoses = true;
								hasTwoDances = true;
						}
					} else {
						switch (randomChance)
						{
							case 0:
								newCharacter(740, 390, "vip-bluecheese", false, true);
							case 1:
								newCharacter(822, 420, "vip-bf", true);
							case 2:
								newCharacter(630, 150, "vip-gf");
								hasNoPoses = true;
								hasTwoDances = true;
						}
					}
				}
				else
				{
					switch (randomChance)
					{
						case 0:
							newCharacter(740, 340, "bluecheese", false, true);
						case 1:
							newCharacter(822, 420, "bf", true);
						case 2:
							newCharacter(630, 150, "gf");
							hasNoPoses = true;
							hasTwoDances = true;
					}
				}
			case 'wi-fi':
				switch (randomChance)
				{
					case 0:
						newCharacter(740, 340, "bluecheese", false, true);
					case 1:
						newCharacter(850, 165, "arsen", true);
					case 2:
						newCharacter(820, 320, "oisuzuki", false, true);
						hasNoPoses = true;
						hasTwoDances = true;
				}
			case 'casual-duel':
				switch (randomChance)
				{
					case 0:
						newCharacter(740, 340, "bluecheese", false, true);
					case 1:
						newCharacter(822, 173, "dansilot", true);
					case 2:
						newCharacter(820, 320, "oisuzuki", false, true);
						hasNoPoses = true;
						hasTwoDances = true;
				}
			case 'manager-strike-back':
				switch (randomChance)
				{
					case 0:
						newCharacter(753, 120, "undertale-oisuzuki", false, true);
					case 1:
						newCharacter(822, 420, "undertale-bf", true);
				}
			case 'frosted':
				switch (randomChance)
				{
					case 1:
						newCharacter(678, 112, "avinera-frosted-tape", false, true);
						hasNoPoses = true;
					case 2:
						newCharacter(822, 420, "bf", true);
					case 3:
						newCharacter(822, 173, "dansilot", true);
				}
			default:
				// Remove Unnesecary BF and GF there. GET EM OUTTA HERE BRAH!! HAHHA
				newCharacter(740, 340, "bluecheese", false, true);

				trace('missing song, default characters and chances.');
		}

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			songText = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.tweenType = "right trail";
			songText.targetY = i;
			songText.ID = i; //small fix for flash id's
			grpMenuShit.add(songText);
		}

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.displaySongName;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		blueballedTxt = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = "Deaths: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "YOU WILL NOW NEVER DIE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		warningText = new FlxText(20, FlxG.height - 40, 0, "WARNING: Changing options will restart the song for changes to take place.", 32);
		warningText.scrollFactor.set();
		warningText.setFormat(Paths.font('vcr.ttf'), 24);
		warningText.x = FlxG.width - (warningText.width + 20);
		warningText.updateHitbox();
		add(warningText);

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);
		warningText.x = FlxG.width - (warningText.width + 20);

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var pressedUp = controls.UI_UP_P;
		var pressedDown = controls.UI_DOWN_P;
		var pressedACCEPT = controls.ACCEPT;

		if (pressedUp && canDoStuff)
		{
			changeSelection(-1);
		}

		if (pressedDown && canDoStuff)
		{
			changeSelection(1);
		}

		if (pressedACCEPT && canDoStuff)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					canDoStuff = false;
					menuItems = menuItemsPRESSED;
					coolSound();
					flickerSelected();
					tweenMenuShit('back');

					new FlxTimer().start(1.1, function(tmr:FlxTimer) {
						close();
					});

					trace('shit goes flashy bro');

				case "Restart Song":
					canDoStuff = false;
					coolSound();
					flickerSelected();
					trace('RESTARTING SONG...');

					new FlxTimer().start(1.1, function(tmr:FlxTimer) {
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
					});

				case 'Options':
					canDoStuff = false;
					coolSound();
					flickerSelected();

					new FlxTimer().start(1.1, function(tmr:FlxTimer) {
						OptionsState.inPause = true;
						MusicBeatState.switchState(new OptionsState());
						FlxG.sound.playMusic(Paths.music(pauseSong));
					});

				case 'Toggle Cheats':
					canDoStuff = true;
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;

				case "Exit to menu":
					canDoStuff = false;
					coolSound();
					flickerSelected();

					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					new FlxTimer().start(1.1, function(tmr:FlxTimer) {
						if(PlayState.isStoryMode) {
							MusicBeatState.switchState(new StoryMenuState());
						} else {
							MusicBeatState.switchState(new FreeplayState());
						}
						FlxG.sound.playMusic(Paths.music('freaky_overture'));
					});

					MainMenuState.cursed = false; // makes you not cursed
					PauseSubState.psChartingMode = false;
			}
		}

		// checks if the first animation ended, then plays second animation on the crappy if statement

		if (!hasNoPoses && !hasTwoDances && canDoStuff) {
			UniiStringTools.checkAnimFinish(char, 'idle', 'idle');
		}

		if (hasTwoDances && canDoStuff) {
			UniiStringTools.checkAnimFinish(char, 'danceLeft', 'danceRight');
			UniiStringTools.checkAnimFinish(char, 'danceRight', 'danceLeft');
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.2;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}

	function regenMenu():Void
	{
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.tweenType = "left trail";
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}

	function coolSound():Void
	{
		if (!hasNoPoses) {
			if (char.animOffsets.exists('hey'))
				char.playAnim('hey', true);
			else if (!hasTwoDances)
				char.playAnim('idle', true);
		}

		FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);
	}

	function flickerSelected():Void
	{
		grpMenuShit.forEach(function(spr:Alphabet)
		{
			if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.5, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
			else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
						loaded = false;
						hasNoPoses = false;
					});
				}
		});
	}

	function tweenMenuShit(backOrIn:String) // this function is a weird string code name thing but i dont really care if its bad
	{
		if (loaded)
		{
			FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
			FlxTween.tween(char, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
			FlxTween.tween(levelInfo, {alpha: 0, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
			FlxTween.tween(levelDifficulty, {alpha: 0, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
			FlxTween.tween(blueballedTxt, {alpha: 0, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
			FlxTween.tween(warningText, {alpha: 0, y: warningText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		}
	}

	function newCharacter(posX:Float, posY:Float, charName:String, ?isBoyfriend:Bool = false, ?flipPosX:Bool = false)
	{
		if (isBoyfriend)
			char = new Boyfriend(posX, posY, charName);
		else
			char = new Character(posX, posY, charName);

		char.scale.set(1.1, 1.1);
		char.scrollFactor.set(0, 0);
		add(char);
		char.alpha = 0.8;

		if (flipPosX)
			char.flipX = true;
		else
			char.flipX = false;

		isBFchar = isBoyfriend;
		loaded = true;

		//trace(startNum + ' ,' + endNum);
		//trace('CHARACTER INFO: NAME: ' + charName + ' X: ' + posX + ' Y: ' + posY + ' FLIPPED: ' + flipPosX);
	}
}
