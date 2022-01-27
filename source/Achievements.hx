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
		//Name, 						 Description, 			 							 Achievement save tag, 	 Hide?

		["Freaky on a Friday Night",	"Play on a Friday... Night.",						'friday_night_play',	 true],

		// VS CHEESE ACHIEVEMENTS

		["Back to the Basics",			"Beat Tutorial and unlock the rest of the game.",	'tutorial_beat', 		false],
		["Are You Cultured?", 			"Beat Week 1 on HARD.",								'week1_beat', 			false],
		["A Prequel?",					"Beat Week 2 on HARD.",								'week2_beat',			false],
		["The Boyz",					"Sing with Unii and get the good ending to Week 2",	'dynamic_duo',			false],
		["Something's Missing...",		"Say no to Unii and get the bad ending to Week 2.",	'below_zero',			false],
		// VIP DIFFICULTY
		["Freestyle Time!", 			"Beat Restaurante on VIP difficulty",				'restaurante_ex',		false],
		["Let's Change It Up!", 		"Beat Milkshake on VIP difficulty.",				'milkshake_ex',		 	false],
		["You're Not Cultured Yet!",	"Beat Cultured on VIP difficulty.", 				'cultured_ex',			false],
		["Feeling the Swing", 			"Beat Mozzarella on HARD.",							'bnb_beat',				false],
		// EXTRA ACHIEVEMENTS
		["Megalomaniac", 				"Beat Manager Strike Back without Pussy Mode.",		'beat_chara',			 true],
		["Let It Go",	 				"Beat Frosted without Pussy Mode.",					'beat_sans',			 true],

		["Dirty Cheater...",
		"You cheated not only the game, but yourself. You didn't grow. You didn't improve. You took a shortcut and gained nothing.
		You experienced a hollow victory. Nothing was risked and nothing was gained. It's sad that you don't know the difference.",
		'beat_onion', true],

		["awww the scrunkly",			"Headpat Cheese on the Main Menu.",					'scrunkly',				false],
		["Evil woops",					"Don't skip dialogue AT ALL in any way.",			'evil_woops',			 true],

		// OG RENAMED

		["L + Ratio",					"Complete a Song with a rating lower than 20%.",	'ur_bad',				false],
		["Marvelous",					"Complete a Song with a rating of 100%.",			'ur_good',				false],

		["Long And Hard",
		"Hold down a note for at least 5 seconds.\nThe name? don't know what you mean",
		'oversinging', false],

		["SCP-173",						"Don't blink.\n(Finish a Song without going Idle.)",'hype',					false],
		["Dynamic Duo",					"Finish a Song pressing only two keys.",			'two_keys',				false],
		["Mac User",					"Have you tried to run the game on a toaster?",		'toastie',				false]
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
