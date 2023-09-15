package loom;

import loom.config.TypedConfig.ProtagonistConfig;

class Protagonist extends Entity {

    public var sprite: Sprite;
    
    public function new(configPath: String){
        var config: ProtagonistConfig;
        config = loom.config.Config.loadConfig(configPath);

        super(config.name);
        if(config.display != null) displayName = config.display;

        if(config.sprite != null){
            sprite = new loom.Sprite(this, config);
        }
    }

    override function init(){}
    override function update(dt: Float){
        super.update(dt);
    }
}