package loom;

class Game extends hxd.App {

    public var resolutionW: Int;
    public var resolutionH: Int;

    private var scaleMode: h2d.Scene.ScaleMode;

    public function new(){
        super();
    }

    override function init(){
        resolutionW = 320; // TODO pass ass parameters
        resolutionH = 200;

        // pixel-perfect scaling
        scaleMode = LetterBox(resolutionW, resolutionH, true, Center, Center);
    }

    override function update(dt: Float){
    }
}