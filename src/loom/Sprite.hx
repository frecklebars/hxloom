package loom;

typedef Animation = {
    frames: Array<aseprite.Aseprite.AsepriteFrame>,
    loop: Bool
};

class Sprite extends aseprite.AseAnim {

    private var sprite: aseprite.Aseprite;
    private var animations: Map<String, Animation> = [];
    public var currentAnim(default, null): String;

    public function new(parent: Entity, spritePath: String){
        super(parent);
    
        sprite = hxd.Res.loader.load(spritePath).to(aseprite.res.Aseprite).toAseprite();
    }

    public function registerAnimation(tag:String, ?loop:Bool = true){
        var frames = sprite.getTag(tag);
        
        for(frame in frames){
            frame.tile.dx = -Std.int(frame.tile.width * 0.5);
            frame.tile.dy = -Std.int(frame.tile.height);
        }
        animations.set(tag, {frames: frames, loop: loop});

        if(currentAnim == null) playAnimation(tag);
    }

    public function playAnimation(tag:String){
        if(currentAnim == tag || !animations.exists(tag)) return;

        currentAnim = tag;
        loop = animations[tag].loop;
        play(animations[tag].frames);
    }

    public function flipHorizontal(){
        parent.scaleX = -parent.scaleX;
    }
}