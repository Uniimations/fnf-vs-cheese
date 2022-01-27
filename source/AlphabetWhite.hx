package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class AlphabetWhite extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	// for menu shit
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var isMenuItem:Bool = false;
	public var tweenType:String = "none";
	public var textSize:Float = 1.0;

	public var text:String = "";

	var _finalText:String = "";
	var _curText:String = "";
	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacterWhite;
	var xPosResetted:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;
	public var lettersArray:Array<AlphaCharacterWhite> = [];

	public var finishedText:Bool = false;
	public var typed:Bool = false;

	public var typingSpeed:Float = 0.05;
	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, ?typingSpeed:Float = 0.05, ?textSize:Float = 1)
	{
		super(x, y);
		forceX = Math.NEGATIVE_INFINITY;
		this.textSize = textSize;

		_finalText = text;
		this.text = text;
		this.typed = typed;
		isBold = bold;

		if (text != "")
		{
			if (typed)
			{
				startTypedText(typingSpeed);
			}
			else
			{
				addText();
			}
		} else {
			finishedText = true;
		}
	}

	public function changeText(newText:String, newTypingSpeed:Float = -1)
	{
		for (i in 0...lettersArray.length) {
			var letter = lettersArray[0];
			remove(letter);
			lettersArray.remove(letter);
		}
		lettersArray = [];
		splitWords = [];
		_curText = "";
		loopNum = 0;
		xPos = 0;
		curRow = 0;
		consecutiveSpaces = 0;
		xPosResetted = false;
		finishedText = false;
		lastSprite = null;

		var lastX = x;
		x = 0;
		_finalText = newText;
		text = newText;
		if(newTypingSpeed != -1) {
			typingSpeed = newTypingSpeed;
		}

		if (text != "") {
			if (typed)
			{
				startTypedText(typingSpeed);
			} else {
				addText();
			}
		} else {
			finishedText = true;
		}
		x = lastX;
	}

	public function addText()
	{
		doSplitWords();

		var xPos:Float = 0;
		for (character in splitWords)
		{
			// if (character.fastCodeAt() == " ")
			// {
			// }

			var spaceChar:Bool = (character == " " || character == "-" || character == "_");
			if (spaceChar)
			{
				consecutiveSpaces++;
			}

			var isNumber:Bool = AlphaCharacterWhite.numbers.indexOf(character) != -1;
			var isSymbol:Bool = AlphaCharacterWhite.symbols.indexOf(character) != -1;
			var isAlphabet:Bool = AlphaCharacterWhite.alphabet.indexOf(character.toLowerCase()) != -1;
			if ((isAlphabet || isSymbol || isNumber) && (!isBold || !spaceChar))
			{
				if (lastSprite != null)
				{
					xPos = lastSprite.x + lastSprite.width;
				}

				if (consecutiveSpaces > 0)
				{
					xPos += 40 * consecutiveSpaces * textSize;
				}
				consecutiveSpaces = 0;

				var letter:AlphaCharacterWhite = new AlphaCharacterWhite(xPos, 0, textSize);

				if (isBold)
				{
					if (isNumber)
					{
						letter.createBoldNumber(character);
					}
					else if (isSymbol)
					{
						if(character != '-')
							letter.createBoldSymbol(character);
					}
					else
					{
						letter.createBoldLetter(character);
					}
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(character);
					}
					else if (isSymbol)
					{
						letter.createSymbol(character);
					}
					else
					{
						letter.createLetter(character);
					}
				}

				add(letter);
				lettersArray.push(letter);

				lastSprite = letter;
			}

			// loopNum += 1;
		}
	}

	function doSplitWords():Void
	{
		splitWords = _finalText.split("");
	}

	var loopNum:Int = 0;
	var xPos:Float = 0;
	var curRow:Int = 0;
	var dialogueSound:FlxSound = null;
	var consecutiveSpaces:Int = 0;

	var typeTimer:FlxTimer = null;
	public function startTypedText(speed:Float):Void
	{
		_finalText = text;
		doSplitWords();

		// trace(arrayShit);

		if(speed <= 0) {
			while(loopNum < splitWords.length) {
				timerCheck();
			}
			finishedText = true;
			if(dialogueSound != null) dialogueSound.stop();
			dialogueSound = FlxG.sound.play(Paths.sound('dialogue'));
		} else {
			typeTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer) {
				typeTimer = new FlxTimer().start(speed, function(tmr:FlxTimer) {
					timerCheck(tmr);
				}, 0);
			});
		}
	}

	public function timerCheck(?tmr:FlxTimer = null) {
		if (loopNum <= splitWords.length - 2 && splitWords[loopNum] == "\\" && splitWords[loopNum+1] == "n")
		{
			if(tmr != null) tmr.loops -= 2;
			loopNum += 2;
			yMulti += 1;
			xPosResetted = true;
			xPos = 0;
			curRow += 1;
		}

		if(loopNum <= splitWords.length) {
			var spaceChar:Bool = (splitWords[loopNum] == " " || splitWords[loopNum] == "-" || splitWords[loopNum] == "_");
			if (spaceChar)
			{
				consecutiveSpaces++;
			}

			var isNumber:Bool = AlphaCharacterWhite.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacterWhite.symbols.indexOf(splitWords[loopNum]) != -1;
			var isAlphabet:Bool = AlphaCharacterWhite.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1;

			if ((isAlphabet || isSymbol || isNumber) && (!isBold || !spaceChar))
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
					// if (isBold)
					// xPos -= 80;
				}
				else
				{
					xPosResetted = false;
				}

				if (consecutiveSpaces > 0)
				{
					xPos += 20 * consecutiveSpaces * textSize;
				}
				consecutiveSpaces = 0;

				var letter:AlphaCharacterWhite = new AlphaCharacterWhite(xPos, 55 * yMulti, textSize);
				letter.row = curRow;
				if (isBold)
				{
					if (isNumber)
					{
						letter.createBoldNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createBoldSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createBoldLetter(splitWords[loopNum]);
					}
				}
				else
				{
					if (isNumber)
					{
						letter.createNumber(splitWords[loopNum]);
					}
					else if (isSymbol)
					{
						letter.createSymbol(splitWords[loopNum]);
					}
					else
					{
						letter.createLetter(splitWords[loopNum]);
					}
				}
				letter.x += 90;

				if(tmr != null) {
					if(dialogueSound != null) dialogueSound.stop();
					dialogueSound = FlxG.sound.play(Paths.sound('dialogue'));
				}

				add(letter);

				lastSprite = letter;
			}
		}

		loopNum += 1;
		if(loopNum >= splitWords.length && tmr != null) {
			typeTimer = null;
			tmr.cancel();
			tmr.destroy();
			finishedText = true;
		}
	}

	override function update(elapsed:Float)
	{
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 9.6, 0, 1);

		if (isMenuItem && (tweenType == "standard" || tweenType == "none"))
		{
			y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
			if(forceX != Math.NEGATIVE_INFINITY) {
				x = forceX;
			} else {
				x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
			}
		}

		switch (tweenType)
		{
			case "standard":
				if (!isMenuItem)
				{
					y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48) + yAdd, lerpVal);
					if(forceX != Math.NEGATIVE_INFINITY) {
						x = forceX;
					} else {
						x = FlxMath.lerp(x, (targetY * 20) + 90 + xAdd, lerpVal);
					}
				}

			case "left trail":
				y = FlxMath.lerp(y, (scaledY * 65) + (FlxG.height * 0.39), 0.16 / 2);

				x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1), 0.16 / 2);

				if (scaledY < 0)
					x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1), 0.16 / 2);

				if (x > FlxG.width + 30)
					x = FlxG.width + 30;

			case "right trail": // has issues
				y = FlxMath.lerp(y, (scaledY * 90) + (FlxG.height * 0.45), 0.16 / 2);

				x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * - 70 + (FlxG.width * 0.35), 0.16 / 2);
				if (scaledY < 0)
					x = FlxMath.lerp(x, Math.exp(scaledY * - 0.8) * -70 + (FlxG.width * 0.35), 0.16 / 2);

				if (x < -900)
					x = -900;

			case "center":
				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.5), 0.16 / 2);
				x = FlxMath.lerp(x, (targetY * 0) + 308, 0.16 / 2);

			default:
				// do nothing bitchj
		}

		super.update(elapsed);
	}

	public function killTheTimer() {
		if(typeTimer != null) {
			typeTimer.cancel();
			typeTimer.destroy();
		}
		typeTimer = null;
	}
}
