package loom;

class Game extends hxd.App{

    public function new(){
        super();
    }

    private var scaleMode: h2d.Scene.ScaleMode = LetterBox(320, 200, true, Center, Center); // pixel-perfect scaling
    private var currentRoom: Room;

    public function setActiveRoom(room:Room){
        setScene(room);
        currentRoom = room;
        currentRoom.scaleMode = scaleMode;
        currentRoom.init();
    }

    override function init(){}

    override function update(dt:Float){
        if(currentRoom != null) currentRoom.update(dt);
    }

}