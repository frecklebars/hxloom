package loom;

using loom.graphic.Sprite;
using loom.adventure.MouseInteraction;

typedef ObjectConfig = {
    var name: String;
    var ?enabled: Bool;
    var ?updateable: Bool;
    var ?position: loom.SimplePoint;

    var ?sprite: loom.graphic.Sprite.SpriteConfig;
    var ?interact: loom.adventure.MouseInteraction.MouseInteractionConfig;
}

class Object extends h2d.Object {
    
    public var enabled: Bool = true;
    public var updateable: Bool = false;

    public var room(default, null): Room;
    
    public var sprite: Sprite;
    public var interact: MouseInteraction;

    public var onChangeRoomCalls: Array<Room->Room->Void> = [];

    public function new(config: ObjectConfig){
        super();
        this.name = config.name;

        if(config.position != null){
            x = config.position.x;
            y = config.position.y;
        }
        if(config.enabled != null) enabled = config.enabled;
        if(config.updateable != null) updateable = config.updateable;

        // SPRITE
        if(config.sprite != null){
            sprite = new Sprite(this, config.sprite);
        }

        // MOUSEINTERACT
        if(config.interact != null){
            interact = new MouseInteraction(this, config.interact);
            // interact.init();
        }
    }
    
    public function changeRoom(room: Room){
        var oldRoom: Room = this.room;
        this.room = room;
        onChangeRoom(room, oldRoom);
    }
    
    public function init(){};
    public function update(dt:Float){}

    public function onChangeRoom(newRoom: Room, oldRoom: Room){
        for (call in onChangeRoomCalls){
            call(newRoom, oldRoom);
        }
    }
}