package;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class HUD extends FlxSpriteGroup
{
	public var zoomLevel:FlxText;

	public function new()
	{
		super();

		zoomLevel = new FlxText(20, 20, 0, "Scheissbollen: ", 14);
		add(zoomLevel);
	}
}
