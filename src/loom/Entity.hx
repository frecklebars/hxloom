package loom;

import loom.utils.UpdateUtils;

abstract class Entity extends h2d.Object implements Updateable{
    public var room(default, null): Room;
    
    public var enabled(default, null): Bool; // TODO handle enabling/disabling
    public var components: UpdateableComponents = [];
    
    public var displayName: String = "";
    
    public function new(name: String, ?room: Room){
        super();

        this.name = name;
        this.enabled = true;
        if(room != null) changeRoom(room);
    }

    public function addComponent(component: Component): Component{
        components.set(component.name, component);
        component.parent = this;

        component.init();

        return component;
    }

    public function changeRoom(room: Room){
        this.room = room;
    }

    public function init(){}
    public function update(dt:Float){
        UpdateUtils.updateAll(dt, components);
    }
}