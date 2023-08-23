package loom;

import loom.config.TypedConfig.RoomConfig;
import loom.config.TypedConfig.PropConfig;
import loom.utils.UpdateUtils;

typedef RoomDimensions = {width: Int, height: Int};
typedef PropAtlas = haxe.DynamicAccess<PropConfig>;

class Room extends h2d.Scene {
    public var displayName: String = "";
    private var background: Background;

    public var propAtlas: PropAtlas;
    
    public var dimensions(default, null): RoomDimensions;
    public var entities: UpdateableEntities = [];
    
    public function new(configPath: String){
        var config: RoomConfig = loom.config.Config.loadConfig(configPath);
        
        super();
        this.name = config.name;
        if(config.display != null) displayName = config.display;

        if(config.propAtlas != null){
            propAtlas = loom.config.Config.loadMultipleConfig(config.propAtlas);
        }

        background = Background.fromPng(this, config.background);
        dimensions = background.getDimensions();
    }

    public function addEntity(entity: Entity, initialise: Bool = true, layer: Int = 4){
        entity.changeRoom(this);
        entities.set(entity.name, entity);
        add(entity, layer);

        if(initialise) entity.init();
    }

    public function addProp<T:Prop>(propClass: Class<T>, name:String){
        var prop = Type.createInstance(propClass, ["", propAtlas[name]]);
        addEntity(prop);
    }

    
    public function init(){}
    public function update(dt:Float){
        UpdateUtils.updateAll(dt, entities);
        ysort(4);
    }
    
}