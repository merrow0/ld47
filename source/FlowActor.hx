package;

import PlayState.ActorType;
import PlayState.Direction;
import flixel.FlxSprite;

class FlowActor extends FlxSprite
{
	public var type:ActorType;
	public var allowedDirs:Array<Direction>;

	public function new(x:Float, y:Float, actorType:ActorType)
	{
		super(x, y);

		type = actorType;

		switch (type)
		{
			case(AUTO):
				loadGraphic(AssetPaths.actor_auto__png, false, 16, 16);
			case(MANUAL):
				loadGraphic(AssetPaths.actor_manual__png, false, 16, 16);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	function checkPossibleDirs():Void {}
}
