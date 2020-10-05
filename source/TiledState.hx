package;

import PlayState.ActorType;
import PlayState.Direction;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class TiledState extends FlxState
{
	public var level:TiledLevel;
	public var wurstGroup:FlxGroup;
	public var spawners:FlxTypedGroup<WurstSpawner>;
	public var exits:FlxGroup;
	public var actors:FlxTypedGroup<FlowActor>;

	var _initCamPos:FlxPoint;

	override public function create()
	{
		super.create();

		spawners = new FlxTypedGroup<WurstSpawner>();
		actors = new FlxTypedGroup<FlowActor>();
		wurstGroup = new FlxGroup();
		exits = new FlxGroup();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		collisionCheck();
		overlapCheck();
	}

	function collisionCheck():Void
	{
		wurstGroup.forEachAlive((it) ->
		{
			var wurst:Wurst = cast(it, Wurst);
			if (level.collideWithLevel(wurst))
			{
				var possibleDirs:Array<Direction> = new Array<Direction>();
				var tileX = Std.int(wurst.x / level.tileWidth);
				var tileY = Std.int(wurst.y / level.tileHeight);

				if (level.collidableTileLayers[0].getTile(tileX, tileY - 1) == 0 && wurst.direction != DOWN)
					possibleDirs.push(UP);
				if (level.collidableTileLayers[0].getTile(tileX, tileY + 1) == 0 && wurst.direction != UP)
					possibleDirs.push(DOWN);
				if (level.collidableTileLayers[0].getTile(tileX - 1, tileY) == 0 && wurst.direction != RIGHT)
					possibleDirs.push(LEFT);
				if (level.collidableTileLayers[0].getTile(tileX + 1, tileY) == 0 && wurst.direction != LEFT)
					possibleDirs.push(RIGHT);

				if (possibleDirs.length == 1)
				{
					wurst.direction = possibleDirs[0];
				}
			}
		});
	}

	function overlapCheck():Void
	{
		FlxG.overlap(wurstGroup, actors, onWurstHitsActor);
	}

	public function handleLoadSpawner(x:Float, y:Float, minInitTime:Int, maxInitTime:Int, minTime:Int, maxTime:Int, initDir:String):Void
	{
		var initalDirection = Direction.DOWN;
		if (initDir != null)
		{
			initalDirection = strToDirection(initDir);
		}
		var spawner = new WurstSpawner(x, y, minInitTime, maxInitTime, minTime, maxTime, initalDirection, this);
		spawners.add(spawner);
	}

	public function handleLoadExit(x:Int, y:Int):Void
	{
		var exit = new FlxSprite(x + 6, y + 12);
		exit.makeGraphic(4, 4, FlxColor.TRANSPARENT);
		exits.add(exit);
	}

	public function handleFlowActor(x:Int, y:Int, type:ActorType, initDir:String, avoidDir:String):Void
	{
		var initalDirection = Direction.NONE;
		if (initDir != null)
		{
			initalDirection = strToDirection(initDir);
		}
		var avoidDirection = Direction.NONE;
		if (avoidDir != null)
		{
			avoidDirection = strToDirection(avoidDir);
		}

		var actor = new FlowActor(x, y, type, initalDirection, avoidDirection, this);
		actors.add(actor);
	}

	public function handleCameraStart(x:Int, y:Int, winCount:Int, loseCount:Int)
	{
		Reg.winCount = winCount;
		Reg.loseCount = loseCount;

		_initCamPos = new FlxPoint(x, y);
	}

	function onWurstHitsActor(wurst:Wurst, actor:FlowActor):Void
	{
		if (wurst.direction != actor.direction)
		{
			wurst.setNextDirection(actor.x, actor.y, actor.direction);
		}

		if (actor.type == AUTO || actor.type == SEMI)
		{
			actor.setNextDirection(wurst.direction);
		}
	}

	function strToDirection(str:String):Direction
	{
		var ret:Direction = NONE;
		switch (str.toLowerCase())
		{
			case "up":
				ret = UP;
			case "down":
				ret = DOWN;
			case "left":
				ret = LEFT;
			case "right":
				ret = RIGHT;
		}
		return ret;
	}
}
