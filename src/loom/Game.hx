package loom;

import haxe.ui.Toolkit;
import haxe.ui.core.Screen;

class Game extends hxd.App{

    public var resW: Int;
    public var resH: Int;
    private var scaleMode: h2d.Scene.ScaleMode;
    
    public var activeRoom(default, null): Room;

    public function new(){
        super();
    }
    
    public function setActiveRoom(room:Room, initialise: Bool = false){
        setScene(room);
        activeRoom = room;
        
        activeRoom.scaleMode = scaleMode;
        activeRoom.filter = new h2d.filter.Nothing();
        
        if(initialise) activeRoom.init();

        Screen.instance.root = room;
        // var ui: UiTest = new UiTest();
        // Screen.instance.addComponent(ui);
    }
    
    override function init(){
        resW = 320; // TODO read from config
        resH = 200;
        
        scaleMode = LetterBox(resW, resH, true, Center, Center); // pixel-perfect scaling

        Toolkit.init();
    }

    override function update(dt:Float){
        if(activeRoom != null) activeRoom.update(dt);
    }

}