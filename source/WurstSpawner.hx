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

	public function new(x:Float, y:Float, state:PlayState)
	{
		super(x, y);
		_state = state;

		new FlxTimer().start(FlxG.random.int(1, 3), spawn);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public function spawn(f:FlxTimer):Void
	{
		var wurst = new Wurst();
		_state.wurstGroup.add(wurst);
		wurst.x = x;
		wurst.y = y + 10;
		wurst.velocity.y = 10;
	}
}
