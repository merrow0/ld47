package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

class HUD extends FlxSpriteGroup
{
	var _x:FlxText;
	var _xx:FlxText;
	var _winCount:FlxText;
	var _loseCount:FlxText;
	var _wurst:FlxSprite;
	var _rohr:FlxSprite;

	public function new()
	{
		super();

		var rect:FlxSprite = new FlxSprite().makeGraphic(43, 26, FlxColor.WHITE);
		rect.alpha = 0.2;
		rect.active = false;
		rect.setPosition(6, 7);
		add(rect);

		_wurst = new FlxSprite(7, 8);
		_wurst.loadGraphic(AssetPaths.poop__png, false, 16, 16);
		_wurst.active = false;
		_wurst.scale.set(0.7, 0.7);
		add(_wurst);

		_x = new FlxText(18, 8, 0, " x ");
		_x.setFormat(AssetPaths.Square__ttf, 12, FlxColor.WHITE, LEFT);
		add(_x);

		_winCount = new FlxText(32, 8, 0);
		_winCount.setFormat(AssetPaths.Square__ttf, 12, FlxColor.WHITE, LEFT);
		add(_winCount);

		_rohr = new FlxSprite(7, 21);
		_rohr.loadGraphic(AssetPaths.broken_pipe__png, false, 16, 16);
		_rohr.active = false;
		_rohr.scale.set(0.7, 0.7);
		add(_rohr);

		_xx = new FlxText(18, 19, 0, " x ");
		_xx.setFormat(AssetPaths.Square__ttf, 12, FlxColor.WHITE, LEFT);
		add(_xx);

		_loseCount = new FlxText(32, 19, 0);
		_loseCount.setFormat(AssetPaths.Square__ttf, 12, FlxColor.WHITE, LEFT);
		add(_loseCount);

		updateHUD();
	}

	public function updateHUD()
	{
		_winCount.text = Std.string(Reg.winCount);
		_loseCount.text = Std.string(Reg.loseCount);
	}
}
