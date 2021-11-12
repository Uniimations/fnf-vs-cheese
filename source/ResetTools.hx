import openfl.Lib;
import flixel.FlxG;

class ResetTools
{
    public static function resetData()
    {
		//EXTRA DATA

		// thanks kade

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.diedTwiceFrosted == null)
			FlxG.save.data.diedTwiceFrosted == false;

		// WEEK UNLOCK DATA

		if (FlxG.save.data.beatTutorial == null)
			FlxG.save.data.beatTutorial = false;

		if (FlxG.save.data.beatCulturedWeek == null)
			FlxG.save.data.beatCulturedWeek = false;

		if (FlxG.save.data.beatWeekEnding == null)
			FlxG.save.data.beatWeekEnding = false;

		if (FlxG.save.data.beatBonus == null)
			FlxG.save.data.beatBonus = false;
	}
}