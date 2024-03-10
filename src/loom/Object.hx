package loom;

class Object extends h2d.Object {

    public var room(default, null): Room;

    public function new(name: String){
        this.name = name;
        super();
    }

    public function init(){};
    public function update(dt:Float){}

    public function changeRoom(room: Room){
        this.room = room;
    }
}