package loom;

class Game extends hxd.App {

    public var resolutionW: Int;
    public var resolutionH: Int;

    private var scaleMode: h2d.Scene.ScaleMode;

    public var _rooms: Map<String, Room> = [];
    public var currentRoom(default, null): Room;
    public var player(default, null): Actor;

    public function new(){
        super();
    }

    override function init(){
        resolutionW = 320; // TODO pass as parameters
        resolutionH = 200;

        // pixel-perfect scaling
        scaleMode = LetterBox(resolutionW, resolutionH, true, Center, Center);
    }
    
    public function registerRoom<T:Room>(roomClass: Class<T>, ?initialise: Bool = true): T{
        var room = Type.createInstance(roomClass, []);

        if(_rooms.exists(room.name)){
            trace('Room with name ${room.name} is already registered');
            return null;
        }
        room.game = this;
        _rooms.set(room.name, room);
        
        if(initialise) room.init();

        return room;
    }
    
    public function moveToRoom(roomName: String){
        var room: Room;
        if(_rooms.exists(roomName)){
            room = _rooms[roomName];
        } else return;

        currentRoom = room;
        
        room.scaleMode = scaleMode;
        room.filter = new h2d.filter.Nothing();
        room.init();

        setScene(room);
    }

    override function update(dt: Float){
        if(currentRoom != null) currentRoom.update(dt);
    }
}