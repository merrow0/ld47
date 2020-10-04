package;

import PlayState.ActorType;
import PlayState.Direction;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlowActor extends FlxSprite
{
	public var type:ActorType;
	public var possibleDirs:Array<Direction>;
	public var direction:Direction = NONE;
	public var avoidDirection:Direction = NONE;
	public var isSelected:Bool;
	public var nextDirSet:Bool;

	var _state:PlayState;
	var _tween:FlxTween;
	var _avoidNextDirection:Direction;

	public function new(x:Float, y:Float, actorType:ActorType, initDir:Direction, avoidDir:Direction, state:PlayState)
	{
		super(x, y);

		type = actorType;
		_state = state;

		switch (type)
		{
			case(AUTO):
				loadGraphic(AssetPaths.actor_auto__png, false, 16, 16);
			case(MANUAL):
				loadGraphic(AssetPaths.actor_manual__png, false, 16, 16);
		}

		direction = initDir;
		avoidDirection = avoidDir;
	}

	public function init():Void
	{
		possibleDirs = new Array<Direction>();
		checkPossibleDirs();

		if (direction == NONE)
		{
			direction = possibleDirs[FlxG.random.int(0, possibleDirs.length - 1)];
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		checkDirection();
		checkIsSelected();
	}

	function checkPossibleDirs():Void
	{
		var tileX = Std.int(x / _state.level.tileWidth);
		var tileY = Std.int(y / _state.level.tileHeight);

		if (_state.level.collidableTileLayers[0].getTile(tileX, tileY - 1) == 0 && avoidDirection != UP)
			possibleDirs.push(UP);
		if (_state.level.collidableTileLayers[0].getTile(tileX, tileY + 1) == 0 && avoidDirection != DOWN)
			possibleDirs.push(DOWN);
		if (_state.level.collidableTileLayers[0].getTile(tileX - 1, tileY) == 0 && avoidDirection != LEFT)
			possibleDirs.push(LEFT);
		if (_state.level.collidableTileLayers[0].getTile(tileX + 1, tileY) == 0 && avoidDirection != RIGHT)
			possibleDirs.push(RIGHT);
	}

	function checkDirection():Void
	{
		switch (direction)
		{
			case UP:
				angle = 0;
			case DOWN:
				angle = 180;
			case LEFT:
				angle = 270;
			case RIGHT:
				angle = 90;
			case NONE:
		}
	}

	function checkIsSelected():Void
	{
		if (isSelected)
		{
			if (_tween == null)
			{
				_tween = FlxTween.tween(scale, {x: 1.3, y: 1.3}, 0.1, {ease: FlxEase.quadInOut, type: FlxTweenType.PINGPONG});
			}
		}
		else
		{
			if (_tween != null)
			{
				_tween.cancel();
				_tween = null;
				scale.set(1, 1);
			}
		}
	}

	public function setNextDirection(avoidNextDir:Direction)
	{
		if (!nextDirSet)
		{
			_avoidNextDirection = avoidNextDir;
			new FlxTimer().start(1.3, changeDirection);
			nextDirSet = true;
		}
	}

	public function changeDirection(f:FlxTimer):Void
	{
		var nextDirection = _avoidNextDirection;
		while (nextDirection == _avoidNextDirection)
		{
			nextDirection = possibleDirs[FlxG.random.int(0, possibleDirs.length - 1)];
		}

		direction = nextDirection;
		nextDirSet = false;
	}
}
