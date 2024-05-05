package loom;

interface Component {
    public var enabled: Bool;
    public var name: String;
    public var parent: loom.Object;
    public function init(): Void;
    public function update(dt:Float): Void;
}