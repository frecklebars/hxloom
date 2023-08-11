package loom.utils;

typedef Margins = {top: Int, bottom: Int, left: Int, right: Int}

class CameraConfig {
    public var room: Room;
    public var camera: h2d.Camera;
    public var focus: Entity;
    
    public var margins: Margins;

    #if debug
    public var drawer: h2d.Graphics;
    #end

    public function new(room: Room, focus: Entity, ?margins: Margins){
        this.room = room;
        this.camera = room.camera;
        this.focus = focus;

        if(margins == null) this.margins = {top: 0, bottom: 0, left: 0, right: 0};
        else                this.margins = margins;
        #if debug
        this.drawer = new h2d.Graphics(room);
        #end
    }
}


class CameraUtils {
    
    /**
        Moves with player if player attempts to go outside bounds.
    
        @param cc Camera Config. Uses margins as bounds.
    **/
    public static function boundedFollowPlayer(cc: CameraConfig) {

        var maxX = cc.room.roomWidth;
        var maxY = cc.room.roomHeight;

        var targetPosRelToCamera = new h2d.col.Point(cc.focus.x, cc.focus.y);
        cc.camera.cameraToScene(targetPosRelToCamera);

        // x axis
        if(targetPosRelToCamera.x < cc.margins.left && cc.camera.x > 0){
            cc.camera.x -= cc.margins.left - targetPosRelToCamera.x;
        }
        else if(targetPosRelToCamera.x > cc.camera.viewportWidth - cc.margins.right && cc.camera.x + cc.camera.viewportWidth < maxX){
            cc.camera.x += targetPosRelToCamera.x - (cc.camera.viewportWidth - cc.margins.right);
        }

        // y axis
        if(targetPosRelToCamera.y < cc.margins.top && cc.camera.y > 0){
            cc.camera.y -= cc.margins.top - targetPosRelToCamera.y;
        }
        else if(targetPosRelToCamera.y > cc.camera.viewportHeight - cc.margins.bottom && cc.camera.y + cc.camera.viewportHeight< maxY){
            cc.camera.y += targetPosRelToCamera.y - (cc.camera.viewportHeight - cc.margins.bottom);
        }

        // camera.x = -Std.int(camera.viewportWidth * 0.5) + player.x;
        // camera.y = -Std.int(camera.viewportHeight * 0.5) + player.y - 20;
    }

    #if debug
    public static function drawMargins(cc: CameraConfig){
        cc.drawer.clear();
        cc.drawer.lineStyle(1, 0xFF0000);

        cc.drawer.moveTo(cc.camera.x + cc.margins.left,                            cc.camera.y);
        cc.drawer.lineTo(cc.camera.x + cc.margins.left,                            cc.camera.y + cc.camera.viewportHeight);
        cc.drawer.moveTo(cc.camera.x + cc.camera.viewportWidth - cc.margins.right, cc.camera.y);
        cc.drawer.lineTo(cc.camera.x + cc.camera.viewportWidth - cc.margins.right, cc.camera.y + cc.camera.viewportHeight);
        
        cc.drawer.moveTo(cc.camera.x                          , cc.camera.y + cc.margins.top);
        cc.drawer.lineTo(cc.camera.x + cc.camera.viewportWidth, cc.camera.y + cc.margins.top);
        cc.drawer.moveTo(cc.camera.x                          , cc.camera.y + cc.camera.viewportHeight - cc.margins.bottom);
        cc.drawer.lineTo(cc.camera.x + cc.camera.viewportWidth, cc.camera.y + cc.camera.viewportHeight - cc.margins.bottom);
    }
    #end
}