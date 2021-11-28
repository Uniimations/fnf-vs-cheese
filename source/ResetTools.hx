import openfl.Lib;
import flixel.FlxG;

class ResetTools
{
    public static function resetData()
    {
		// thanks kade

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		// WEEK UNLOCK DATA

		if (TitleState.isDebug)
		{
			if (FlxG.save.data.beatTutorial == null || FlxG.save.data.beatTutorial == false)
				FlxG.save.data.beatTutorial = true;
	
			if (FlxG.save.data.beatCulturedWeek == null || FlxG.save.data.beatCulturedWeek == false)
				FlxG.save.data.beatCulturedWeek = true;
	
			if (FlxG.save.data.beatWeekEnding == null || FlxG.save.data.beatWeekEnding == false)
				FlxG.save.data.beatWeekEnding = true;
	
			if (FlxG.save.data.beatBonus == null || FlxG.save.data.beatBonus == false)
				FlxG.save.data.beatBonus = true;
		}
		else
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

		//MISC DATA

		if (FlxG.save.data.diedTwiceFrosted == null)
			FlxG.save.data.diedTwiceFrosted == false;

		if (FlxG.save.data.petCheese == null)
			FlxG.save.data.petCheese == false;
	}
}