package;

class Reg
{
	public static var levels:Array<String> = [
		AssetPaths.level__tmx,
		AssetPaths.level1__tmx,
		AssetPaths.level2__tmx,
		AssetPaths.level3__tmx
	];

	public static var levelIdx:Int = 0;

	public static var sounds_abdrueck:Array<String> = [
		AssetPaths.Abdrueck01__ogg,
		AssetPaths.Abdrueck02__ogg,
		AssetPaths.Abdrueck03__ogg,
		AssetPaths.Abdrueck04__ogg,
		AssetPaths.Abdrueck05__ogg,
		AssetPaths.Abdrueck07__ogg,
		AssetPaths.Abdrueck08__ogg,
		AssetPaths.Abdrueck09__ogg
	];

	public static var sounds_nach_abdrueck:Array<String> = [
		AssetPaths.es_kommt_1__ogg,
		AssetPaths.es_kommt_2__ogg,
		AssetPaths.es_kommt_3__ogg,
		AssetPaths.es_kommt_4__ogg,
		AssetPaths.es_kommt_5__ogg,
		AssetPaths.es_kommt_6__ogg
	];

	public static var sounds_actors:Array<String> = [
		AssetPaths.faucet_squeak_1__ogg,
		AssetPaths.faucet_squeak_2__ogg,
		AssetPaths.faucet_squeak_3__ogg,
		AssetPaths.faucet_squeak_4__ogg
	];

	public static var kack_schmatz:Array<String> = [
		AssetPaths.Schmatz01__ogg, AssetPaths.Schmatz02__ogg, AssetPaths.Schmatz03__ogg, AssetPaths.Schmatz07__ogg, AssetPaths.Schmatz10__ogg,
		AssetPaths.Schmatz11__ogg, AssetPaths.Schmatz12__ogg, AssetPaths.Schmatz13__ogg, AssetPaths.Schmatz15__ogg, AssetPaths.Schmatz16__ogg,
		AssetPaths.Schmatz17__ogg
	];

	public static var sounds_spuelung:Array<String> = [AssetPaths.Spuelung__ogg];

	public static var score:Int = 0;

	public static var winCount:Int = 0;
}
