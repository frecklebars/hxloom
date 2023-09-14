package loom.utils;

using loom.math.MathExtensions;

class RoomUtils {

    #if debug
    static var placing: Bool = true;
    static var placedPoints: Array<h2d.col.Point> = [];
    static var activeNode: Int = 0;

    public static function placeWalkArea(room: loom.Room){
        if(!placing){
            editWalkArea(room, placedPoints);
            return;
        }

        if(hxd.Key.isPressed(hxd.Key.MOUSE_LEFT) && placing){
            placedPoints.push(new h2d.col.Point(Std.int(room.mouseX), Std.int(room.mouseY)));
        }
        else if(hxd.Key.isPressed(hxd.Key.ENTER)){
            placing = false;
            return;
        }

        // draw
        room.drawer.clear();
        room.drawer.lineStyle(1, 0xFF0000);
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
        room.drawer.drawRect(Std.int(room.mouseX)-1, Std.int(room.mouseY)-1, 3, 3);
    }
    
    public static function editWalkArea(room: loom.Room, walkArea: h2d.col.Polygon, color: Color = 0xFF0000){
        // draw
        drawWalkAreaLines(room, walkArea, 0x0000FF);
        drawWalkAreaPoints(room, walkArea);

        if(hxd.Key.isDown(hxd.Key.MOUSE_LEFT)){
            walkArea.points[activeNode].set(Std.int(room.mouseX), Std.int(room.mouseY));
        }
        else if(hxd.Key.isPressed(hxd.Key.MOUSE_RIGHT)){
            walkArea.insert(activeNode, new h2d.col.Point(Std.int(room.mouseX), Std.int(room.mouseY)));
        }
        else if(hxd.Key.isPressed(hxd.Key.BACKSPACE) && walkArea.length > 1){
            walkArea.remove(walkArea.points[activeNode]);
            if(activeNode == walkArea.length) activeNode--;
        }
        else if(hxd.Key.isPressed(hxd.Key.MOUSE_WHEEL_UP) || hxd.Key.isPressed(hxd.Key.NUMBER_2)){
            activeNode = (activeNode + 1) % walkArea.length;
        }
        else if(hxd.Key.isPressed(hxd.Key.MOUSE_WHEEL_DOWN) || hxd.Key.isPressed(hxd.Key.NUMBER_1)){
            activeNode = (walkArea.length + activeNode - 1) % walkArea.length;
        }
        else if(hxd.Key.isPressed(hxd.Key.ENTER)){
            exportWalkArea(walkArea);
        }
        
        room.drawer.lineStyle(1, color);
        room.drawer.drawRect(walkArea.points[activeNode].x-1, walkArea.points[activeNode].y-1, 3, 3);


    }
    
    public static function drawWalkArea(room: loom.Room, walkArea: h2d.col.Polygon, mode: Int = 0x111){
        if(mode & 0x100 == 0x100) drawWalkAreaLines(room, walkArea);
        if(mode & 0x010 == 0x010) drawWalkAreaPoints(room, walkArea);
        if(mode & 0x001 == 0x001) drawWalkAreaConcavePoints(room, walkArea);
    }

    private static function drawWalkAreaLines(room: loom.Room, walkArea:h2d.col.Polygon, color: Color = 0xFF0000, clear: Bool = true){
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

    private static function drawWalkAreaPoints(room: loom.Room, walkArea:h2d.col.Polygon, color: Color = 0x00FF00, clear: Bool = false){
        if(clear) room.drawer.clear();
        
        room.drawer.lineStyle(1, color);
        for (point in walkArea.points){
            room.drawer.drawRect(point.x-1, point.y-1, 3, 3);
        }
    }
    
    private static function drawWalkAreaConcavePoints(room: loom.Room, walkArea:h2d.col.Polygon, color: Color = 0xFFFFFF, invert: Bool = false, clear: Bool = false){
        if(clear) room.drawer.clear();
        
        var concavePoints = Math.getConcavePoints(walkArea.points, invert);
        room.drawer.lineStyle(1, color);
        for (p in concavePoints){
            room.drawer.drawRect(p.x-2, p.y-2, 5, 5);
        }
    }
    
    private static function drawWalkAreaConvexPoints(room: loom.Room, walkArea:h2d.col.Polygon, color: Color = 0xFFFFFF, clear: Bool = false){
        drawWalkAreaConcavePoints(room, walkArea, color, true, clear);
    }

    public static function exportWalkArea(walkArea:h2d.col.Polygon){
        var exportMessage = "====\n==== WALK AREA POLYGONS ====\n";
        for (point in walkArea.points){
            exportMessage += '        {x: ${point.x}, y: ${point.y}},\n';
        }
        exportMessage += "==== ==== ==== ====";
        trace(exportMessage);
    }
    #end
}