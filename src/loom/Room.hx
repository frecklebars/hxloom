package loom;

import loom.utils.UpdateUtils;

class Room extends h2d.Scene {

    public var entities: UpdateableEntities = [];

    public function new(name: String){
        super();
        this.name = name;
    }

    public function addEntity(entity: Entity){
        entities.set(entity.name, entity);
        addChild(entity);

        entity.init();
    }

    
    public function init(){}
    public function update(dt:Float){
        UpdateUtils.updateAll(dt, entities);
    }

    // TODO: add persistence later?
    // override function dispose(){
    //     super.dispose();
    // }
}