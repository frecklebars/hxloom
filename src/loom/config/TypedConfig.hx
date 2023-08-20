package loom.config;

typedef BaseConfig = {
    var name: String;
}

typedef SpriteConfig = {
    var sprite: {
        var path: String;
        var animations: Array<{tag: String, loop: Bool}>;
        var initial: String;
    }
}

typedef ProtagonistConfig = {
    > BaseConfig,
    > SpriteConfig,
}

typedef RoomConfig = {
    > BaseConfig,
    var background: String;
}

typedef PropConfig = {
    > BaseConfig,
    > SpriteConfig,
}

typedef ActorConfig = {
    > PropConfig,
    var dialogue: String; // TODO actually handle dialogue
}
