package;

import flixel.util.FlxTimer;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var wholeAssCreditList:Array<Dynamic> = [ // LAYOUT: Name, Icon name, "Quote"\nDescription, Link
		['We did a lot'],
		['Uniimations', 		'unii', 			'"I did literally everything"\nSprite Artist, Graphic Designer, Animation, Music, Charting, Programming, Story, Writing, Voice Clips, Voice Acting',			'https://twitter.com/UniiAnimates'],
		['potionion', 			'potionion', 		'"God I love Thorns."\nBackground Arist, Resprite Artist, "Perfect" pop up Artist, Character Design & Concept Art', 											'https://twitter.com/Potionion'],
		['Avinera', 			'avinera', 			'"Aside from my huge c**ck, I\'m just an ordinary girl!"\nComposed Manager Strike Back & Frosted, Writing, Concepts/Ideas, Voice clips, Voice acting', 			'https://youtube.com/avinera'],
		[''],
		['Extra Charters'],
		['dude0216', 			'dude0216', 		'"fefe"\nCultured Hard difficulty chart', 			'https://www.youtube.com/channel/UCiGJubAsma0AWVozQUIoCJA'],
		['Cerbera', 			'cerbera', 			'"swag"\nCultured EX difficulty chart', 			'https://www.youtube.com/c/Cerberaa'],
		[''],
		['Voice Actors'],
		['BlueCheese', 			'bluecheese', 		'"Comedy skit!"\nWeek 1 Writing, Voice Clips, Voice acting\n& Character Design', 				'https://youtube.com/bluecheese'],
		['OiSuzuki', 			'oisuzuki', 		'"I hate Friday Night Funkin."\nVoice Clips, Voice acting', 									'https://www.youtube.com/channel/UCA538hKV5s9cXhzW36rXsnw'],
		['Dansilot', 			'dansilot', 		'"Las Vegas."\nVoice Clips, Voice acting', 														'https://www.youtube.com/channel/UC8tNRrCufSfWP1tXDL5wYLQ'],
		['Arsen Infinity', 		'arsen', 			'"I\'M LAGGING!"\nVoice Clips, Voice acting', 													'https://www.youtube.com/c/Arsen_Infinity'],
		[''],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_'],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/RiverOaken'],
		[''],
		['People I stole from'],
		['Verwex',				'verwex',			'Music Disc assets and some of\nthe Mic\'d Up Engine features',				'https://twitter.com/Vershift'],
		['Kade Dev',			'kade',				'Some of the Kade Engine features',											'https://www.youtube.com/c/KadeDev'],
		['Yoshubs',				'shubs',			'New Input System Programmer',												'https://twitter.com/yoshubs'],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension\nfor Windows',									'https://twitter.com/polybiusproxy'],
		['GWebDev', 			'gwebdev', 			'.WebM Video Loader Extension\nfor Mac',									'https://github.com/GrowtopiaFli']
	];

	var bgBack:FlxSprite;
	var bg:FlxSprite;
	var blackBar:FlxSprite;
	var descBox:FlxSprite;
	var descText:FlxText;
	var arrowSpr:FlxSprite;

	var FlxGHeightDivided:Int = Math.round(FlxG.height / 2);
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bgBack = new FlxSprite().loadGraphic(Paths.image('credits/menuCredits'));
		bgBack.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgBack);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.5;
		add(bg);

		blackBar = new FlxSprite().makeGraphic(FlxG.width, FlxG.height - FlxGHeightDivided, FlxColor.BLACK);
		blackBar.screenCenter(Y);

		descBox = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		descBox.y += 585;
		descBox.alpha = 0.5;

		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		for (i in 0...wholeAssCreditList.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:AlphabetWhite = new AlphabetWhite(0, 70 * i, wholeAssCreditList[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite;
				icon = new AttachedSprite('credits/icons/' + wholeAssCreditList[i][1]);

				icon.yAdd = 25;
				icon.xAdd = optionText.width + 15;
				icon.sprTracker = optionText;

				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descBox);
		add(descText);

		// OFFSETS
		/*
		var offsetsTxt;
		var file:String = ('assets/images/credits/arrowButtonOffsets.txt'); // txt for arsen offsets

		offsetsTxt = CoolUtil.coolTextFile(file);
		for (i in 0...offsetsTxt.length)
			{
				CoolUtil.spriteOffsets.push(Std.parseFloat(offsetsTxt[i]));
			}
		trace('loaded main arrowButton offset txt');
		*/

		arrowSpr = new FlxSprite(40, 260);
		arrowSpr.frames = Paths.getSparrowAtlas('credits/arrowButton');
		arrowSpr.animation.addByPrefix('intro', 'intro arrow', 24, false);
		arrowSpr.animation.addByIndices('normal', 'arrow', [0], '', 0, true);
		arrowSpr.animation.addByIndices('pressed', 'press arrow', [0], '', 0, true);

		arrowSpr.antialiasing = ClientPrefs.globalAntialiasing;
		arrowSpr.scrollFactor.set();
		arrowSpr.updateHitbox();
		arrowSpr.alpha = 0;
		add(arrowSpr);

		new FlxTimer().start(0.5, function(tmr: FlxTimer)
		{
			arrowSpr.alpha = 1;
			if (arrowSpr.alpha == 1)
				arrowSpr.animation.play('intro');
		});

		changeSelection();
		super.create();
	}

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

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			arrowSpr.animation.play('pressed');
			new FlxTimer().start(0.3, function(tmr: FlxTimer)
			{
				CoolUtil.browserLoad(wholeAssCreditList[curSelected][3]);
			});
		}

		checkAnimFinish(arrowSpr, 'intro', 'normal');
		checkAnimFinish(arrowSpr, 'pressed', 'normal');
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = wholeAssCreditList.length - 1;
			if (curSelected >= wholeAssCreditList.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.3;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = wholeAssCreditList[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return wholeAssCreditList[num].length <= 1;
	}
}
