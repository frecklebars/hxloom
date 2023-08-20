package loom;

class Background extends h2d.Bitmap {

    public function new(room: Room, tile: h2d.Tile) {
        super(tile, room);
        this.blendMode = h2d.BlendMode.None;
    }
    
    public static function fromPng(room: Room, path: String){
        var tile = hxd.Res.loader.load(path).toTile();
        return new Background(room, tile);
    }

    public static function fromColor(room: Room, ?color: Color = 0x000000, ?width: Int = 10, ?height: Int = 10){
        var tile = h2d.Tile.fromColor(Color.fromHexRGB(color), width, height);
        return new Background(room, tile);
    }

    public function getDimensions(): Room.RoomDimensions{
        return {width: Std.int(this.tile.width), height: Std.int(this.tile.height)};
    }
}