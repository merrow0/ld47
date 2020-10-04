package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class WurstSpawner extends FlxSprite
{
	var _timer:Float;
	var _wurstGrp:FlxTypedGroup<Wurst>;
	var _state:PlayState;
	var _minSpawnTime:Int;
	var _maxSpawnTime:Int;

	public function new(x:Float, y:Float, minSpawnTime:Int, maxSpawnTime:Int, state:PlayState)
	{
		super(x, y);
		loadGraphic(AssetPaths.scheisshaus__png, false, 34, 47);
		_state = state;
		_minSpawnTime = minSpawnTime;
		_maxSpawnTime = maxSpawnTime;

		width = 16;
		height = 16;
		offset.set(8, 15);

		new FlxTimer().start(FlxG.random.int(2, 5), spawn);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function spawn(f:FlxTimer):Void
	{
		var wurst = new Wurst(x, y + 16);
		wurst.direction = DOWN;
		_state.wurstGroup.add(wurst);
		f.start(FlxG.random.int(_minSpawnTime, _maxSpawnTime), spawn);
	}
}
