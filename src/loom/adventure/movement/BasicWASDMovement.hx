package loom.adventure.movement;

using hxd.Key;

class BasicWASDMovement implements Component{
    public var name: String;
    public var parent: loom.Object;
	public var enabled:Bool = true;

    public var speed: Int = 80;

    public var walking: Bool = false;
    public var stoppedWalking: Bool = false;

    public function new(parent: loom.Object, ?speed: Int){
        this.parent = parent;
        if(speed != null) this.speed = speed;
    }

    public function init(){}
    public function update(dt:Float){
        if(Key.isDown(Key.W) || Key.isDown(Key.A) || Key.isDown(Key.S) || Key.isDown(Key.D)){
            walking = true;
            if(Key.isDown(Key.W)){
                parent.y = parent.y - dt * speed;
            }
            if(Key.isDown(Key.A)){
                parent.x = parent.x - dt * speed;
            }
            if(Key.isDown(Key.S)){
                parent.y = parent.y + dt * speed;
            }
            if(Key.isDown(Key.D)){
                parent.x = parent.x + dt * speed;
            }
        }
        else if(Key.isReleased(Key.W) || Key.isReleased(Key.A) || Key.isReleased(Key.S) || Key.isReleased(Key.D)){
            walking = false;
            stoppedWalking = true;
        }
        else{
            stoppedWalking = false;
        }
    }
}