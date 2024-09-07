package loom.adventure;

import h2d.Interactive;
import h2d.col.Point;

typedef MouseInteractionConfig = {
    var name: String;
    var ?size: {
        width: Float, height: Float,
        ?dx: Float, ?dy: Float,
    }; // ignored if hitbox is present
    var ?hitbox: Array<loom.SimplePoint>;
}

class MouseInteraction implements Component {
    #if debug
    public var DEBUG_DRAW: Bool = false;
    #end

    public var name: String;
    public var enabled: Bool = true;
    public var parent: loom.Object;

    private var interact: Interactive;

    public var width(default, null): Float;
    public var height(default, null): Float;
    public var dx: Float = 0;
    public var dy: Float = 0;
    public var hasPolygonHitbox: Bool = false;

    public var hitbox: Array<Point> = [];

    public function new(parent: loom.Object, config: MouseInteractionConfig){
        this.parent = parent;
        this.name = config.name;

        width = 10;
        height = 10;

        if(config.hitbox != null){
            // set hitbox collider
        }
        else if(config.size != null){
            width = config.size.width;
            height = config.size.height;
            if(config.size.dx != null) dx = config.size.dx;
            if(config.size.dy != null) dy = config.size.dy;
        }
        else if(parent.sprite != null){ // get from sprite height
            width = parent.sprite.width;
            height = parent.sprite.height;
        }

        if(config.hitbox != null){
            hasPolygonHitbox = true;

            for(hp in config.hitbox){
                hitbox.push(new Point(hp.x, hp.y));
            }
            var polygons: h2d.col.Polygons = [new h2d.col.Polygon(hitbox)];
            var collider: h2d.col.PolygonCollider = new h2d.col.PolygonCollider(polygons);
            
            interact = new Interactive(width, height, this.parent, collider);
        }
        else{
            interact = new Interactive(width, height, this.parent);
            
            interact.x = -width / 2 + dx;
            interact.y = -height + dy;
        }
        
    
        // TODO make sure these only update if the player itself is updated
        // interact.onOver = function(e){trace('mouse in ${name}');}
        // interact.onOut = function(e){trace('mouse out ${name}');}
    }

    // TODO 1 polygons
    // TODO 1.5 draw
    // TODO 2 events
    // TODO 3 plug in
    
    public function init(){}
    public function update(dt:Float){
        #if debug
        if(DEBUG_DRAW) debugDraw();
        #end
    }
    
    #if debug
    private function debugDraw(){
        if(hitbox.length > 0){

        }
        else{

        }
    }
    #end
}