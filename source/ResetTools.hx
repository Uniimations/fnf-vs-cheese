import openfl.Lib;
import flixel.FlxG;

class ResetTools
{
    public static function resetData()
    {
		// WEEK UNLOCK DATA

		if (FlxG.save.data.beatTutorial == null)
			FlxG.save.data.beatTutorial = false;

		if (FlxG.save.data.beatCulturedWeek == null)
			FlxG.save.data.beatCulturedWeek = false;

		if (FlxG.save.data.beatCream == null)
			FlxG.save.data.beatCream = false;

		if (FlxG.save.data.beatWeekEnding == null)
			FlxG.save.data.beatWeekEnding = false;

		if (FlxG.save.data.beatNormalEnd == null)
			FlxG.save.data.beatNormalEnd = false;

		if (FlxG.save.data.beatAlternateEnd == null)
			FlxG.save.data.beatAlternateEnd = false;

		if (FlxG.save.data.beatBonus == null)
			FlxG.save.data.beatBonus = false;

		if (FlxG.save.data.beatOnion == null)
			FlxG.save.data.beatOnion = false;

		//MISC DATA

		if (FlxG.save.data.seenIntro == null)
			FlxG.save.data.seenIntro = false;

		if (FlxG.save.data.diedTwiceFrosted == null)
			FlxG.save.data.diedTwiceFrosted = false;

		if (FlxG.save.data.diedTwiceMSB == null)
			FlxG.save.data.diedTwiceMSB = false;

		if (FlxG.save.data.petCheese == null)
			FlxG.save.data.petCheese = false;

		if (FlxG.save.data.seenNotifs == null)
			FlxG.save.data.seenNotifs = false;

		// FOR "Afterparty" ACHIEVEMENT

		if (FlxG.save.data.seenVIPres == null)
			FlxG.save.data.seenVIPres = false;

		if (FlxG.save.data.seenVIPmilk == null)
			FlxG.save.data.seenVIPmilk = false;

		if (FlxG.save.data.seenVIPcul == null)
			FlxG.save.data.seenVIPcul = false;

		if (FlxG.save.data.seenCream == null)
			FlxG.save.data.seenCream = false;

		if (FlxG.save.data.seenDuo == null)
			FlxG.save.data.seenDuo = false;

		if (FlxG.save.data.seenBZ == null)
			FlxG.save.data.seenBZ = false;

		if (FlxG.save.data.seenMozz == null)
			FlxG.save.data.seenMozz = false;

		if (FlxG.save.data.seenMSB == null)
			FlxG.save.data.seenMSB = false;
	}
}
