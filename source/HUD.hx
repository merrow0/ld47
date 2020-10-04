package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class HUD extends FlxSpriteGroup
{
	var _x:FlxText;
	var _winCount:FlxText;
	var _wurst:FlxSprite;

	public function new()
	{
		super();

		_wurst = new FlxSprite(7, 8);
		_wurst.loadGraphic(AssetPaths.poop__png, false, 16, 16);
		_wurst.active = false;
		add(_wurst);
		_x = new FlxText(18, 8, 0, " x ");
		_x.setFormat(AssetPaths.Square__ttf, 12, FlxColor.WHITE, LEFT);
		add(_x);
		_winCount = new FlxText(32, 8, 0);
		_winCount.setFormat(AssetPaths.Square__ttf, 12, FlxColor.WHITE, LEFT);
		add(_winCount);

		updateHUD();
	}

	public function updateHUD()
	{
		_winCount.text = Std.string(Reg.winCount);
	}
}
