import openfl.Lib;
import flixel.FlxG;

class ResetTools
{
    public static function resetData()
    {
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