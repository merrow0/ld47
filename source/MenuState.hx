package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import lime.system.System;

class MenuState extends TiledState
{
	override public function create():Void
	{
		super.create();

		FlxG.sound.playMusic(AssetPaths.music_title__ogg, 0.7, true);
		FlxG.sound.music.persist = false;

		Reg.levelIdx = 0;
		level = new TiledLevel(Reg.levels[Reg.levelIdx], this);

		add(level.backgroundLayer);
		add(level.wallLayer);
		add(wurstGroup);
		add(spawners);
		add(level.foregroundLayer);
		add(actors);
		add(exits);

		actors.forEach((actor) -> actor.init());

		var title:FlxText = new FlxText(0, 0, 0, "LOOP THE POOP", 23);
		title.screenCenter(FlxAxes.X);
		title.y = 40;
		title.scrollFactor.set();
		title.setBorderStyle(OUTLINE, FlxColor.BROWN, 5);
		title.alpha = 0;
		FlxTween.tween(title, {alpha: 1}, 1);
		add(title);

		var lmb1:FlxSprite = new FlxSprite(250, 115);
		lmb1.loadGraphic(AssetPaths.lmb__png, false, 6, 10);
		lmb1.active = false;
		add(lmb1);
		var plus1:FlxText = new FlxText(258, 113, 0, "+", 10);
		add(plus1);
		var wasd1:FlxSprite = new FlxSprite(270, 114);
		wasd1.loadGraphic(AssetPaths.wasd__png, false, 16, 14);
		wasd1.active = false;
		add(wasd1);

		var lmb2:FlxSprite = new FlxSprite(250, 146);
		lmb2.loadGraphic(AssetPaths.lmb__png, false, 6, 10);
		lmb2.active = false;
		add(lmb2);
		var plus2:FlxText = new FlxText(258, 144, 0, "+", 10);
		add(plus2);
		var wasd2:FlxSprite = new FlxSprite(270, 145);
		wasd2.loadGraphic(AssetPaths.wasd__png, false, 16, 14);
		wasd2.active = false;
		add(wasd2);

		var rmb:FlxSprite = new FlxSprite(250, 180);
		rmb.loadGraphic(AssetPaths.rmb__png, false, 6, 10);
		rmb.active = false;
		add(rmb);
		var scroll:FlxText = new FlxText(259, 179, 0, "HOLD TO PAN", 7);
		add(scroll);

		add(new FlxButton(FlxG.camera.width / 2 - 45, FlxG.camera.height / 2, "Start Game", click_start));
		#if !html5
		add(new FlxButton(FlxG.camera.width / 2 - 45, FlxG.camera.height / 2 + 30, "Quit", click_quit));
		#end
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		FlxG.overlap(wurstGroup, exits, onWurstHitsExit);
	}

	function onWurstHitsExit(wurst:Wurst, actor:FlxSprite):Void
	{
		wurst.killWurst(true);
	}

	function click_start():Void
	{
		Reg.levelIdx++;
		FlxG.camera.fade(FlxColor.BLACK, 0.2, false, start);
	}

	function start():Void
	{
		FlxG.sound.music.stop();
		FlxG.switchState(new PlayState());
	}

	function click_quit():Void
	{
		FlxG.camera.fade(FlxColor.TRANSPARENT, 0.2, false, actuallyQuit);
	}

	function actuallyQuit():Void
	{
		System.exit(0);
	}
}
