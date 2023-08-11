package loom;

import loom.utils.UpdateUtils;

class Entity extends h2d.Object implements Updateable{
    public var enabled: Bool;
    public var components: UpdateableComponents = [];

    public var room: Room;
    
    public function new(name: String, room: Room){
        super();

        this.name = name;
        this.enabled = true;
        this.room = room;
    }

    public function addComponent(component: Component){
        components.set(component.name, component);
        component.parent = this;

        component.init();
    }

    public function init(){}
    public function update(dt:Float){
        UpdateUtils.updateAll(dt, components);
    }
}