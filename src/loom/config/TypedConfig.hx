package loom.config;

typedef Point = {x: Int, y: Int}

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

typedef WalkAreaConfig = {
    var walkArea: {
        var points: Array<Point>;
        var exclusion: Array<Array<Point>>;
    }
}

typedef RoomConfig = {
    > BaseConfig,
    > WalkAreaConfig,
    var background: String;
    var propAtlas: String;
}

typedef PropConfig = {
    > BaseConfig,
    > SpriteConfig,
    var position: Point;
}

typedef ActorConfig = {
    > PropConfig,
    var dialogue: String; // TODO actually handle dialogue; this is just to differentiate it from PropConfig
}
