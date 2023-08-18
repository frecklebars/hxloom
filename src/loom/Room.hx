package loom;

import loom.Color;
import loom.utils.UpdateUtils;

class Room extends h2d.Scene {

    private var background: h2d.Bitmap;
    
    public var roomWidth(default, null): Int;
    public var roomHeight(default, null): Int;
    public var entities: UpdateableEntities = [];

    public function new(name: String, bgTilePath: String){
        super();
        this.name = name;

        var bgTile;
        if(bgTilePath == null){ // TODO remove later after adding from json loading?
            bgTile = h2d.Tile.fromColor(Color.fromHexRGB(0x000000), 320, 200);
        }
        else{
            bgTile = hxd.Res.loader.load(bgTilePath).toTile();
        }

        roomWidth = Std.int(bgTile.width);
        roomHeight = Std.int(bgTile.height);

        background = new h2d.Bitmap(bgTile, this);
        background.blendMode = h2d.BlendMode.None;
    }

    public function addEntity(entity: Entity, initialise: Bool = false){
        entities.set(entity.name, entity);
        addChild(entity);

        if(initialise) entity.init();
    }

    
    public function init(){}
    public function update(dt:Float){
        UpdateUtils.updateAll(dt, entities);
    }
    
}