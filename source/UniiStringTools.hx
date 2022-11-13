package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.display.BlendMode;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

/**
 * this isnt only used for string tools i lied :3 
 * hehe x3
 * @author uniimations
 */

class UniiStringTools
{
    // FC TYPES - ALSO I CHANGED IT TO SFC NOW BECAYUSE PSYCH ENGINE OMGG
    public static function makePlayRanks(misses:Int, shits:Int, bads:Int, goods:Int, sicks:Int, perfectMarvelous:Int) // generate a letter ranking
    {
        var rankString:String = "N/A";

        if (misses == 0 && shits == 0 && bads == 0 && goods == 0 && sicks == 0 && perfectMarvelous >= 1)
            rankString = 'PFC'; //no shits, bads, or sicks, only perfect
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
    public static function noteSkinSuffix(characterString:String)
    {
        var note_skin_suffix:String = '';

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

        // the string it will return for the note skin path
        return note_skin_suffix;
    }

    public static function checkAnimFinish(object:FlxSprite, introAnim:String, idleAnim:String)
    {
        if (object.animation.curAnim != null)
        {
            if (object.animation.curAnim.name == introAnim && object.animation.curAnim.finished)
            {
                new FlxTimer().start(0.1, function(tmr: FlxTimer)
                {
                    object.animation.play(idleAnim);
                });
            }
        }
    }

    public static function getLuaStage(stage:String):LuaStage
    {
		var rawJson:String = null;
		var path:String = Paths.mods('stages/' + stage + '.json');

		if(FileSystem.exists(path))
        {
			rawJson = File.getContent(path);
		}
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}

    public static function potionionsMessage() {
		var returnTxt = "You cheated not only the game, but yourself. You didn't grow. You didn't improve. You took a shortcut and gained nothing. You experienced a hollow victory. Nothing was risked and nothing was gained. It's sad that you don't know the difference.";

		return returnTxt;
	}

    // i added blend modes!! ^_^
    public static function getBlend(blend:String):BlendMode {
		switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
	}
}

typedef LuaStage = {
    var stage:String;
	var defaultZoom:Float;
    var staticZoom:Float;
    var combo:Array<Int>;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;
}