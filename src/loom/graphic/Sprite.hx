package loom.graphic;

using aseprite.Aseprite;

typedef SpriteConfig = {
    var path: String;
}

class Sprite extends aseprite.AseAnim{
    private var sprite: Aseprite;

    private var bitmap: h2d.Bitmap;

    public function new(parent: loom.Object, config: SpriteConfig){
        super(parent);

        sprite = hxd.Res.loader.load(config.path).to(aseprite.res.Aseprite).toAseprite();
        bitmap = new h2d.Bitmap(sprite.toTile(), parent);

        bitmap.tile.dx = -bitmap.tile.width / 2;
        bitmap.tile.dy = -bitmap.tile.height;
    }

}