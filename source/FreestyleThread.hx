package; 

import openfl.utils.Function;
import flixel.FlxBasic as YourMother;

class FreestyleThread extends YourMother // FREESTYLE ENGINE THREADING
{
    public static var cache:Bool = false;
    public static var invoke:Dynamic;
      static var th:sys.thread.Thread;
    
    public function new() {
        super();
    }
    
    public static function start(fn:String) {
      if (th == null) {
            th = sys.thread.Thread.create(() ->
            {
                trace('why');
                var fn = Reflect.field(invoke, fn);
                Reflect.callMethod(invoke, fn, []);
            });
      }
    }
}

// copy this into it
// CREDIT IT
// CREDIT IT YOU BETTER
// -Rapper GF
// https://twitter.com/Rapper_GF_Dev