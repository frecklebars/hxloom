package loom.config;

typedef BaseConfig = {
    var name: String;
    var display: String;
}

typedef SpriteConfig = {
    var sprite: {
        var path: String;
        var animations: Array<{tag: String, loop: Bool}>;
        var layer: String;
    }
}

typedef ProtagonistConfig = {
    > BaseConfig,
    > SpriteConfig,
}

typedef RoomConfig = {
    > BaseConfig,
    var background: String;
    var propAtlas: String;
}

typedef PropConfig = {
    > BaseConfig,
    > SpriteConfig,
    var position: {x: Int, y: Int};
}

typedef ActorConfig = {
    > PropConfig,
    var dialogue: String; // TODO actually handle dialogue; this is just to differentiate it from PropConfig
}
