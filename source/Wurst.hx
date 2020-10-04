package;

import PlayState.Direction;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxColor;

class Wurst extends FlxSprite
{
	public static inline var WURST_SPEED:Int = 25;

	public var direction:Direction;
	public var possibleDirections:Array<Direction>;
	public var isImmovable = false;

	var _nextDirection:Direction;
	var _nextX:Float = 0.0;
	var _nextY:Float = 0.0;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		loadGraphic(AssetPaths.poop__png, false, 16, 16);
		possibleDirections = new Array<Direction>();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (isImmovable)
		{
			velocity.set(0, 0);
			return;
		}

		switch (direction)
		{
			case UP:
				velocity.set(0, -WURST_SPEED);
			case DOWN:
				velocity.set(0, WURST_SPEED);
			case LEFT:
				velocity.set(-WURST_SPEED, 0);
			case RIGHT:
				velocity.set(WURST_SPEED, 0);
			case NONE:
				velocity.set(0, 0);
		}

		if (direction != _nextDirection && Std.int(x) == Std.int(_nextX) && Std.int(y) == Std.int(_nextY))
		{
			x = _nextX;
			y = _nextY;
			direction = _nextDirection;
			velocity.set(0, 0);
		}
	}

	override function kill()
	{
		super.kill();

		FlxG.sound.play(Reg.kack_schmatz[FlxG.random.int(0, Reg.kack_schmatz.length - 1)], 0.7, false);

		var emitter = new FlxEmitter(x + 8, y + 8);
		FlxG.state.add(emitter);
		emitter.launchMode = FlxEmitterMode.CIRCLE;
		emitter.acceleration.set(-8, 400, -16, 800);
		emitter.makeParticles(5, 5, FlxColor.BROWN, 32).start(true, 0, 0);
	}

	public function setNextDirection(nextX:Float, nextY:Float, newDir:Direction)
	{
		_nextX = nextX;
		_nextY = nextY;
		_nextDirection = newDir;
	}
}
