package loom;

import hxd.Key;

import loom.editor.RoomEditor;
import loom.graphic.Background;

typedef RoomConfig = {
    var name: String;
    var entry: Map<String, loom.SimplePoint>; // player entry points: prevRoom name ("_" if none) and point. TODO add facing direction too
    
    var ?walkArea: Array<loom.SimplePoint>;
    var ?exclusionAreas: Array<Array<loom.SimplePoint>>;

    var ?background: loom.graphic.Background.BackgroundConfig;
}

class Room extends h2d.Scene {
    @:allow(loom.Game)
    public var game(default, null): loom.Game;

    private var _objects: Map<String, loom.Object> = [];
    private var _actors: Map<String, loom.Actor> = [];
    private var updateables: Array<loom.Object> = [];
    
    private var background: Background;
    private var entry: Map<String, loom.SimplePoint>;

    public var roomW: Int;
    public var roomH: Int;

    public var walkArea: h2d.col.Polygon = [];
    public var exclusionAreas: Array<h2d.col.Polygon> = [];

    #if debug
    public var editor: RoomEditor;
    #end
    
    public function new(config: RoomConfig){
        super();
        name = config.name;
        entry = config.entry;

        if(config.background != null){
            if(config.background.path != null){
                background = Background.fromPng(this, config.background.path);
            }
            else if(config.background.color != null){
                background = Background.fromColor(this, config.background.color, config.background.width, config.background.height);
            }
        }
        else{
            background = Background.fromColor(this, 0x000000, game.resolutionW, game.resolutionH);
        }
        roomW = Std.int(background.tile.width);
        roomH = Std.int(background.tile.height);
            
        if(config.walkArea != null){
            for (p in config.walkArea){
                this.walkArea.push(new h2d.col.Point(p.x, p.y));
            }
        }

        if(config.exclusionAreas != null){
            for(ea in config.exclusionAreas){
                var exclArea: Array<h2d.col.Point> = [];
                for(p in ea){
                    exclArea.push(new h2d.col.Point(p.x, p.y));
                }
                this.exclusionAreas.push(exclArea);
            }
        }

        #if debug
        editor = new RoomEditor(this);
        add(editor.drawer, 40);
        #end
    }
    
    // removed args bcos you should declare everything in the config in the init of the inheriting class
    // public function createAndAddObject<T:Object>(objectClass: Class<T>, args: Array<Dynamic>, ?initialise: Bool = true, ?layer: Int = 4): T{
    public function createAndAddObject<T:Object>(objectClass: Class<T>, ?initialise: Bool = true, ?layer: Int = 4): T{
        var object = Type.createInstance(objectClass, []);
        addObject(object, initialise, layer);
        return object;
    }
    public function createAndAddActor<T:Actor>(actorClass: Class<T>, ?initialise: Bool = true, ?layer: Int = 4): T{
        var actor = Type.createInstance(actorClass, []);
        addActor(actor, initialise, layer);
        return actor;
    }

    public function addObject(object: Object, ?initialise: Bool = true, ?layer: Int = 4){
        object.changeRoom(this);
        this._objects.set(object.name, object);
        add(object, layer);
        
        if(object.updateable) updateables.push(object);
        
        if(initialise) object.init();
    }
    public function addActor(actor: Actor, ?initialise: Bool = true, ?layer: Int = 4){
        actor.changeRoom(this);
        this._actors.set(actor.name, actor);
        add(actor, layer);

        if(actor.updateable) updateables.push(actor);

        if(initialise) actor.init();
    }

    public function removeObject(objectName: String): Object{
        if(!_objects.exists(objectName)){
            trace('failed to remove object ${objectName}: does not exist');
            return null;
        }

        var removedObject: Object = _objects[objectName];
        _objects.remove(objectName);
        updateables.remove(removedObject);

        return removedObject;
    }
    public function removeActor(actorName: String): Actor{
        if(!_objects.exists(actorName)){
            trace('failed to remove actor ${actorName}: does not exist');
            return null;
        }

        var removedActor: Actor = _actors[actorName];
        _actors.remove(actorName);
        updateables.remove(removedActor);
        
        return removedActor;
    }

    public function getObjects(): Map<String, Object>{
        return _objects;
    }
    public function getActors(): Map<String, Actor>{
        return _actors;
    }

    public function onEntry(){
        // TODO check game.prevRoom and pos player based on that
        game.player.x = entry["_"].x;
        game.player.y = entry["_"].y;
    }

    public function onExit(){}

    public function init(){}
    public function update(dt: Float){
        #if debug
        if(Key.isPressed(Key.QWERTY_TILDE)) editor.toggleEditor();
        if(editor.EDIT_MODE != Inactive){
            editor.update(dt);
            return;
        }
        #end

        if(game.player != null){ // curious to benchmark how much this if statement takes since literally all of the time its going to eval to true
            if(game.player.enabled) game.player.update(dt);
        }

        for(obj in updateables){
            if(obj.enabled) obj.update(dt);
        }

        ysort(4);
    }
}