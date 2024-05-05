package loom;

class Game extends hxd.App {

    public var resolutionW: Int = 320;
    public var resolutionH: Int = 200;

    private var scaleMode: h2d.Scene.ScaleMode;

    public var _rooms: Map<String, Room> = [];
    public var currentRoom(default, null): Room;
    // public var prevRoom(default, null): Room; // TODO implement

    public var player(default, null): Actor;

    public function new(){
        super();
    }

    override function init(){
        // pixel-perfect scaling
        scaleMode = LetterBox(resolutionW, resolutionH, true, Center, Center);
    }
    
    public function registerRoom<T:Room>(roomClass: Class<T>, ?initialise: Bool = true): T{
        var room = Type.createInstance(roomClass, []);

        if(_rooms.exists(room.name)){
            trace('Room with name ${room.name} is already registered.');
            return null;
        }
        room.game = this;
        _rooms.set(room.name, room);
                
        room.scaleMode = scaleMode;
        room.filter = new h2d.filter.Nothing();

        if(initialise) room.init();

        return room;
    }
    
    // TODO untested (when actually moving between rooms properly)
    public function moveToRoom(roomName: String){
        var room: Room;
        if(_rooms.exists(roomName)){
            room = _rooms[roomName];
        } else return;

        if(currentRoom != null && player != null){
            currentRoom.removeActor(player.name);
        }
        
        currentRoom = room;

        if(player != null){
            currentRoom.addActor(player, false);
        }
    
        setScene(room);

        room.onEntry();
    }

    public function changePlayer(newPlayer: Actor){
        player = newPlayer;
        // TODO later, change to player room, redraw inventory/ui, remove from updateables.
    }

    public function createPlayer<T:Actor>(playerClass: Class<T>, ?initialise: Bool = true): T{
        var player = Type.createInstance(playerClass, []);
        changePlayer(player);

        if(initialise) player.init();

        return player;
    }

    override function update(dt: Float){
        if(currentRoom != null) currentRoom.update(dt);
    }
}