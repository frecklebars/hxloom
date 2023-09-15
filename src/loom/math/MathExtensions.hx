package loom.math;

using h2d.col.Point;
using h2d.col.Polygon;

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

function getConcavePoints(cl:Class<Math>, points: Array<h2d.col.Point>, invert: Bool = false): Array<h2d.col.Point> {
    var concavePoints: Array<h2d.col.Point> = [];
    if(points.length <= 3) return concavePoints;

    for(i in 0...points.length){
        var point = points[i];
        var nextPoint = points[(i+1) % points.length];
        var prevPoint = points[(points.length + i - 1) % points.length];

        var left = {x: point.x - prevPoint.x, y: point.y - prevPoint.y};
        var right = {x: nextPoint.x - point.x, y: nextPoint.y - point.y};

        var cross: Float = (left.x * right.y) - (left.y * right.x);

        if((!invert && cross < 0) || (invert && cross > 0)) concavePoints.push(point);
    }

    return concavePoints;
}

function getConvexPoints(cl:Class<Math>, points: Array<Point>): Array<Point> {
    if(points.length <= 3) return points;
    return getConcavePoints(cl, points, true);
}

/**
    Checks if line p1p2 intersects line q1q2
**/
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

function pointInLineOfSight(cl:Class<Math>, polygons: Array<Polygon>, start: Point, end: Point): Bool {
    // not in LOS if any of the ends is outside the polygon
    if(!polygons[0].contains(start) || !polygons[0].contains(end)) return false;
    if(start == end) return false;

    for (polygon in polygons){
        for (i in 0...polygon.points.length) {
            var v1 = polygon.points[i];
            var v2 = polygon.points[(i+1) % polygon.points.length];
            
            if(linesIntersect(cl, start, end, v1, v2)) return false;
        }
    }
    
    var middle = new Point((start.x + end.x)/2, (start.y + end.y)/2);
    var inside: Bool = polygons[0].contains(middle);

    for (i in 1...polygons.length){
        if(polygons[i].contains(middle)) return false;
    }

    return inside;
}