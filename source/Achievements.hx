import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class Achievements
{
	// for achievements
	public static var achievementsStuff:Array<Dynamic> = [
		//Name, 						 Description, 			 																	 Achievement save tag, 	 Hide?

		["Freaky on a Friday Night",	"Play on a Friday Night.",																	'friday_night_play',	 true],
		["Back To The Basics",			"Beat the Tutorial.",																		'tutorial_beat', 		false],

		// WEEKS
		["Are You Cultured?", 			"Beat Week 1 on HARD.",																		'week1_beat', 			false],
		["A Prequel?",					"Beat Week 2 on HARD.",																		'week2_beat',			false],
		["The Boyz",					"Sing with Unii and get the canon ending \nto Week 2",										'dynamic_duo',			false],
		["Something's Missing...",		"Say no to Unii and get the alternate\nending to Week 2.",									'below_zero',			false],

		// VIP DIFFICULTY
		["Freestyle Time!", 			"Beat Restaurante on VIP difficulty.",														'restaurante_ex',		false],
		["Let's Change It Up!", 		"Beat Milkshake on VIP difficulty.",														'milkshake_ex',		 	false],
		["You're Not Cultured Yet!",	"Beat Cultured on VIP difficulty.", 														'cultured_ex',			false],

		// EXTRA ACHIEVEMENTS
		["Afterparty",					"Beat all Bonus Songs and VIP remixes.",													'beat_bonus',			false],
		["Megalomaniac", 				"Beat Manager Strike Back with mechanics on.",												'beat_chara',			 true],
		["Let It Go",	 				"Beat Frosted with mechanics on.",															'beat_sans',			 true],
		["Mania",	 					"Beat Alter Ego with mechanics on.",														'beat_unii',			 true],

		["Fucking Cheater...",  		UniiStringTools.potionionsMessage(), 														'beat_onion', 			 true], //made cleaner, look in UniiStringTools.hx for info!

		["Cerbera",						"Place a note in the Chart Editor.",														'charter', 				false],
		["awww the scrunkly <3",		"Headpat Cheese on the Main Menu.",															'scrunkly',				false], //i added a heart here fuck u lol it looks cute <33
		["Loremaster",					"You're a fucking streamer aren't you?!\nDon't skip dialogue AT ALL in any way.",			'evil_woops',			false],

		// OG RENAMED

		["L + Ratio",					"Beat a Song with less than 20% accuracy.",													'ur_bad',				false],
		["Marvelous",					"Beat a Song with a Full Combo with a 100% PFC.",											'ur_good',				false],
		["Long And Hard", 				"Hold down a note for at least 5 seconds. \nThe name? don't know what you mean...", 		'oversinging', 			false],
		["SCP-173",						"Don't blink.\n(Finish a Song without going Idle.)",										'hype',					false],
		["Dynamic Duo",					"Finish a Song pressing only two keys.",													'two_keys',				false],
		["Mac User",					"Have you tried to run the game on a toaster?",												'toastie',				false],

		// SECRET
		["Ghostly Articulation", 		"HEY GUYSITS ME GHOST ORU! THE REAL ONE! IM REAL!",											'beat_ghost',			 true],
		["Hacker",						"01100011 01100001 01101101 01100101 01101111", 											'beat_diples', 			 true],
		["Lung Failure", 				"This meme isn't fucking funny anymore.",													'beat_ralsei',			 true]
	];

	// for unlocks/notifications
	public static var notifStuff:Array<Dynamic> = [
		//Header, 						 Subtitle,	 			 							 Save tag, 	 			Hide?
		["Psst...", 					"You unlocked Week 1 in Story Mode!",				'unlock_week1',			true],
		["Psst...", 					"You unlocked VIP difficulty in Freeplay!",			'unlock_ex',			true],
		["Psst...", 					"You unlocked Week 2 in Story Mode!",				'unlock_week2',			true],
		["Psst...", 					"You unlocked BONUS CONTENT in Story Mode!",		'unlock_bonus',			true],
		["Psst...", 					"You unlocked BONUS SONGS in Freeplay!",			'unlock_endgame',		true],
	];

	public static var achievementsMap:Map<String, Bool> = new Map<String, Bool>();

	public static function unlockAchievement(name:String):Void {
		FlxG.log.add('Completed achievement "' + name +'"');
		achievementsMap.set(name, true);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	}

	public static function isAchievementUnlocked(name:String) {
		if(achievementsMap.exists(name) && achievementsMap.get(name)) {
			return true;
		}
		return false;
	}

	public static function getAchievementIndex(name:String, ?type:String = 'achievement') {
		var typeList:Array<Dynamic> = [];

		switch (type)
		{
			case 'achievement':
				typeList = achievementsStuff;
			case 'notification':
				typeList = notifStuff;
		}

		for (i in 0...typeList.length) {
			if(typeList[i][2] == name) {
				return i;
			}
		}
		return -1;
	}

	public static function loadAchievements():Void {
		if(FlxG.save.data.achievementsMap != null) {
			achievementsMap = FlxG.save.data.achievementsMap;
		}
		if(FlxG.save.data.achievementsUnlocked != null) {
			FlxG.log.add("Trying to load stuff");
			var savedStuff:Array<String> = FlxG.save.data.achievementsUnlocked;
			for (i in 0...savedStuff.length) {
				achievementsMap.set(savedStuff[i], true);
			}
		}

		// DOESNT SAVE UNNECECARY STUFF >:(
	}
}
