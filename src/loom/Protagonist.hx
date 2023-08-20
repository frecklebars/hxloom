package loom;

import loom.config.TypedConfig.ProtagonistConfig;

class Protagonist extends Entity {

    private var sprite: Sprite;
    
    public function new(room: Room, configPath: String){
        var config: ProtagonistConfig;
        config = loom.config.Config.loadConfig(configPath);

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