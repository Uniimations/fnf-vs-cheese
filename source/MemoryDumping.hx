import flixel.FlxG;

class MemoryDumping
{
    // MEMORY CACHE STUFF !!!!!!!!!!!!!!!!!!!!!!!!!!!!!! :3

    // UPDATE: dont use this it does a null error :[

	static var imagesToCache:Array<String> = [];
	static var charactersToCache:Array<String> = [];

    public static function loadToDump(realSongs:String)
    {
        switch (realSongs)
		{
			case 'tutorial':

				imagesToCache = [
					'cheese/kitchen/background_main',
					'cheese/kitchen/cheeese_nevr_uses_that_frying_pan_on_that_shelf',
					'cheese/kitchen/counter_strike_source',
					'cheese/kitchen/SILLY_TRAMSHCANSH',
					'cheese/kitchen/Sink',
					'cheese/kitchen/THEE_AWESIOME_STOBEVE'
				];

				charactersToCache = ['characters/bluecheese_kitchen', 'characters/oisuzuki_kitchen'];

			case 'restaurante' | 'milkshake' | 'cultured':

				imagesToCache = [
					'cheese/floor',
					'cheese/tableA',
					'cheese/tableB',
					'cheese/wall_suzuki',
					'cheese/char/boppers',
					'cheese/counter'
				];

				charactersToCache = [
					'characters/Cheese_Assets',
					'characters/Cheese_Exausted',
					'characters/BOYFRIEND',
					'characters/BOYFRIEND_ALT',
					'characters/GF_assets'
				];

			case 'cream-cheese':

				imagesToCache = [
					'bonus/cream/floor',
					'bonus/cream/tableA',
					'bonus/cream/tableB',
					'bonus/cream/t-side_mod',
					'cheese/wall_suzuki',
					'bonus/cream/counter'
				];

				charactersToCache = [
					'characters/CREAM_CHEESE',
					'characters/BOYFRIEND',
					'characters/BOYFRIEND_ALT',
					'characters/GF_assets',
					'characters/GF_Ghostoru'
				];

			case 'wifi':

				imagesToCache = [
					'cheese/floor_week2',
					'cheese/t-side_mod',
					'cheese/tableA',
					'cheese/tableB',
					'cheese/char/stickmin',
					'cheese/char/joey_new',
					'cheese/char/circle_bop',
					'cheese/char/ralsei_bop',
					'cheese/wall',
					'cheese/counter'
				];

				charactersToCache = [
					'characters/Cheese_Assets',
					'characters/ARSEN_EXPRESSIVE',
					'characters/oisuzuki'
				];

			case 'casual-duel':

				imagesToCache = [
					'cheese/floor_week2',
					'cheese/tableB',
					'cheese/char/fun_gang_latest',
					'cheese/char/sussy_table',
					'cheese/char/DELTARUNE',
					'cheese/wall',
					'cheese/counter',
					'cheese/char/avinera_counter',
					'cheese/char/crowdindie_big'
				];

				charactersToCache = [
					'characters/Cheese_Assets',
					'characters/DANSILOT',
					'characters/oisuzuki'
				];

			case 'below-zero':

				imagesToCache = [
					'cheese/floor',
					'cheese/tableA',
					'cheese/tableB',
					'cheese/t-side_mod',
					'cheese/wall_suzuki',
					'cheese/counter'
				];

				charactersToCache = [
					'characters/Cheese_Assets',
					'characters/DANSILOT',
					'characters/oisuzuki'
				];

			case 'dynamic-duo':

				imagesToCache = [
					'cheese/floor',
					'cheese/char/DYANMIC_BOPPER',
					'cheese/wall_suzuki',
					'cheese/counter'
				];

				charactersToCache = [
					'characters/Cheese_Assets',
					'characters/dynamic-duo-full/the_nera_sans_boy_urh_rur_urh',
					'characters/oisuzuki'
				];
		}
    }

    public static function dumpSongAssets()
    {
        var daSong:String = PlayState.SONG.song.toLowerCase();

        loadToDump(daSong);

        for (character in charactersToCache)
        {
            trace("dumped character " + character);
            FlxG.bitmap.removeByKey(Paths.image(character, 'preload', true));
        }

        charactersToCache = [];
    }
}