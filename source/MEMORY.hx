package;

import flixel.math.FlxMath;
#if cpp
import cpp.vm.Gc;
#end
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

// https://imgur.com/a/LVkQmqe
#if windows
@:headerCode("
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <psapi.h>
// are you serious?? 
// do i have to include this after windows.h to not get outrageous compilation errors??????
// one side of my brains loves c++ and the other one hates it
")
#end
class MEMORY extends TextField
{
	private var times:Array<Float>;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000)
	{
		super();

		x = inX;
		y = inY;
		selectable = false;
		defaultTextFormat = new TextFormat("_sans", 12, inCol);

		addEventListener(Event.ENTER_FRAME, onEnter);
		width = 150;
		height = 70;
	}

	private function onEnter(_) // i LOVE freestyle engine :3
	{
		#if windows
		// now be an ACTUAL real man and get the memory from plain & straight c++
		var actualMem:Float = obtainMemory();
		#else
			#if cpp
			// be a real man and calculate memory from hxcpp
			var actualMem:Float = Gc.memInfo64(3); // update: this sucks
			#else
			var actualMem:Float = 7;
			#end
		#end

		var mem:Float = Math.round(actualMem / 1024 / 1024 * 100) / 100;
		var gcMem:Float = 7;

		#if cpp
		gcMem = Math.round(cpp.vm.Gc.memInfo64(2) / 1024 / 1024 * 100) / 100;
		#else
		gcMem = Math.round(openfl.system.System.totalMemory / 1024 / 1024 * 100) / 100;
		#end

		var ramUsage:Float = FlxMath.roundDecimal((mem / 1000), 2);

		if (visible)
		{
			text = "\nPHYS MEM: " + mem + " MB\nGC MEM: " + gcMem + " MB\n" + "USAGE: " + ramUsage + "/8 GB";
		}
	}

	#if windows // planning to do the same for linux but im lazy af so rn it'll use the hxcpp gc
	@:functionCode("
		// ily windows api <3
		auto memhandle = GetCurrentProcess();
		PROCESS_MEMORY_COUNTERS pmc;

		if (GetProcessMemoryInfo(memhandle, &pmc, sizeof(pmc)))
			return(pmc.WorkingSetSize);
		else
			return 0;
	")
	function obtainMemory():Dynamic
	{
		return 0;
	}
	#end
}
