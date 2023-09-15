package loom.utils;

using loom.math.MathExtensions;
using hxd.Key;
using h2d.col.Point;
using h2d.col.Polygon;

class RoomUtils {

    #if debug
    static var placing: Bool = true;
    static var placedPoints: Array<Point> = [];
    static var placedExclusions: Array<Array<Point>> = [];
    static var activeNode: Int = 0;
    static var activeExclusion: Int = 0;

    public static function placeWalkArea(room: loom.Room, exclusion: Bool = false){
        if(!placing){
            if(exclusion) editExclusionArea(room, room.walkArea, placedExclusions);
            else editWalkArea(room, placedPoints);
            return;
        }

        if(Key.isPressed(Key.MOUSE_LEFT) && placing){
            placedPoints.push(new Point(Std.int(room.mouseX), Std.int(room.mouseY)));
        }
        else if(exclusion && Key.isPressed(Key.SPACE) && placing){
            placedExclusions.push(placedPoints.copy());
            placedPoints = [];
        }
        else if(Key.isPressed(Key.ENTER)){
            placing = false;
            if(exclusion){
                placedExclusions.push(placedPoints.copy());
                placedPoints = [];
            }
            return;
        }

        // draw
        room.drawer.clear();
        if(exclusion) room.drawer.lineStyle(1, 0x0000FF);
        else room.drawer.lineStyle(1, 0xFF0000);
        if(placedPoints.length > 0){
            room.drawer.moveTo(placedPoints[0].x, placedPoints[0].y);
        }
        if(placedPoints.length > 1){
            for(i in 1...placedPoints.length){
                room.drawer.lineTo(placedPoints[i].x, placedPoints[i].y);
            }
        }
        if(placedPoints.length > 0) room.drawer.lineTo(Std.int(room.mouseX-1), Std.int(room.mouseY-1));
        
        drawWalkAreaPoints(room, placedPoints);
        if(exclusion) drawWalkArea(room, room.walkArea, placedExclusions, false);
        room.drawer.drawRect(Std.int(room.mouseX)-1, Std.int(room.mouseY)-1, 3, 3);
    }
    
    public static function editWalkArea(room: loom.Room, walkArea: Polygon, color: Color = 0xFF0000){
        // draw
        drawWalkAreaLines(room, walkArea, 0x0000FF, true);
        drawWalkAreaPoints(room, walkArea);
        drawWalkAreaConcavePoints(room, walkArea);

        if(Key.isDown(Key.MOUSE_LEFT)){
            walkArea.points[activeNode].set(Std.int(room.mouseX), Std.int(room.mouseY));
        }
        else if(Key.isPressed(Key.MOUSE_RIGHT)){
            walkArea.insert(activeNode, new Point(Std.int(room.mouseX), Std.int(room.mouseY)));
        }
        else if(Key.isPressed(Key.BACKSPACE) && walkArea.length > 1){
            walkArea.remove(walkArea.points[activeNode]);
            if(activeNode == walkArea.length) activeNode--;
        }
        else if(Key.isPressed(Key.MOUSE_WHEEL_UP) || Key.isPressed(Key.NUMBER_2)){
            activeNode = (activeNode + 1) % walkArea.length;
        }
        else if(Key.isPressed(Key.MOUSE_WHEEL_DOWN) || Key.isPressed(Key.NUMBER_1)){
            activeNode = (walkArea.length + activeNode - 1) % walkArea.length;
        }
        else if(Key.isPressed(Key.F)){
            walkArea.reverse();
        }
        else if(Key.isPressed(Key.ENTER)){
            exportWalkArea(walkArea);
        }
        
        room.drawer.lineStyle(1, color);
        room.drawer.drawRect(walkArea.points[activeNode].x-1, walkArea.points[activeNode].y-1, 3, 3);
    }
    
    public static function editExclusionArea(room: loom.Room, walkArea: Polygon, exclusionAreas: Array<Polygon>, color: Color = 0xFF0000){
        // draw
        drawWalkAreaLines(room, walkArea, true);
        drawWalkAreaPoints(room, walkArea);
        drawExclusionAreaLines(room, exclusionAreas, 0x0000FF);
        drawExclusionAreaPoints(room, exclusionAreas);

        drawExclusionAreaConvexPoints(room, exclusionAreas);

        if(Key.isDown(Key.MOUSE_LEFT)){
            exclusionAreas[activeExclusion].points[activeNode].set(Std.int(room.mouseX), Std.int(room.mouseY));
        }
        else if(Key.isPressed(Key.MOUSE_RIGHT)){
            exclusionAreas[activeExclusion].insert(activeNode, new Point(Std.int(room.mouseX), Std.int(room.mouseY)));
        }
        else if(Key.isPressed(Key.BACKSPACE) && exclusionAreas[activeExclusion].length > 1){
            exclusionAreas[activeExclusion].remove(exclusionAreas[activeExclusion].points[activeNode]);
            if(activeNode == exclusionAreas[activeExclusion].length) activeNode--;
        }
        else if(Key.isDown(Key.SHIFT)){
            if(Key.isPressed(Key.MOUSE_WHEEL_UP) || Key.isPressed(Key.NUMBER_2)){
                activeExclusion = (activeExclusion + 1) % exclusionAreas.length;
            }
            else if(Key.isPressed(Key.MOUSE_WHEEL_DOWN) || Key.isPressed(Key.NUMBER_1)){
                activeExclusion = (exclusionAreas.length + activeExclusion - 1) % exclusionAreas.length;
            }
        }
        else if(Key.isPressed(Key.MOUSE_WHEEL_UP) || Key.isPressed(Key.NUMBER_2)){
            activeNode = (activeNode + 1) % exclusionAreas[activeExclusion].length;
        }
        else if(Key.isPressed(Key.MOUSE_WHEEL_DOWN) || Key.isPressed(Key.NUMBER_1)){
            activeNode = (exclusionAreas[activeExclusion].length + activeNode - 1) % exclusionAreas[activeExclusion].length;
        }
        else if(Key.isPressed(Key.F)){
            exclusionAreas[activeExclusion].reverse();
        }
        else if(Key.isPressed(Key.ENTER)){
            exportExclusionArea(exclusionAreas);
        }
        
        drawWalkAreaLines(room, exclusionAreas[activeExclusion], 0x00FFFF);
        room.drawer.lineStyle(1, color);
        room.drawer.drawRect(exclusionAreas[activeExclusion].points[activeNode].x-1, exclusionAreas[activeExclusion].points[activeNode].y-1, 3, 3);
    }
    
    public static function drawWalkArea(room: loom.Room, walkArea: Polygon, exclusionAreas: Array<Polygon> = null, mode: Int = 0x111111, clear: Bool = true){
        if(mode & 0x100000 == 0x100000 && exclusionAreas != null) drawExclusionAreaPoints(room, exclusionAreas, clear);
        if(mode & 0x010000 == 0x010000 && exclusionAreas != null) drawExclusionAreaLines(room, exclusionAreas);
        if(mode & 0x001000 == 0x001000 && exclusionAreas != null) drawExclusionAreaConvexPoints(room, exclusionAreas);
        if(mode & 0x000100 == 0x000100) drawWalkAreaLines(room, walkArea);
        if(mode & 0x000010 == 0x000010) drawWalkAreaPoints(room, walkArea);
        if(mode & 0x000001 == 0x000001) drawWalkAreaConcavePoints(room, walkArea);
    }

    private static function drawWalkAreaLines(room: loom.Room, walkArea:Polygon, color: Color = 0xFF0000, clear: Bool = false){
        if(clear) room.drawer.clear();
        room.drawer.lineStyle(1, color);
        
        if(walkArea.points.length > 1){
            room.drawer.moveTo(walkArea.points[0].x, walkArea.points[0].y);
            
            for(i in 1...walkArea.points.length){
                room.drawer.lineTo(walkArea.points[i].x, walkArea.points[i].y);
            }
        }
        if(walkArea.points.length > 2) room.drawer.lineTo(walkArea.points[0].x, walkArea.points[0].y);
    }
    
    private static function drawExclusionAreaLines(room: loom.Room, exclusionAreas:Array<Polygon>, color: Color = 0x00FFFF, clear: Bool = false){
        if(clear) room.drawer.clear();
        room.drawer.lineStyle(1, color);
        
        if(exclusionAreas.length > 0){
            for(area in exclusionAreas){
                if(area.points.length > 1){
                    room.drawer.moveTo(area.points[0].x, area.points[0].y);
                    
                    for(i in 1...area.points.length){
                        room.drawer.lineTo(area.points[i].x, area.points[i].y);
                    }
                }
                if(area.points.length > 2) room.drawer.lineTo(area.points[0].x, area.points[0].y);
            }
        }
    }

    private static function drawWalkAreaPoints(room: loom.Room, walkArea:Polygon, color: Color = 0x00FF00, clear: Bool = false){
        if(clear) room.drawer.clear();
        
        room.drawer.lineStyle(1, color);
        for (point in walkArea.points){
            room.drawer.drawRect(point.x-1, point.y-1, 3, 3);
        }
    }
    
    private static function drawExclusionAreaPoints(room: loom.Room, exclusionAreas:Array<Polygon>, color: Color = 0x00FF00, clear: Bool = false){
        if(clear) room.drawer.clear();
        
        room.drawer.lineStyle(1, color);
        for (area in exclusionAreas){
            for (point in area.points){
                room.drawer.drawRect(point.x-1, point.y-1, 3, 3);
            }
        }
    }
    
    private static function drawWalkAreaConcavePoints(room: loom.Room, walkArea:Polygon, color: Color = 0xFFFFFF, clear: Bool = false){
        if(clear) room.drawer.clear();
        var concavePoints = Math.getConcavePoints(walkArea.points);
        room.drawer.lineStyle(1, color);
        for (p in concavePoints){
            room.drawer.drawRect(p.x-2, p.y-2, 5, 5);
        }
    }
    
    private static function drawExclusionAreaConvexPoints(room: loom.Room, exclusionAreas:Array<Polygon>, color: Color = 0xFFFFFF, clear: Bool = false){
        if(clear) room.drawer.clear();

        room.drawer.lineStyle(1, color);
        for(area in exclusionAreas){
            var convexPoints = Math.getConvexPoints(area.points);
            for (p in convexPoints){
                room.drawer.drawRect(p.x-2, p.y-2, 5, 5);
            }
        }
    }

    public static function exportWalkArea(walkArea:Polygon){
        var exportMessage = "====\n==== WALK AREA POLYGONS ====\n";
        for (point in walkArea.points){
            exportMessage += '        {x: ${point.x}, y: ${point.y}},\n';
        }
        exportMessage += "==== ==== ==== ====";
        trace(exportMessage);
    }
    
    public static function exportExclusionArea(exclusionAreas:Array<Polygon>){
        var exportMessage = "====\n==== EXCLUSION AREA POLYGONS ====\n";
        for (area in exclusionAreas){
            exportMessage += "        [\n";
            for (point in area.points){
                exportMessage += '            {x: ${point.x}, y: ${point.y}},\n';
            }
            exportMessage += "        ],\n";
        }
        exportMessage += "==== ==== ==== ====";
        trace(exportMessage);
    }
    #end
}