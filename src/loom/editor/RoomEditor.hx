package loom.editor;

import hxd.Key;

import loom.Room;
import loom.graphic.Color;

using loom.math.MathExtensions;


enum RoomEditorMode {
    Inactive; // off
    Select; // on, waiting mode select

    WalkArea;
}


class RoomEditor{
    private var room: Room;

    public var EDIT_MODE: RoomEditorMode = Inactive;

    public var drawer: h2d.Graphics;
    public var textOutput: h2d.Text;

    public function new(room: Room){
        this.room = room;
        drawer = new h2d.Graphics();
    }

    private function changeEditMode(em: RoomEditorMode){
        drawer.moveTo(0, 0);
        drawer.clear();

        EDIT_MODE = em;
        trace('EDIT MODE: $EDIT_MODE');

        printEditMenu(em);
    }

    public function toggleEditor(){
        if(EDIT_MODE != Inactive) changeEditMode(Inactive);
        else                      changeEditMode(Select);
    }

    private function printEditMenu(em: RoomEditorMode){
        var editMenuString: String = "\n\n";

        switch(em){
            case Select: {
                editMenuString += "======== EDITOR MODE ========\n";
                editMenuString += "==== 1 : Edit Walk Area =====\n";
            }

            case WalkArea: {
                editMenuString += "========  EDIT WALK AREA ========\n";
                // editMenuString += "==== \n"
            }

            default: return;
        }

        trace(editMenuString);
    }

    // ====================================
    // ============   UPDATE   ============
    // ====================================

    public function update(dt: Float){
        switch (EDIT_MODE){
            case Select:   update_SelectMode(dt);
            case WalkArea: update_WalkAreaMode(dt);

            default: return;
        }
    }

    // ====================================
    // ============   SELECT   ============
    // ====================================
    
    public function update_SelectMode(dt: Float){
        if(Key.isDown(Key.NUMBER_1)){
            changeEditMode(WalkArea);
        }
    }
    
    // =======================================
    // ============   WALK AREA   ============
    // =======================================

    private function printEditMenu_WalkArea(){
        var editMenuString: String = "\n\n";
        editMenuString += "======== EDITOR MODE ========\n";
        editMenuString += "==== 1 : Edit Walk Area =====\n";

        trace(editMenuString);
    }

    private var activeNode: Int = 0;
    
    private function update_WalkAreaMode(dt: Float){
        var mouseX: Int = Std.int(room.mouseX);
        var mouseY: Int = Std.int(room.mouseY);
        
        drawer.clear();
        
        drawWalkArea();
        
        drawer.lineStyle(1, Color.WHITE);
        drawer.drawRect(mouseX-1, mouseY-1, 3, 3);
        
        if(Key.isPressed(Key.SPACE)){ // export
            if(!room.walkArea.isClockwise()){
                room.walkArea.reverse();
            }
            exportWalkArea(room.walkArea);
        }
        else if(Key.isPressed(Key.MOUSE_RIGHT)){
            placeNode(mouseX, mouseY, activeNode);
        }
        else if(room.walkArea.length > 0){
            if(Key.isPressed(Key.MOUSE_LEFT)){
                room.walkArea[activeNode].x = mouseX;
                room.walkArea[activeNode].y = mouseY;
            }
            else if(Key.isPressed(Key.BACKSPACE)){
                room.walkArea.remove(room.walkArea[activeNode]);
                if(activeNode == room.walkArea.length) activeNode -= 1;
            }
            else if(Key.isPressed(Key.MOUSE_WHEEL_DOWN)){
                activeNode -= 1;
                activeNode = (activeNode + room.walkArea.length) % room.walkArea.length;
            }
            else if(Key.isPressed(Key.MOUSE_WHEEL_UP)){
                activeNode += 1;
                activeNode = activeNode % room.walkArea.length;
            }
        }
    }

    private function drawWalkArea(){
        // draw Lines
        drawer.lineStyle(1, Color.RED);
        if(room.walkArea.length > 1){
            drawer.moveTo(room.walkArea[0].x, room.walkArea[0].y);

            for (pi in 1...room.walkArea.length){
                drawer.lineTo(room.walkArea[pi].x, room.walkArea[pi].y);
            }

            drawer.lineTo(room.walkArea[0].x, room.walkArea[0].y);
        }

        // draw Nodes
        drawer.lineStyle(1, Color.WHITE);
        if(room.walkArea.length > 0){
            for (pi in 0...room.walkArea.length){
                drawer.drawRect(room.walkArea[pi].x - 1, room.walkArea[pi].y - 1, 3, 3);
                if(pi == activeNode)
                    drawer.drawRect(room.walkArea[pi].x - 2, room.walkArea[pi].y - 2, 5, 5);
            }
        }
    }

    private function placeNode(mouseX: Int, mouseY: Int, ?index: Int = 0){
        var newPoint: h2d.col.Point = new h2d.col.Point(mouseX, mouseY);
        if(room.walkArea.length <= 1 || index == room.walkArea.length - 1){
            room.walkArea.push(newPoint);
        }
        else{
            room.walkArea.insert(index+1, newPoint);
        }

        activeNode += 1;
        activeNode = activeNode % room.walkArea.length;
    }

    private function exportWalkArea(wa: h2d.col.Polygon){
        var exportedArea: String = "\n\nwalkArea: [\n";
        for(p in wa){
            exportedArea += '    {x: ${p.x}, y: ${p.y}},\n';
        }
        exportedArea += ']';
        trace(exportedArea);
    }
}