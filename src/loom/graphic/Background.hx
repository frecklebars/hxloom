package loom.graphic;

class Background extends h2d.Bitmap {
    
    public function new(tile: h2d.Tile, room: Room){
        super(tile, room);
    }

    public static function fromPng(room: Room, backgroundPath: String): Background{
        var tile = hxd.Res.loader.load(backgroundPath).toTile();
        return new Background(tile, room);
    }

    public static function fromColor(room: Room, ?color: Color=0x000000, ?width: Int=10, ?height: Int=10): Background{
        var tile = h2d.Tile.fromColor(Color.fromHexRGB(color), width, height);
        return new Background(tile, room);
    }
}