package;

import Song.SwagSong;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class SongMetaData
{
    public var songName:String = "";
    public var week:Int = 0;
    public var songCharacter:String = "";
    public var color:Int = -7179779;

    public function new(song:String, week:Int, songCharacter:String, coolColors:Array<Int>)
    {
        this.songName = song;
        this.week = week;
        this.songCharacter = songCharacter;
        if(week < coolColors.length) {
            this.color = coolColors[week];
        }
    }
}
