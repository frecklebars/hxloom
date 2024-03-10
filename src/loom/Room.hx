package loom;

import loom.graphic.Background;

class Room extends h2d.Scene {

    private var background: Background;
    private var objects: Map<String, loom.Object> = [];
    
    public function new(backgroundPath: String){
        super();

        background = Background.fromPng(this, backgroundPath);
    }

    public function addObject(object: Object, ?initialise: Bool = true, ?layer: Int = 4){
        object.changeRoom(this);
        this.objects.set(object.name, object);
        add(object, layer);

        if(initialise) object.init();
    }
    public function createAndAddObject<T:Object>(objectClass: Class<T>, args: Array<Dynamic>, ?initialise: Bool = true, ?layer: Int = 4): T{
        var object = Type.createInstance(objectClass, args);
        addObject(object, initialise, layer);
        return object;
    }

    public function init(){}
    public function update(dt: Float){
        ysort(4);
    }

}