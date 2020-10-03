package;

import flixel.FlxSprite;

class FlowActor extends FlxSprite
{
	public var type:String;

	public function new(x, y, actorType)
	{
		super(x, y);

		loadGraphic(AssetPaths.actor__png, false, 16, 16);
		type = actorType;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
