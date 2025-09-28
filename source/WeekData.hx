package;

class WeekData {
	#if web
	public static var songsNames:Array<Dynamic> = [
		['Kbhgames'],
		['Kbhgames', 'Kbhgames', 'Kbhgames'],
		['Kbhgames', 'Kbhgames'],
		['Kbhgames'],
		['Kbhgames']
	];
	#else
	public static var songsNames:Array<Dynamic> = [
		['Tutorial'],
		['Restaurante', 'Milkshake', 'Cultured'],
		['Wi-Fi', 'Casual-Duel', '???'],
		['Manager-Strike-Back']
		#if PLAYTEST_BUILD
		,['UNLOCK', 'ALL', 'SONGS'],
		['LOCK', 'ALL', 'SONGS']
		#end
	];
	#end

	//seperate names for bonus tracks
	public static var bonusNames:Array<Dynamic> = [
		['Frosted', 'Alter-Ego']
	];

	// Custom week number, used for your week's score not being overwritten by a new vanilla week when the game updates
	// I'd recommend setting your week as -99 or something that new vanilla weeks will probably never ever use
	// null = Don't change week number, it follows the vanilla weeks number order
	public static var weekNumber:Array<Dynamic> = [
		null,	//Tutorial
		null,	//Week 1
		null,	//Week 2
		null	//Manager Strike Back
		#if PLAYTEST_BUILD
		,null,
		null
		#end
	];

	public static var loadDirectory:Array<String> = [
		null,   //Tutorial
		null,	//Week 1
		null,	//Week 2
		null	//Manager Strike Back
		#if PLAYTEST_BUILD
		,null,
		null
		#end
	];

	//The only use for this is to display a different name for the Week when you're on the score reset menu.
	//Set it to null to make the Week be automatically called "Week (Number)"

	//Edit: This now also messes with Discord Rich Presence, so it's kind of relevant.
	public static var weekResetName:Array<String> = [
		"Tutorial",
		null,	//Week 1
		null,	//Week 2
		"Bonus Week"
		#if PLAYTEST_BUILD
		,"stop pressing the r button", //ur not supposed to be able to play this loloololl
		"stop pressing the r button"   //ur not supposed to be able to play this loloololl
		#end
	];


	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getCurrentWeekNumber():Int {
		return getWeekNumber(PlayState.storyWeek);
	}

	public static function getWeekNumber(num:Int):Int {
		var value:Int = 0;
		if(num < weekNumber.length) {
			value = num;
			if(weekNumber[num] != null) {
				value = weekNumber[num];
				//trace('Cur value: ' + value);
			}
		}
		return value;
	}

	//Used on LoadingState, nothing really too relevant
	public static function getWeekDirectory():String {
		var value:String = loadDirectory[PlayState.storyWeek];
		if(value == null) {
			value = "week" + getCurrentWeekNumber();
		}
		return value;
	}
}