package loom.graphic;

import aseprite.Aseprite;

typedef SpriteConfig = {
    var path: String;
    var ?animations: Array<AnimationConfig>;
}

typedef AnimationConfig = {
    var tag: String;
    var loop: Bool;
    var ?timeScale: Float;
}

typedef Animation = {
    var frames: Array<AsepriteFrame>;
    var loop: Bool;
    var timeScale: Float;
}

class Sprite extends aseprite.AseAnim{
    private var sprite: Aseprite;
    private var animations: Map<String, Animation> = [];
    private var bitmap: h2d.Bitmap;
    
    public var currentAnimation: String;

    // width and height of the first frame in default animation
    public var width(default, null): Float;
    public var height(default, null): Float;

    public function new(parent: loom.Object, config: SpriteConfig){
        super(parent);

        sprite = hxd.Res.loader.load(config.path).to(aseprite.res.Aseprite).toAseprite();

        if(config.animations == null){
            bitmap = new h2d.Bitmap(sprite.toTile(), parent);
    
            bitmap.tile.dx = -bitmap.tile.width / 2;
            bitmap.tile.dy = -bitmap.tile.height;

            width = bitmap.tile.width;
            height = bitmap.tile.height;
        }
        else{
            for(animationCfg in config.animations){
                registerAnimation(animationCfg);
            }

            width = animations[currentAnimation].frames[0].tile.width;
            height = animations[currentAnimation].frames[0].tile.height;
        }
    }

    private function registerAnimation(cfg: AnimationConfig){
        var frames = sprite.getTag(cfg.tag);
        var ts: Float = 1;
        if(cfg.timeScale != null) ts = cfg.timeScale;

        for(frame in frames){
            frame.tile.dx = -frame.tile.width / 2;
            frame.tile.dy = -frame.tile.height;
        }

        animations.set(cfg.tag, {
            frames: frames,
            loop: cfg.loop,
            timeScale: ts
        });

        if(currentAnimation == null) playAnimation(cfg.tag);
    }

    public function playAnimation(tag: String){
        if(currentAnimation == tag || !animations.exists(tag)) return;

        currentAnimation = tag;

        timeScale = animations[tag].timeScale;
        loop = animations[tag].loop;
        play(animations[tag].frames);
    }

    public function flipHorizontal(){
        scaleX = -scaleX;
    }
}