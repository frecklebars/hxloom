package loom;

class Game extends hxd.App{

    public function new(){
        super();
    }

    private var currentRoom: Room;

    public function setActiveRoom(room:Room){
        setScene(room);
        currentRoom = room;
        currentRoom.init();
    }

    override function init(){}

    override function update(dt:Float){
        if(currentRoom != null) currentRoom.update(dt);
    }

}