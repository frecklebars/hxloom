package loom.math;

import h2d.col.Point;
import h2d.col.Polygon;

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

function pointsInLineOfSight(cl:Class<Math>, polygons: Array<Polygon>, start: Point, end: Point): Bool {
    if(start == end) return false;

    for(polygon in polygons){
        for(i in 0...polygon.points.length){
            var p1 = polygon.points[i];
            var p2 = polygon.points[(i + 1) % polygon.points.length];

            if(linesIntersect(cl, start, end, p1, p2)) return false;
        }
    }

    return true;
}

function linesIntersect(cl:Class<Math>, p1: Point, p2: Point, q1: Point, q2: Point): Bool {
    var denominator: Float = ((p2.x - p1.x) * (q2.y - q1.y) - (p2.y - p1.y) * (q2.x - q1.x));

    if(denominator == 0) return false;

    var numerator1: Float = ((p1.y - q1.y) * (q2.x - q1.x) - (p1.x - q1.x) * (q2.y - q1.y));
    var numerator2: Float = ((p1.y - q1.y) * (p2.x - p1.x) - (p1.x - q1.x) * (p2.y - p1.y));

    if(numerator1 == 0 || numerator2 == 0) return false;

    var r: Float = numerator1 / denominator;
    var s: Float = numerator2 / denominator;

    return (r > 0 && r < 1) && (s > 0 && s < 1);
}