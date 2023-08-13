package loom;

using loom.math.MathExtensions;

// 0xAARRGGBB
abstract Color(Int) from Int to Int {
    
    public var alpha(get, set): Int;
    public var red(get, set): Int;
    public var green(get, set): Int;
    public var blue(get, set): Int;

    inline public function get_alpha(): Int {
        return (this & 0xFF000000) >> (8*3) & 0xFF;
    }
    inline public function set_alpha(value: Int): Int {
        value = Math.clamp(value, 0, 255);
        this = (this & 0x00FFFFFF) | (value << (8*3));
        return this;
    }
    
    inline public function get_red(): Int {
        return (this & 0x00FF0000) >> (8*2);
    }
    inline public function set_red(value: Int): Int {
        value = Math.clamp(value, 0, 255);
        this = (this & 0xFF00FFFF) | (value << (8*2));
        return this;
    }
    
    inline public function get_green(): Int {
        return (this & 0x0000FF00) >> 8;
    }
    inline public function set_green(value: Int): Int {
        value = Math.clamp(value, 0, 255);
        this = (this & 0xFFFF00FF) | (value << 8);
        return this;
    }
    
    inline public function get_blue(): Int {
        return (this & 0x000000FF);
    }
    inline public function set_blue(value: Int): Int {
        value = Math.clamp(value, 0, 255);
        this = (this & 0xFFFFFF00) | value;
        return this;
    }
    

    public inline function new(c:Int){
        this = c & 0xFFFFFFFF;
    }

    public static function fromValues(r: Int = 255, g: Int = 255, b: Int = 255, a: Int = 255): Color{
        var c: Color = 0xFFFFFFFF;
        c.alpha = a;
        c.red = r;
        c.green = g;
        c.blue = b;
        return c;
    }
}