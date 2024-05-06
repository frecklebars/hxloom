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
                editMenuString += "===========  EDIT WALK AREA ===========\n";
                editMenuString += "==== SPACE       : Export =============\n";
                editMenuString += "==== SCROLL      : Change Nodes =======\n";
                editMenuString += "==== R-CLICK     : Add Node ===========\n";
                editMenuString += "==== L-CLICK     : Move Node ==========\n";
                editMenuString += "==== BACKSPACE   : Remove Node ========\n";
                editMenuString += "==== TAB         : Change Walk ========\n";
                editMenuString += "====                 or Excl ==========\n";
                editMenuString += "==== SHIFT+ ===========================\n";
                editMenuString += "====   R-CLICK   : Add Excl Area ======\n";
                editMenuString += "====   SCROLL    : Change Excl Area ===\n";
                editMenuString += "====   BACKSPACE : Remove Excl Area ===\n";
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
    private var modifyExclusions: Bool = false;
    private var activeExclusion: Int = 0;
    
    private function update_WalkAreaMode(dt: Float){
        var mouseX: Int = Std.int(room.mouseX);
        var mouseY: Int = Std.int(room.mouseY);
        
        drawer.clear();
        
        drawArea();
        
        drawer.lineStyle(1, Color.WHITE);
        drawer.drawRect(mouseX-1, mouseY-1, 3, 3);

        if(Key.isPressed(Key.TAB)){
            modifyExclusions = !modifyExclusions;
            activeNode = 0;
            activeExclusion = 0;
        }

        // modify exclusion areas
        if(modifyExclusions){ 
            if(Key.isPressed(Key.SPACE)){ // export
                exportExclArea(room.exclusionAreas);
            }
            else if(Key.isDown(Key.SHIFT)){
                if(Key.isPressed(Key.MOUSE_RIGHT)){
                    var newExclArea: h2d.col.Polygon = [];
                    newExclArea.push(new h2d.col.Point(mouseX, mouseY));
                    room.exclusionAreas.push(newExclArea);
                    activeExclusion = room.exclusionAreas.length - 1;
                    activeNode = 0;
                }
                else if(room.exclusionAreas.length > 0){
                    if(Key.isPressed(Key.MOUSE_WHEEL_DOWN)){
                        activeNode = 0;
                        activeExclusion -= 1;
                        activeExclusion = (activeExclusion + room.exclusionAreas.length) % room.exclusionAreas.length;
                    }
                    else if(Key.isPressed(Key.MOUSE_WHEEL_UP)){
                        activeNode = 0;
                        activeExclusion += 1;
                        activeExclusion = activeExclusion % room.exclusionAreas.length;
                    }
                    else if(Key.isPressed(Key.BACKSPACE)){
                        room.exclusionAreas.remove(room.exclusionAreas[activeExclusion]);
                        if(activeExclusion == room.exclusionAreas.length) activeExclusion -= 1;
                    }
                }
            }
            else if(room.exclusionAreas.length > 0){
                areaOperation(room.exclusionAreas[activeExclusion], mouseX, mouseY);
            }
            
        }
        // modify walk area itself
        else{ 
            if(Key.isPressed(Key.SPACE)){ // export
                if(!room.walkArea.isClockwise()){
                    room.walkArea.reverse();
                }
                exportWalkArea(room.walkArea);
            }
            else{
                areaOperation(room.walkArea, mouseX, mouseY);
            }
        }
    }

    private function areaOperation(area: h2d.col.Polygon, mouseX: Int, mouseY: Int){
        if(Key.isPressed(Key.MOUSE_RIGHT)){
            placeNode(area, mouseX, mouseY, activeNode);
        }
        else if(area.length > 0){
            if(Key.isPressed(Key.MOUSE_LEFT)){
                area[activeNode].x = mouseX;
                area[activeNode].y = mouseY;
            }
            else if(Key.isPressed(Key.BACKSPACE)){
                area.remove(area[activeNode]);
                if(activeNode == area.length) activeNode -= 1;
            }
            else if(Key.isPressed(Key.MOUSE_WHEEL_DOWN)){
                activeNode -= 1;
                activeNode = (activeNode + area.length) % area.length;
            }
            else if(Key.isPressed(Key.MOUSE_WHEEL_UP)){
                activeNode += 1;
                activeNode = activeNode % area.length;
            }
        }
    }

    private function drawArea(?drawWalkArea: Bool = true, ?drawExclusionArea: Bool = true){
        if(drawWalkArea){
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
                    if(!modifyExclusions && pi == activeNode ){
                        drawer.drawRect(room.walkArea[pi].x - 2, room.walkArea[pi].y - 2, 5, 5);
                    }
                }
            }
        }

        if(drawExclusionArea){
            for(ea_i in 0...room.exclusionAreas.length){
                var exclusionArea: h2d.col.Polygon = room.exclusionAreas[ea_i];

                // draw Lines
                drawer.lineStyle(1, Color.BLUE);
                if(exclusionArea.length > 1){
                    drawer.moveTo(exclusionArea[0].x, exclusionArea[0].y);
    
                    for (pi in 1...exclusionArea.length){
                        drawer.lineTo(exclusionArea[pi].x, exclusionArea[pi].y);
                    }
                    
                    drawer.lineTo(exclusionArea[0].x, exclusionArea[0].y);
                }
                
                // draw Nodes
                drawer.lineStyle(1, Color.WHITE);
                if(exclusionArea.length > 0){
                    for (pi in 0...exclusionArea.length){
                        drawer.drawRect(exclusionArea[pi].x - 1, exclusionArea[pi].y - 1, 3, 3);
                        if(modifyExclusions && activeExclusion == ea_i && pi == activeNode){
                            drawer.drawRect(exclusionArea[pi].x - 2, exclusionArea[pi].y - 2, 5, 5);
                        }
                    }
                }
            }
        }
    }

    private function placeNode(area: h2d.col.Polygon, mouseX: Int, mouseY: Int, ?index: Int = 0){
        var newPoint: h2d.col.Point = new h2d.col.Point(mouseX, mouseY);
        if(area.length <= 1 || index == area.length - 1){
            area.push(newPoint);
        }
        else{
            area.insert(index+1, newPoint);
        }

        activeNode += 1;
        activeNode = activeNode % area.length;
    }

    private function exportWalkArea(wa: h2d.col.Polygon){
        var exportedArea: String = "\n\nwalkArea: [\n";
        for(p in wa){
            exportedArea += '    {x: ${p.x}, y: ${p.y}},\n';
        }
        exportedArea += ']';
        trace(exportedArea);
    }

    private function exportExclArea(eas: Array<h2d.col.Polygon>){
        var exportedArea: String = "\n\nexclusionAreas: [\n";
        for(ea in eas){
            exportedArea += "    [\n";
            for(p in ea){
                exportedArea += '        {x: ${p.x}, y: ${p.y}},\n';
            }
            exportedArea += "    ],\n";
        }
        exportedArea += "]";
        trace(exportedArea);
    }
}