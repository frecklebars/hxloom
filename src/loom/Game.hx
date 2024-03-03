package loom;

class Game extends hxd.App {

    public var resolutionW: Int;
    public var resolutionH: Int;

    private var scaleMode: h2d.Scene.ScaleMode;

    public var currentRoom(default, null): Room;

    public function new(){
        super();
    }

    override function init(){
        resolutionW = 320; // TODO pass as parameters
        resolutionH = 200;

        // pixel-perfect scaling
        scaleMode = LetterBox(resolutionW, resolutionH, true, Center, Center);
    }

    public function changeRoom(room: Room){
        setScene(room);
        currentRoom = room;

        room.scaleMode = scaleMode;
        room.filter = new h2d.filter.Nothing();
        room.init();
    }

    override function update(dt: Float){
        currentRoom.update(dt);
    }
}