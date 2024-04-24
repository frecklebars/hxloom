package loom;

using loom.graphic.Sprite;

typedef ObjectConfig = {
    var name: String;
    var ?enabled: Bool;
    var ?updateable: Bool;
    var ?position: loom.Point;

    var ?sprite: loom.graphic.Sprite.SpriteConfig;
}

class Object extends h2d.Object {

    public var room(default, null): Room;
    public var sprite: Sprite;

    public var enabled: Bool = true;
    public var updateable: Bool = false;

    public function new(config: ObjectConfig){
        super();
        this.name = config.name;

        if(config.position != null){
            x = config.position.x;
            y = config.position.y;
        }
        if(config.enabled != null) enabled = config.enabled;
        if(config.updateable != null) updateable = config.updateable;

        if(config.sprite != null){
            sprite = new Sprite(this, config.sprite);
        }
    }

    public function init(){};
    public function update(dt:Float){}

    public function changeRoom(room: Room){
        this.room = room;
    }
}