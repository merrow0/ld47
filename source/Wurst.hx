package;

import flixel.FlxSprite;

class Wurst extends FlxSprite
{
	public var direction:String;

	public function new()
	{
		super();
		loadGraphic(AssetPaths.wurst__png, false, 16, 16);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
