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

function pointInLineOfSight(cl:Class<Math>, polygons: Array<Polygon>, start: Point, end: Point, tolerance: Float = 10): Bool {
    // not in LOS if any of the ends is outside the polygon
    if(!pointInsidePolygonTolerant(cl, polygons[0], start) || !pointInsidePolygonTolerant(cl, polygons[0], end)) return false;
    if(start == end) return false;

    if(start.distance(end) < tolerance) return true;

    for (polygon in polygons){
        for (i in 0...polygon.points.length) {
            var p1 = polygon.points[i];
            var p2 = polygon.points[(i+1) % polygon.points.length];
            
            if(linesIntersect(cl, start, end, p1, p2)) return false;
        }
    }
    
    var middle = new Point((start.x + end.x)/2, (start.y + end.y)/2);
    var inside: Bool = polygons[0].contains(middle);

    for (i in 1...polygons.length){
        if(polygons[i].contains(middle)) return false;
    }

    return inside;
}

function getDirection(cl:Class<Math>, origin: Point, target: Point): Point{
    var dir: Point = new Point(target.x - origin.x, target.y - origin.y);

    var mag: Float = Math.sqrt(dir.x * dir.x + dir.y * dir.y);

    if(mag > 0){
        dir.x = dir.x/mag;
        dir.y = dir.y/mag;
    }

    return dir;
}

function pointInsidePolygonTolerant(cl: Class<Math>, polygon: Polygon, point: Point, tolerance: Float = 5): Bool{
    var inside: Bool = false;
    
    if(polygon.length < 3) return false;

    var oldPoint: Point = polygon.points[polygon.length - 1];
    var oldSqDist: Float = oldPoint.distanceSq(point);

    for (newPoint in polygon.points){
        var newSqDist: Float = newPoint.distanceSq(point);

        if(oldSqDist + newSqDist + 2 * Math.sqrt(oldSqDist * newSqDist) - newPoint.distanceSq(oldPoint) < tolerance) return true;

        var left: Point;
        var right: Point;

        if(newPoint.x > oldPoint.x){
            left = oldPoint;
            right = newPoint;
        }
        else{
            left = newPoint;
            right = oldPoint;
        }

        if(left.x < point.x && point.x <= right.x && (point.y - left.y) * (right.x - left.x) < (right.y - left.y) * (point.x - left.x))
            inside = !inside;

        oldPoint = newPoint;
        oldSqDist = newSqDist;
    }

    return inside;
}