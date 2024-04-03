package loom;

using loom.graphic.Sprite;

typedef ActorConfig = {
    > loom.Object.ObjectConfig,

    var isPlayer: Bool;
}

class Actor extends loom.Object{

    var isPlayer: Bool = false;

    public function new(config: ActorConfig){
        

        super(config);
    }



}