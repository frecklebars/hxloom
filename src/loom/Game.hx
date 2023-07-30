package loom;

class Game extends hxd.App{

    public function new(){
        super();
    }

    private var scaleMode: h2d.Scene.ScaleMode = LetterBox(320, 200, true, Center, Center); // pixel-perfect scaling
    public var activeRoom(default, null): Room;

    public function setActiveRoom(room:Room){
        setScene(room);
        activeRoom = room;
        activeRoom.scaleMode = scaleMode;
        activeRoom.filter = new h2d.filter.Nothing();
        activeRoom.init();
    }

    override function init(){}

    override function update(dt:Float){
        if(activeRoom != null) activeRoom.update(dt);
    }

}