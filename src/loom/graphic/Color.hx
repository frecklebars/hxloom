package loom.graphic;

using loom.math.MathExtensions;

// 0xAARRGGBB
abstract Color(Int) from Int to Int {

    public static inline var WHITE    = 0xFFFFFF;
    public static inline var GRAY     = 0x888888;
    public static inline var BLACK    = 0x000000;
    public static inline var RED      = 0xFF0000;
    public static inline var GREEN    = 0x00FF00;
    public static inline var BLUE     = 0x0000FF;
    public static inline var YELLOW   = 0xFFFF00;
    public static inline var MAGENTA  = 0xFF00FF;
    public static inline var CYAN     = 0x00FFFF;


    public var alpha(get, set): Int;
    public var red(get, set): Int;
    public var blue(get, set): Int;
    public var green(get, set): Int;

    inline public function get_alpha(): Int{
        return (this & 0xFF000000) >> (8*3) & 0xFF;
    }
    inline public function set_alpha(value: Int): Color{
        value = Math.clamp(value, 0, 255);
        this = (this & 0x00FFFFFF) | (value << (8*3));
        return this;
    }

    inline public function get_red(): Int{
        return (this & 0x00FF0000) >> (8*2);
    }
    inline public function set_red(value: Int): Color{
        value = Math.clamp(value, 0, 255);
        this = (this & 0xFF00FFFF) | (value << (8*2));
        return this;
    }

    inline public function get_green(): Int{
        return (this & 0x0000FF00) >> 8;
    }
    inline public function set_green(value: Int): Color{
        value = Math.clamp(value, 0, 255);
        this = (this & 0xFFFF00FF) | (value << 8);
        return this;
    }

    inline public function get_blue(): Int{
        return (this & 0x000000FF);
    }
    inline public function set_blue(value: Int): Color{
        value = Math.clamp(value, 0, 255);
        this = (this & 0xFFFFFF00) | value;
        return this;
    }


    public static function fromHexRGB(c: Int): Color{
        var c: Color = (c & 0xFFFFFF);
        c.alpha = 255;
        return c;
    }
    public static function fromHexARGB(c: Int): Color{
        var c: Color = (c & 0xFFFFFFFF);
        return c;
    }
    public static function fromHexRGBA(c: Int): Color{
        var c: Color = (c & 0xFFFFFFFF);
        var a = (c & 0x000000FF);
        c = c >> 8;
        c.alpha = a;
        return c;
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