package loom;

import loom.config.TypedConfig.PropConfig;

class Prop extends Entity {

    public var sprite: Sprite;
    
    public function new(room: Room, configPath: String, ?config: PropConfig){
        if(config == null){
            config = loom.config.Config.loadConfig(configPath);
        }

        super(room, config.name);

        if(config.sprite != null){
            sprite = new loom.Sprite(this, config.sprite.path);
            
            for(animation in config.sprite.animations){
                sprite.registerAnimation(animation.tag, animation.loop);
            }
        }
    }

    override function init(){}
    override function update(dt: Float){
        super.update(dt);
    }
}