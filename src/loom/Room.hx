package loom;

import loom.graphic.Background;

typedef RoomConfig = {
    var name: String;

    var ?background: loom.graphic.Background.BackgroundConfig;
}

class Room extends h2d.Scene {
    @:allow(loom.Game)
    public var game(default, null): loom.Game;

    private var background: Background;
    private var _objects: Map<String, loom.Object> = [];
    private var objectsUpdateable: Array<loom.Object> = [];
    
    public function new(config: RoomConfig){
        super();
        name = config.name;

        if(config.background != null){
            if(config.background.path != null){
                background = Background.fromPng(this, config.background.path);
            }
            else if(config.background.color != null){
                background = Background.fromColor(
                    this, 
                    config.background.color,
                    config.background.width,
                    config.background.height
                );
            }
        }

    }

    public function addObject(object: Object, ?initialise: Bool = true, ?layer: Int = 4){
        object.changeRoom(this);
        this._objects.set(object.name, object);
        add(object, layer);
        
        if(object.updateable) objectsUpdateable.push(object);
        
        if(initialise) object.init();
    }
    
    // removed args bcos you should declare everything in the config in the init of the inheriting class
    // public function createAndAddObject<T:Object>(objectClass: Class<T>, args: Array<Dynamic>, ?initialise: Bool = true, ?layer: Int = 4): T{
    public function createAndAddObject<T:Object>(objectClass: Class<T>, ?initialise: Bool = true, ?layer: Int = 4): T{
        var object = Type.createInstance(objectClass, []);
        addObject(object, initialise, layer);
        return object;
    }

    public function init(){}
    public function update(dt: Float){
        for(obj in objectsUpdateable){
            if(obj.enabled) obj.update(dt);
        }

        ysort(4);
    }

}