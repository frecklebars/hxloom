package loom.adventure.movement;

import h2d.col.Point;
import h2d.col.Polygon;
import hxd.Key;

using loom.math.MathExtensions;

#if debug
import loom.graphic.Color;
#end

class AstarNode {
    public var point: Point;
    public var x(get, set): Int;
    public var y(get, set): Int;

    public var id: Int;
    public var neighbors: Array<{id: Int, distance: Float}> = [];

    public var parent: Int = -1;

    public var distanceFromStart: Float = 999_999_999;
    public var distanceToGoal: Float = 999_999_999;
    public var cost(get, null): Float;

    public function new(id: Int, x: Int, y: Int){
        this.point = new Point(x, y);
        this.id = id;
    }

    function set_x(val: Int): Int {
        point.x = val;
        return Std.int(point.x);
    }

	function get_x(): Int {
		return Std.int(point.x);
	}
    
    function set_y(val: Int): Int {
        point.y = val;
        return Std.int(point.y);
    }

	function get_y(): Int {
		return Std.int(point.y);
	}

    function get_cost(): Float {
        return distanceFromStart + distanceToGoal;
    }
}

class PointAndClickMovement implements Component {
    #if debug
    public var DEBUG_DRAW: Bool = false;
    #end

    public var name: String;
    public var parent: loom.Object;
	public var enabled:Bool = true;

    private var room: loom.Room;

    private var nodeSpacingW: Int = 3;
    private var nodeSpacingH: Int = 3;
    private var nodesW: Int;
    private var nodesH: Int;

    private var graph: Array<AstarNode> = [];
    private var graphIds: Array<Int> = [];
    private var graphIdsMap: Map<Int, Int> = [];

    private var start: AstarNode;
    private var goal: AstarNode;
    private var openNodes: Array<AstarNode> = [];
    private var visitedNodes: Array<AstarNode> = [];
    private var current: AstarNode;
    private var path: Array<AstarNode> = [];

    public var walking: Bool = false;
    public var speed: Float = 60;
    public var speedModX: Float = 1;
    public var speedModY: Float = 0.8;

    private var reachedNextPoint: Bool = true;
    private var nextWalkingPoint: Point;
    public var walkingDirection: Point = new Point(0, 0);
    
    public function onChangeRoom(newRoom: loom.Room, oldRoom: loom.Room){
        if(!enabled) return;
        this.room = newRoom;
        makePathfindingGrid();
    }

    public function new(parent: loom.Object, ?speed: Float){
        this.parent = parent;
        if(speed != null) this.speed = speed;

        parent.onChangeRoomCalls.push(onChangeRoom);
        this.room = parent.room;
    }


    public function makePathfindingGrid(){
        nodesW = Math.floor(room.roomW / nodeSpacingW - 1);
        nodesH = Math.floor(room.roomH / nodeSpacingW - 1);

        graph = [];
        graphIds = [];

        for(i in 0...nodesH){
            for(j in 0...nodesW){
                var nodeAlive: Bool = true;
                var nodeId = j + i * nodesW;
                var node = new AstarNode(nodeId, nodeSpacingW * (j+1), nodeSpacingH * (i+1));

                if(!room.walkArea.contains(node.point)) continue;
                for(ea in room.exclusionAreas){
                    if(ea.contains(node.point)){
                        nodeAlive = false;
                        break;
                    }
                }

                if(nodeAlive){
                    graph.push(node);
                    graphIds.push(nodeId);
                }
                else continue;

                // connect node to NW, N, NE, W if they exist
                var neighbor: AstarNode;
                var neighborId: Int;

                if(i > 0){
                    // NW
                    neighborId = (j - 1) + (i - 1) * nodesW;
                    if(j > 0 && graphIds.contains(neighborId)){
                        neighbor = findNodeById(neighborId);
                        neighbor.neighbors.push({id: nodeId, distance: 14});
                        node.neighbors.push({id: neighborId, distance: 14});
                    }
                    // N
                    neighborId = j + (i - 1) * nodesW;
                    if(graphIds.contains(neighborId)){
                        neighbor = findNodeById(neighborId);
                        neighbor.neighbors.push({id: nodeId, distance: 10});
                        node.neighbors.push({id: neighborId, distance: 10});
                    }
                    // NE
                    neighborId = (j + 1) + (i - 1) * nodesW;
                    if(j + 1 < nodesW && graphIds.contains(neighborId)){
                        neighbor = findNodeById(neighborId);
                        neighbor.neighbors.push({id: nodeId, distance: 14});
                        node.neighbors.push({id: neighborId, distance: 14});
                    }
                }
                // W
                neighborId = (j - 1) + i * nodesW;
                if(j > 0 && graphIds.contains(neighborId)){
                    neighbor = findNodeById(neighborId);
                    neighbor.neighbors.push({id: nodeId, distance: 10});
                    node.neighbors.push({id: neighborId, distance: 10});
                }
                
            }
        }

        // remap to make the id of each node its index in the graph array
        graphIdsMap = [];
        for(i in 0...graphIds.length){
            graphIdsMap.set(graphIds[i], i);
        }

        for(node in graph){
            node.id = graphIdsMap[node.id];
            node.neighbors = [
                for(n in node.neighbors) 
                    {id: graphIdsMap[n.id], distance: n.distance}
            ];
        }
    }

    private function findNodeById(nodeId: Int): AstarNode{
        for(node in graph){
            if(node.id == nodeId) return node;
        }
        return null;
    }

    // feels kinda hacky but eh, works. should eventually profile it
    // curious how it fares against the old id guessing method
    private function findNodesAroundPoint(point: Point): Array<AstarNode> {
        var neighbors: Array<AstarNode> = [];
        var closestPoint: AstarNode = null;
        var closestPointDistance: Float = 999_999_999;

        var searchArea: Polygon = [
            new Point(point.x - nodeSpacingW, point.y - nodeSpacingH),
            new Point(point.x + nodeSpacingW, point.y - nodeSpacingH),
            new Point(point.x + nodeSpacingW, point.y + nodeSpacingH),
            new Point(point.x - nodeSpacingW, point.y + nodeSpacingH),
        ];

        for(node in graph){
            if(searchArea.contains(node.point)){
                neighbors.push(node);
            }
            else if(point.distance(node.point) < closestPointDistance){
                closestPoint = node;
                closestPointDistance = point.distance(node.point);
            }
        }

        if(neighbors.length == 0) neighbors.push(closestPoint);

        return neighbors;
    }

    private function getGoal(mouseX: Float, mouseY: Float): Point{
        var clickPoint: Point = new Point(mouseX, mouseY);
    
        if(room.walkArea.contains(clickPoint)){
            for(ea in room.exclusionAreas){
                if(ea.contains(clickPoint)){
                    clickPoint = ea.projectPoint(clickPoint);
                    clickPoint.x = Std.int(clickPoint.x);
                    clickPoint.y = Std.int(clickPoint.y);
                    return clickPoint;
                }
            }
            clickPoint.x = Std.int(clickPoint.x);
            clickPoint.y = Std.int(clickPoint.y);
            return clickPoint;
        }

        clickPoint = room.walkArea.projectPoint(clickPoint);
        clickPoint.x = Std.int(clickPoint.x);
        clickPoint.y = Std.int(clickPoint.y);
        return clickPoint;
    }

    private function pathfind(goalX: Int, goalY: Int): Array<AstarNode> {
        visitedNodes = [];

        // TODO late may want the startpoint to actually project to walkarea edges, if outside it
        start = new AstarNode(graph.length, Std.int(parent.x), Std.int(parent.y)); 
        goal = new AstarNode(graph.length + 1, goalX, goalY);
        
        if(Math.pointsInLineOfSight([room.walkArea].concat(room.exclusionAreas), start.point, goal.point)){
            return [goal]; // path is directly to goal
        }

        var startNeighbors: Array<AstarNode> = findNodesAroundPoint(start.point);
        for(startNeighbor in startNeighbors){
            var dist: Float = startNeighbor.point.distanceSq(start.point);
            start.neighbors.push({id: startNeighbor.id, distance: dist});
            startNeighbor.neighbors.push({id: start.id, distance: dist});
        }
        start.distanceFromStart = 0;

        var goalNeighbors: Array<AstarNode> = findNodesAroundPoint(goal.point);
        for(goalNeighbor in goalNeighbors){
            var dist: Float = goalNeighbor.point.distanceSq(goal.point);
            goal.neighbors.push({id: goalNeighbor.id, distance: dist});
            goalNeighbor.neighbors.push({id: goal.id, distance: dist});
        }

        graph.push(start);
        graph.push(goal);

        openNodes = [start];

        while(openNodes.length > 0){
            haxe.ds.ArraySort.sort(openNodes, function(a, b): Int {
                return Std.int(a.cost - b.cost);
            });

            current = openNodes.shift();

            if(current == goal) break;

            visitedNodes.push(current);

            for(neighbor in current.neighbors){
                var neighborNode: AstarNode = graph[neighbor.id];
                if(visitedNodes.contains(neighborNode)) continue;

                var tentativeCost: Float = current.distanceFromStart + neighbor.distance;

                if(neighborNode.distanceFromStart > tentativeCost || !openNodes.contains(neighborNode)){
                    neighborNode.distanceFromStart = tentativeCost;
                    neighborNode.parent = current.id;

                    if(!openNodes.contains(neighborNode)){
                        openNodes.push(neighborNode);
                    }
                }
            }
        }

        // remove edges to start and goal
        for (startNeighbor in startNeighbors){
            startNeighbor.neighbors.pop();
        }
        for (goalNeighbor in goalNeighbors){
            goalNeighbor.neighbors.pop();
        }
        // remove goal and start
        graph.pop();
        graph.pop();

        // get path

        var path: Array<AstarNode> = [goal];
        while(path[0].parent != -1){
            if(path[0].parent == graph.length) break; // id of start node found

            path.insert(0, graph[path[0].parent]);
        }
        
        return path;
    }

    
    private function walkAlongPath(parent: loom.Object, path: Array<AstarNode>, dt: Float): Bool{
        if(reachedNextPoint){
            if(path.length > 0){
                nextWalkingPoint = path.shift().point;
                var parentPoint = new Point(parent.x, parent.y);
                walkingDirection = Math.getDirection(parentPoint, nextWalkingPoint, speedModX, speedModY);
                reachedNextPoint = walkToPoint(parent, nextWalkingPoint, dt);
            }
            else return false;
        }
        else{
            reachedNextPoint = walkToPoint(parent, nextWalkingPoint, dt);
        }

        return true;
    }

    
    private function walkToPoint(parent: loom.Object, point: Point, dt: Float): Bool{
        var parentPoint: Point = new Point(parent.x, parent.y);
        var distance = parentPoint.distanceSq(point);

        if(distance <= 2){
            return true;
        }
        else{
            parent.x += (walkingDirection.x * speed * speedModX * dt);
            parent.y += (walkingDirection.y * speed * speedModY * dt);
        }

        return false;
    }

    public function init(){}
    public function update(dt:Float){
        #if debug
        if(DEBUG_DRAW){
            if(Key.isPressed(Key.W) && Key.isDown(Key.SHIFT)) makePathfindingGrid();
            debugDraw(true, false, true); 
        }
        #end

        if(Key.isPressed(Key.MOUSE_LEFT)){
            var goalPoint: Point = getGoal(room.mouseX, room.mouseY);
            path = pathfind(Std.int(goalPoint.x), Std.int(goalPoint.y));
            walking = true;
            reachedNextPoint = true;
        }

        if(walking){
            walking = walkAlongPath(parent, path, dt);
        }
    }
    
    #if debug
    private function debugDraw(?drawNodes: Bool = true, ?drawEdges: Bool = true, ?drawPath: Bool = true){
        var drawer: h2d.Graphics = room.editor.drawer;
        drawer.clear();

        room.editor.drawArea(true, true, false);
        
        if(drawEdges){
            drawer.lineStyle(1, Color.GRAY);
            for(node in graph){
                for(neighbor in node.neighbors){
                    drawer.moveTo(node.x, node.y);
                    var nn: AstarNode = findNodeById(neighbor.id);
                    drawer.lineTo(nn.x, nn.y);
                }
            }
            drawer.lineStyle(1, Color.GREEN);
            if(start != null){
                drawer.moveTo(start.x, start.y);
                for(n in start.neighbors){
                    var neighbor = graph[n.id];
                    drawer.lineTo(neighbor.x, neighbor.y);
                    drawer.lineTo(start.x, start.y);
                }
            }
            if(goal != null){
                drawer.moveTo(goal.x, goal.y);
                for(n in goal.neighbors){
                    var neighbor = graph[n.id];
                    drawer.lineTo(neighbor.x, neighbor.y);
                    drawer.lineTo(goal.x, goal.y);
                }
            }
        }
        if(drawNodes){
            drawer.lineStyle(1, Color.WHITE);
            for(node in graph){
                // drawer.drawRect(node.x - 1, node.y - 1, 3, 3);
                drawer.drawRect(node.x, node.y, 1, 1);
            }
        }
        if(drawPath){
            drawer.lineStyle(1, Color.MAGENTA);
            if(start != null){
                drawer.moveTo(start.x, start.y);
                for(p in path){
                    drawer.lineTo(p.x, p.y);
                }
            }
        }
    }
    #end
}