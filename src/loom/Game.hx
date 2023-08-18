package loom;

class Game extends hxd.App{

    public var resW: Int;
    public var resH: Int;
    private var scaleMode: h2d.Scene.ScaleMode;
    
    public var activeRoom(default, null): Room;

    public function new(){
        super();
    }
    
    public function setActiveRoom(room:Room){
        setScene(room);
        activeRoom = room;
        
        activeRoom.scaleMode = scaleMode;
        activeRoom.filter = new h2d.filter.Nothing();
        
        activeRoom.init();
    }
    
    override function init(){
        resW = 320; // TODO read from config
        resH = 200;
        
        scaleMode = LetterBox(resW, resH, true, Center, Center); // pixel-perfect scaling
    }

    override function update(dt:Float){
        if(activeRoom != null) activeRoom.update(dt);
    }

}