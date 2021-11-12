package;

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
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<AlphabetWhite>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		['Mod Creator'],
		['Uniimations', 'new/unii', '"I did literally everything"\nArt, Animation, Music, Charting, Programming, Story, Writing, Voice Clips, Voice Acting', 'https://youtube.com/uniimations', 0xFF32091F],
		[''],
		['Discord Server', 'discord', 'Join my discord server!\nI talk there a lot :]', 'https://discord.gg/gZYrEKbzCd', 0xFF080C1F],
		[''],
		['The Boyz'],
		['Avinera',	'new/avinera', '"uhuhuhuhuh sans uhuhuhuhuhuh"\nComposed Manager Strike Back, Voice clips, Voice acting, Character Design', 'https://youtube.com/avinera', 0xFF242833],
		['BlueCheese', 'new/cheese', '"There\'s a new Whitty video! oh fuck- there\'s a new Grian video!" Week 1 writing, Voice Clips, Voice acting, Character Design', 'https://youtube.com/bluecheese', 0xFF061730],
		['OiSuzuki', 'new/suzuki', '"I hate Friday Night Funkin."\nVoice Clips, Voice acting, Character Design', 'https://www.youtube.com/channel/UCA538hKV5s9cXhzW36rXsnw', 0xFF480D0D],
		['Dansilot', 'new/dani', '"Las Vegas."\nVoice Clips, Voice acting, Character Design', 'https://www.youtube.com/channel/UC8tNRrCufSfWP1tXDL5wYLQ', 0xFF480D0D],
		['Arsen Infinity', 'new/arsen', '"I\'M LAGGING!"\nVoice Clips, Voice acting, Character Design', 'https://www.youtube.com/c/Arsen_Infinity', 0xFF480D0D],
		[''],
		['Extra Credits'],
		['Potionion', 'new/potion', '"My gender is fuck you. My pronouns are fuck/off"\nBackground Artist', 'https://twitter.com/Potionion', 0xFF3D2B3C],
		['Joey Animations', 'new/joey', '"Look at that floor, oh my God it\'s so good"\nBackground Arist (floor!)', 'https://www.youtube.com/channel/UCRLsZwUPm7Ax4ZZ3lgM77Ng',	0xFF0A1127],
		//['Ash',	'new/ash', '"There are 3 modders I simp for, one of them is Unii"\nHelped me with programming.', 'https://twitter.com/ash__i_guess_',	0xFFFFFFFF],
		['dude0216', 'new/dude', '"fefe"\nmade Cultured rechart.', 'https://www.youtube.com/channel/UCiGJubAsma0AWVozQUIoCJA', 0xFF27073E],
		[''],
		/*['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',	0xFFFFDD33],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',		0xFFC30085],
		[''],
		['Special Thanks'],
		['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',			0xFFFFFFFF],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFF73838],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFFFBB1B],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFF53E52C],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFF6475F3]*/
	];

	var bgBack:FlxSprite;
	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bgBack = new FlxSprite().loadGraphic(Paths.image('menuCredits'));
		bgBack.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgBack);

		bg = new FlxSprite().loadGraphic(Paths.image('creditsOverlay'));
		add(bg);

		grpOptions = new FlxTypedGroup<AlphabetWhite>();
		add(grpOptions);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:AlphabetWhite = new AlphabetWhite(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
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
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
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
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
