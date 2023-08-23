package loom;

import loom.config.TypedConfig.PropConfig;

class Prop extends Entity {

    public var sprite: Sprite;
    
    public function new(configPath: String, ?config: PropConfig){
        if(config == null){
            config = loom.config.Config.loadConfig(configPath);
        }

        super(config.name);

        if(config.display != null) displayName = config.display;

        if(config.position != null){
            x = config.position.x;
            y = config.position.y;
        }

        if(config.sprite != null){
            sprite = new loom.Sprite(this, config);
        }
    }

    override function init(){}
    override function update(dt: Float){
        super.update(dt);
    }
}