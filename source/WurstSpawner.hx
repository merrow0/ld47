package;

import PlayState.Direction;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class WurstSpawner extends FlxSprite
{
	var _wurstGrp:FlxTypedGroup<Wurst>;
	var _state:PlayState;
	var _minInitSpawnTime:Int;
	var _maxInitSpawnTime:Int;
	var _minSpawnTime:Int;
	var _maxSpawnTime:Int;
	var _wurstDirection:Direction;
	var _timer:FlxTimer;
	var _shake:FlxShakeEffect;

	public function new(x:Float, y:Float, minInitSpawnTime:Int, maxInitSpawnTime:Int, minSpawnTime:Int, maxSpawnTime:Int, initDir:Direction, state:PlayState)
	{
		super(x, y);

		loadGraphic(AssetPaths.scheisshaus__png, false, 34, 47);
		_state = state;
		_minInitSpawnTime = minInitSpawnTime;
		_maxInitSpawnTime = maxInitSpawnTime;
		_minSpawnTime = minSpawnTime;
		_maxSpawnTime = maxSpawnTime;
		_wurstDirection = initDir;

		width = 16;
		height = 16;
		offset.set(8, 15);

		new FlxTimer().start(FlxG.random.int(_minInitSpawnTime, _maxInitSpawnTime), initWurst);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	function initWurst(f:FlxTimer):Void
	{
		_timer = f;

		if (_wurstDirection == DOWN)
		{
			FlxG.sound.play(Reg.sounds_abdrueck[FlxG.random.int(0, Reg.sounds_abdrueck.length - 1)], 1, false, preFlushWurst);
		}
		else
		{
			spawnWurst();
		}
	}

	function preFlushWurst():Void
	{
		FlxG.sound.play(Reg.sounds_nach_abdrueck[FlxG.random.int(0, Reg.sounds_nach_abdrueck.length - 1)], 1, false, flushWurst);
	}

	function flushWurst():Void
	{
		FlxG.sound.play(Reg.sounds_spuelung[FlxG.random.int(0, Reg.sounds_spuelung.length - 1)], 1, false, spawnWurst);
	}

	function spawnWurst():Void
	{
		var offsX:Int = 0;
		var offsY:Int = 0;
		switch (_wurstDirection)
		{
			case UP:
				offsY = -16;
			case DOWN:
				offsY = 16;
			case LEFT:
				offsX = -16;
			case RIGHT:
				offsX = 16;
			case NONE:
		}

		var wurst = new Wurst(x + offsX, y + offsY);
		wurst.direction = _wurstDirection;
		_state.wurstGroup.add(wurst);
		_timer.start(FlxG.random.int(_minSpawnTime, _maxSpawnTime), initWurst);
	}
}
