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

    public var walkArea: h2d.col.Polygon;
    public var exclusionAreas: Array<h2d.col.Polygon>;

    #if debug
    public var drawer: h2d.Graphics;
    #end

    public function new(configPath: String){
        var config: RoomConfig = loom.config.Config.loadConfig(configPath);
        
        super();
        this.name = config.name;
        if(config.display != null) displayName = config.display;

        if(config.propAtlas != null){
            propAtlas = loom.config.Config.loadMultipleConfig(config.propAtlas);
        }

        if(config.walkArea != null){
            var waPoints = new Array<h2d.col.Point>();
            for (point in config.walkArea.points){
                waPoints.push(new h2d.col.Point(point.x, point.y));
            }
            walkArea = new h2d.col.Polygon(waPoints);

            if(config.walkArea.exclusion != null){
                exclusionAreas = [];
                for (exclusion in config.walkArea.exclusion){
                    var exclPoints = new Array<h2d.col.Point>();
                    for (point in exclusion){
                        exclPoints.push(new h2d.col.Point(point.x, point.y));
                    }
                    exclusionAreas.push(exclPoints);
                }
            }
        }

        background = Background.fromPng(this, config.background);
        dimensions = background.getDimensions();

        #if debug
        drawer = new h2d.Graphics();
        add(drawer, 40);
        #end
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