import flixel.FlxG;

class UniiStringTools
{
    // FC TYPES - ALSO I CHANGED IT TO SFC NOW BECAYUSE PSYCH ENGINE OMGG
    public static function makePlayRanks(accuracy:Float, misses:Int, shits:Int, bads:Int, goods:Int, sicks:Int, perfectMarvelous:Int) // generate a letter ranking
    {
        var rankString:String = "N/A";

        if (misses == 0 && shits == 0 && bads == 0 && goods == 0 && sicks == 0 && perfectMarvelous >= 1)
            rankString = 'SFC'; //no shits, bads, or sicks, only perfect
        else if (misses == 0 && shits == 0 && bads == 0 && goods == 0 && sicks >= 1)
            rankString = 'SFC'; //no shits or bads, only sick and above
        else if (misses == 0 && shits == 0 && bads == 0 && goods >= 1)
            rankString = 'GFC'; //no shits or bads, only goods and above
        else if (misses == 0)
            rankString = 'FC'; //standard fc
        else if (misses <= 10)
            rankString = 'SDCB'; //under 10 misses
        else if (misses >= 11)
            rankString = 'clear'; //anything else

        return rankString;
    }

    // NOTE SKIN SUFFIX
    public static function noteSkinSuffix(characterString:String, ?playerInt:Int = 0)
    {
        var note_skin_suffix:String = '';

        switch (playerInt)
        {
            case 0: // dad character name
                switch (characterString)
                {
                    case 'bluecheese' | 'bluecheese-garcello' | 'bluecheese-hex' | 'bluecheese-kitchen' | 'bluecheese-spamton' | 'bluecheese-tired' | 'bluecheese-tricky' | 'bluecheese-whitty' | 'ex-bluecheese':
                        note_skin_suffix = '_CHEESE';
                    case 'avinera-frosted-tape' | 'avinera-frosted':
                        note_skin_suffix = '_AVINERA';
                    case 'bluecheese-and-suzuki':
                        note_skin_suffix = '_SUZUCHEESE';
                    case 'unii':
                        note_skin_suffix = '_UNII';
                    default:
                        note_skin_suffix = '';
                }
            case 1: // bf character name (unused, DON'T use)
                switch (characterString)
                {
                    case 'bf' | 'bf-alt' | 'bf-small' | 'bf-small-alt':
                        note_skin_suffix = '_BF';
                    case 'undertale-bf':
                        note_skin_suffix = '_UNDERTALE';
                    default:
                        note_skin_suffix = '';
                }
        }

        // the string it will return for the note skin path
        return note_skin_suffix;
    }

    // FOR ADDING BASIC ACHIEVEMENTS FOR WEEKS AND SONGS SINCE IM LAZY LOL
    public static function quickAchievement(achievementType:String, statement:Bool = true, ?weekNum:Int = 0, ?difficulty:String = 'hard', ?song:String = '', ?SongString:String = '')
    {
        // none of this works dont use it, pushing this file anyway for note skins
        switch (achievementType)
        {
            case 'song':
                if (song == SongString && CoolUtil.difficultyString() == difficulty.toUpperCase()) {
                    statement = true;
                }

            case 'storySong':
                if (PlayState.isStoryMode && song == SongString && CoolUtil.difficultyString() == difficulty.toUpperCase()) {
                    statement = true;
                }

            case 'quickSong':
                if (song == SongString) {
                    statement = true;
                }

            case 'week':
                if (PlayState.isStoryMode && WeekData.getCurrentWeekNumber() == weekNum && PlayState.storyPlaylist.length <= 1 && CoolUtil.difficultyString() == difficulty.toUpperCase()) {
                    statement = true;
                }

        }
    }
}