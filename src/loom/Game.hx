package loom;

class Game extends hxd.App{

    // public var resolutionW: Int = 320;
    // public var resolutionH: Int = 200;
    private var scaleMode: h2d.Scene.ScaleMode;
    
    public var activeRoom(default, null): Room;

    public function new(){
        super();

        scaleMode = LetterBox(320, 200, true, Center, Center); // pixel-perfect scaling
    }

    public function setActiveRoom(room:Room){
        setScene(room);
        activeRoom = room;
        // if(activeRoom.game == null) activeRoom.game = this;

        activeRoom.scaleMode = scaleMode;
        activeRoom.filter = new h2d.filter.Nothing();
        
        activeRoom.init();
    }

    override function init(){}

    override function update(dt:Float){
        if(activeRoom != null) activeRoom.update(dt);
    }

}