package loom;

import loom.utils.UpdateUtils;

class Component implements Updateable{
    public var name: String;
    public var enabled: Bool;
    public var parent: Entity;

    public function new(name: String){
        this.name = name;
        this.enabled = true;
    }

    function toString() {
		var c = Type.getClassName(Type.getClass(this));
		return name == null ? c : name + "(" + c + ")";
	}

    public function init(){}
    public function update(dt:Float){}

}