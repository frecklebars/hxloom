package loom;

import loom.config.TypedConfig.ActorConfig;

class Actor extends Prop {

    public function new(room: Room, configPath: String) {
        var config: ActorConfig = loom.config.Config.loadConfig(configPath);

        /**
            TODO finish later with sprite and etc
            handle only dialogue and Actor specific things here, rest is picked up by Prop
        **/
        
        super(room, configPath, config);
    }

}