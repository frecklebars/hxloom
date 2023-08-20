package loom;

import loom.config.TypedConfig.RoomConfig;
import loom.utils.UpdateUtils;

typedef RoomDimensions = {width: Int, height: Int};

class Room extends h2d.Scene {

    
    private var background: Background;
    
    public var dimensions(default, null): RoomDimensions;
    public var entities: UpdateableEntities = [];
    
    public function new(configPath: String){
        var config: RoomConfig = loom.config.Config.loadConfig(configPath);
        
        super();
        this.name = config.name;

        background = Background.fromPng(this, config.background);
        dimensions = background.getDimensions();
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