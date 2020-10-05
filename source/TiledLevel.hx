package;

import PlayState.ActorType;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import haxe.io.Path;

class TiledLevel extends TiledMap
{
	inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/";

	public var wallLayer:FlxGroup;
	public var objectsLayer:FlxGroup;
	public var backgroundLayer:FlxGroup;
	public var foregroundLayer:FlxGroup;

	public var collidableTileLayers:Array<FlxTilemap>;

	public var imagesLayer:FlxGroup;

	public function new(tiledLevel:FlxTiledMapAsset, state:TiledState)
	{
		super(tiledLevel);

		imagesLayer = new FlxGroup();
		wallLayer = new FlxGroup();
		objectsLayer = new FlxGroup();
		backgroundLayer = new FlxGroup();
		foregroundLayer = new FlxGroup();

		loadImages();
		loadObjects(state);

		// Load Tile Maps
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE)
				continue;
			var tileLayer:TiledTileLayer = cast layer;

			var tileSheetName:String = tileLayer.properties.get("tileset");

			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";

			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}

			if (tileSet == null)
				throw "Tileset '"
					+ tileSheetName
					+ "' not found. Did you misspell the 'tilesheet' property in '"
					+ tileLayer.name
					+ "' layer?";

			var imagePath = new Path(tileSet.imageSource);
			var processedPath = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;

			// could be a regular FlxTilemap if there are no animated tiles
			var tilemap = new FlxTilemapExt();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processedPath, tileSet.tileWidth, tileSet.tileHeight, OFF, tileSet.firstGID, 1, 1);

			if (tileLayer.properties.contains("animated"))
			{
				var specialTiles:Map<Int, TiledTilePropertySet> = new Map();
				for (tileProp in tileSet.tileProps)
				{
					if (tileProp != null && tileProp.animationFrames.length > 0)
					{
						specialTiles[tileProp.tileID + tileSet.firstGID] = tileProp;
					}
				}

				tilemap.setSpecialTiles([
					for (tile in tileLayer.tiles)
						if (tile != null && specialTiles.exists(tile.tileID)) getAnimatedTile(specialTiles[tile.tileID], tileSet) else null
				]);
			}

			if (tileLayer.name.toLowerCase().indexOf("background") >= 0)
			{
				backgroundLayer.add(tilemap);
			}
			else if (tileLayer.name.toLowerCase().indexOf("foreground") >= 0)
			{
				foregroundLayer.add(tilemap);
			}
			else
			{
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();

				wallLayer.add(tilemap);
				collidableTileLayers.push(tilemap);
			}
		}
	}

	function getAnimatedTile(props:TiledTilePropertySet, tileset:TiledTileSet):FlxTileSpecial
	{
		var special = new FlxTileSpecial(1, false, false, 0);
		var n:Int = props.animationFrames.length;
		var offset = Std.random(n);
		special.addAnimation([
			for (i in 0...n)
				props.animationFrames[(i + offset) % n].tileID + tileset.firstGID
		], (1000 / props.animationFrames[0].duration));
		return special;
	}

	public function loadObjects(state:TiledState)
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;
			var objectLayer:TiledObjectLayer = cast layer;

			// collection of images layer
			if (layer.name == "images")
			{
				for (o in objectLayer.objects)
				{
					loadImageObject(o);
				}
			}

			// objects layer
			if (layer.name == "objects")
			{
				for (o in objectLayer.objects)
				{
					loadObject(state, o, objectLayer, objectsLayer);
				}
			}
		}
	}

	function loadImageObject(object:TiledObject)
	{
		var tilesImageCollection:TiledTileSet = this.getTileSet("imageCollection");
		var tileImagesSource:TiledImageTile = tilesImageCollection.getImageSourceByGid(object.gid);

		// decorative sprites
		var levelsDir:String = "assets/images/";

		var decoSprite:FlxSprite = new FlxSprite(0, 0, levelsDir + tileImagesSource.source);
		if (decoSprite.width != object.width || decoSprite.height != object.height)
		{
			decoSprite.antialiasing = true;
			decoSprite.setGraphicSize(object.width, object.height);
		}
		if (object.flippedHorizontally)
		{
			decoSprite.flipX = true;
		}
		if (object.flippedVertically)
		{
			decoSprite.flipY = true;
		}
		decoSprite.setPosition(object.x, object.y - decoSprite.height);
		decoSprite.origin.set(0, decoSprite.height);
		if (object.angle != 0)
		{
			decoSprite.angle = object.angle;
			decoSprite.antialiasing = true;
		}

		// Custom Properties
		if (object.properties.contains("depth"))
		{
			var depth = Std.parseFloat(object.properties.get("depth"));
			decoSprite.scrollFactor.set(depth, depth);
		}

		backgroundLayer.add(decoSprite);
	}

	function loadObject(state:TiledState, o:TiledObject, g:TiledObjectLayer, group:FlxGroup)
	{
		var x:Int = o.x;
		var y:Int = o.y;

		// objects in tiled are aligned bottom-left (top-left in flixel)
		if (o.gid != -1)
			y -= g.map.getGidOwner(o.gid).tileHeight;

		switch (o.name.toLowerCase())
		{
			case "wurst_spawner":
				var initDir:String = null;
				if (o.properties.contains("init_dir"))
				{
					initDir = o.properties.get("init_dir");
				}
				var minInitTime:Int = Std.parseInt(o.properties.get("min_init_spawntime"));
				var maxInitTime:Int = Std.parseInt(o.properties.get("max_init_spawntime"));
				var minTime:Int = Std.parseInt(o.properties.get("min_spawntime"));
				var maxTime:Int = Std.parseInt(o.properties.get("max_spawntime"));

				state.handleLoadSpawner(x, y, minInitTime, maxInitTime, minTime, maxTime, initDir);
			case "flow_actor":
				var initDir:String = null;
				var avoidDir:String = null;
				if (o.properties.contains("init_dir"))
				{
					initDir = o.properties.get("init_dir");
				}
				if (o.properties.contains("avoid_dir"))
				{
					avoidDir = o.properties.get("avoid_dir");
				}

				var type:ActorType = AUTO;
				switch (o.type.toLowerCase())
				{
					case "auto":
						type = AUTO;
					case "semi":
						type = SEMI;
					case "manuell":
						type = MANUAL;
				}
				state.handleFlowActor(x, y, type, initDir, avoidDir);
			case "oneway":
				var initDir:String = o.properties.get("oneway_dir");
				state.handleFlowActor(x, y, ONEWAY, initDir, null);
			case "exit":
				state.handleLoadExit(x, y);
			case "camera_start":
				var winCount:Int = Std.parseInt(o.properties.get("win_count"));
				var loseCount:Int = Std.parseInt(o.properties.get("lose_count"));
				state.handleCameraStart(x, y, winCount, loseCount);
		}
	}

	public function loadImages()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			var image:TiledImageLayer = cast layer;
			var sprite = new FlxSprite(image.x, image.y, c_PATH_LEVEL_TILESHEETS + image.imagePath);
			imagesLayer.add(sprite);
		}
	}

	public function collideWithLevel(obj:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool):Bool
	{
		if (collidableTileLayers == null)
			return false;

		for (map in collidableTileLayers)
		{
			// IMPORTANT: Always collide the map with objects, not the other way around.
			//            This prevents odd collision errors (collision separation code off by 1 px).
			if (FlxG.overlap(map, obj, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
			{
				return true;
			}
		}
		return false;
	}
}
