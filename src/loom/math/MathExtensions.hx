package loom.math;

overload extern inline function clamp(cl:Class<Math>, num:Int, min:Null<Int>, max:Null<Int>): Int{
    if(max != null && num > max) return max;
    if(min != null && num < min) return min;
    return num;    
}

overload extern inline function clamp(cl:Class<Math>, num:Float, min:Null<Float>, max:Null<Float>): Float{
    if(max != null && num > max) return max;
    if(min != null && num < min) return min;
    return num; 
}