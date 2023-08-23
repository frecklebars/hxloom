package loom;

import loom.config.TypedConfig.SpriteConfig;

typedef Animation = {
    frames: Array<aseprite.Aseprite.AsepriteFrame>,
    loop: Bool
};

class Sprite extends aseprite.AseAnim {

    private var sprite: aseprite.Aseprite;
    private var animations: Map<String, Animation> = [];
    public var currentAnim(default, null): String;

    private var bitmap: h2d.Bitmap;

    public function new(parent: Entity, config: SpriteConfig){
        super(parent);
    
        sprite = hxd.Res.loader.load(config.sprite.path).to(aseprite.res.Aseprite).toAseprite();

        if(config.sprite.animations == null){
            bitmap = new h2d.Bitmap(sprite.toTile(), parent);
            bitmap.tile.dx = -Std.int(bitmap.tile.width * 0.5);
            bitmap.tile.dy = -Std.int(bitmap.tile.height);
        }
        else{
            for(animation in config.sprite.animations){
                registerAnimation(animation.tag, animation.loop);
            }
        }

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