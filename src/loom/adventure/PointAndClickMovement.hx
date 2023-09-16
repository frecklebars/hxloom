package loom.adventure;

using hxd.Key;
using loom.math.MathExtensions;

using h2d.col.Polygon;
using h2d.col.Point;

class AstarNode extends Point {
    public var id: Int;
    public var neighbors: Array<{id: Int, distance: Float}> = [];

    public var parent: Int = -1;
    
    public var distFromStart: Float = 999_999_999;
    public var distToGoal: Float = 999_999_999;

    override public function new(id: Int, x: Float, y: Float) {
        super(x, y);
        this.id = id;
    }

    override function toString():String {
        return "{" + id + "," + x + "," + y + "}";
    }
}

class PointAndClickMovement extends Component {
    private var nodesW: Int;
    private var nodesH: Int;
    private var resW: Int;
    private var resH: Int;
    var nodeSpacingW: Float;
    var nodeSpacingH: Float;

    private var graph: Array<AstarNode> = [];
    private var graphIds: Array<Int> = []; // graph coordinates ids to check existing position nodes
    private var graphIdsMap: Map<Int, Int> = [];
    private var queue: Array<AstarNode> = [];
    
    private var start: AstarNode;
    private var goal: AstarNode;
    private var path: Array<AstarNode> = [];

    private var currentNode: AstarNode;

    private var openNodes: Array<AstarNode>;
    private var visitedNodes: Array<AstarNode>;

    public var walking: Bool = false;
    public var speed: Float = 60;

    private var walkingDir: Point;

    public function new(name: String = "pointandclickmovement", nodesW: Int = 40, nodesH: Int = 20, resW: Int = 320, resH: Int = 200) {
        super(name);
        this.nodesW = nodesW;
        this.nodesH = nodesH;
        this.resW = resW;
        this.resH = resH;
    }

    private function makeGrid(nodesW: Int, nodesH: Int, resW: Int, resH: Int, walkArea: Polygon, exclusionAreas: Array<Polygon>){
        nodeSpacingW = resW / (nodesW + 1);
        nodeSpacingH = resH / (nodesH + 1);

        graph = [];
        graphIds = [];

        for (i in 0...nodesH){
            for (j in 0...nodesW){
                var pointAlive: Bool = true;
                var pointId: Int = j+nodesW*i;
                var point = new AstarNode(pointId, nodeSpacingW * (j+1), nodeSpacingH * (i+1));

                if(!walkArea.contains(point)) continue;
                for(exclArea in exclusionAreas){
                    if(exclArea.contains(point)){
                        pointAlive = false;
                        break;
                    }
                }
                if(pointAlive){
                    graph.push(point);
                    graphIds.push(pointId);
                }
                else continue;

                // now connect nodes NW, N, NE, W if they exist
                var neighbor: AstarNode;
                var neighborId: Int;
                if(i > 0){
                    // NW
                    neighborId = (j-1)+ nodesW * (i-1);
                    if(j > 0 && graphIds.contains(neighborId)){
                        neighbor = findInGraph(neighborId);
                        neighbor.neighbors.push({id: pointId, distance: 14});
                        point.neighbors.push({id:neighborId, distance: 14});
                    }
                    // N
                    neighborId = j+ nodesW * (i-1);
                    if(graphIds.contains(neighborId)){
                        neighbor = findInGraph(neighborId);
                        neighbor.neighbors.push({id: pointId, distance: 10});
                        point.neighbors.push({id:neighborId, distance: 10});
                    }
                    // NE
                    neighborId = (j+1)+ nodesW * (i-1);
                    if(j < nodesW && graphIds.contains(neighborId)){
                        neighbor = findInGraph(neighborId);
                        neighbor.neighbors.push({id: pointId, distance: 14});
                        point.neighbors.push({id:neighborId, distance: 14});
                    }
                }
                // W
                neighborId = (j-1) + nodesW * i;
                if(j > 0 && graphIds.contains(neighborId)){
                    neighbor = findInGraph(neighborId);
                    neighbor.neighbors.push({id: pointId, distance: 10});
                    point.neighbors.push({id:neighborId, distance: 10});
                }
            }
        }

        remapGraph();
    }

    private function findNodesAroundPoint(point: Point): Array<AstarNode>{
        var closestW: Int = Math.floor(point.x / nodeSpacingW);
        var closestH: Int = Math.floor(point.y / nodeSpacingH);
        
        var neighbors: Array<AstarNode> = [];
        
        var possibleIds: Array<Int> = [
            closestW   + nodesW *  closestH - 1,
            closestW+1 + nodesW *  closestH - 1,
            closestW   + nodesW * (closestH-1) - 1,
            closestW+1 + nodesW * (closestH-1) - 1,
        ];

        for(pid in possibleIds){
            if(graphIds.contains(pid)){
                neighbors.push(graph[graphIdsMap[pid]]);
            }
        }

        #if debug
        var debugDraw: Bool = false;
        if(debugDraw){
            var drawer: h2d.Graphics = parent.room.drawer;
            drawer.lineStyle(1, 0x00FF00);
            for(n in neighbors){
                drawer.moveTo(point.x, point.y);
                drawer.lineTo(n.x, n.y);
            }
        }
        #end

        return neighbors;
    }

    private function remapGraph(){
        graphIdsMap = [];

        for (i in 0...graphIds.length){
            graphIdsMap.set(graphIds[i], i);
        }

        for (node in graph){
            node.id = graphIdsMap[node.id];
            node.neighbors = [for(n in node.neighbors) {id: graphIdsMap[n.id], distance: n.distance}];
        }
    }

    private function findInGraph(id: Int): AstarNode{
        for (node in graph){
            if(node.id == id) return node;
        }
        return null;
    }

    private function calculatePath(goalX: Float, goalY: Float){
        visitedNodes = [];
        start = new AstarNode(graph.length, parent.x, parent.y);
        var startNeighbors: Array<AstarNode> = findNodesAroundPoint(start);
        for (startNeighbor in startNeighbors){
            var dist: Float = startNeighbor.distanceSq(start);
            start.neighbors.push({id: startNeighbor.id, distance: dist});  
            startNeighbor.neighbors.push({id: start.id, distance: dist});
        }
        start.distFromStart = 0;

        goal = new AstarNode(graph.length+1, goalX, goalY);
        var goalNeighbors: Array<AstarNode> = findNodesAroundPoint(goal);
        for (goalNeighbor in goalNeighbors){
            var dist: Float = goalNeighbor.distanceSq(goal);
            goal.neighbors.push({id: goalNeighbor.id, distance: dist});  
            goalNeighbor.neighbors.push({id: goal.id, distance: dist});
        }

        graph.push(start);
        graph.push(goal);
        
        
        openNodes = [start];

        while(openNodes.length > 0){
            haxe.ds.ArraySort.sort(openNodes, function(a, b): Int {return Std.int((a.distFromStart + a.distToGoal) - (b.distFromStart + b.distToGoal));});
            currentNode = openNodes.shift();

            if(currentNode == goal) break;

            visitedNodes.push(currentNode);

            for (neighbor in currentNode.neighbors){
                var neighborNode: AstarNode = graph[neighbor.id];
                if(visitedNodes.contains(neighborNode)) continue;

                var tentativeCost: Float = currentNode.distFromStart + neighbor.distance;

                if(neighborNode.distFromStart > tentativeCost || !openNodes.contains(neighborNode)){
                    neighborNode.distFromStart = tentativeCost;
                    neighborNode.parent = currentNode.id;

                    if(!openNodes.contains(neighborNode)) openNodes.push(neighborNode);
                }
            }

        }

        for (startNeighbor in startNeighbors){
            startNeighbor.neighbors.pop();
        }
        for (goalNeighbor in goalNeighbors){
            goalNeighbor.neighbors.pop();
        }
        graph.pop();
        graph.pop();
    }

    function getComputedPath(): Array<AstarNode>{
        var path: Array<AstarNode> = [goal];

        while(path[0].parent != -1){
            if(path[0].parent == graph.length) break; // start node found

            path.insert(0, graph[path[0].parent]);
        }

        return path;
    }

    override function init(){
        super.init();

        makeGrid(nodesW, nodesH, resW, resH, parent.room.walkArea, parent.room.exclusionAreas);
    }

    override function update(dt: Float){
        super.update(dt);

        if(Key.isPressed(Key.MOUSE_LEFT)){
            
            calculatePath(parent.room.mouseX, parent.room.mouseY);
            path = getComputedPath();
            walking = true;
            walkingDir = Math.getDirection(new Point(parent.x, parent.y), path[0]);

            // drawGraph(0x111);
        }

        if(walking){
            var parentPoint: Point = new Point(parent.x, parent.y);
            var distance: Float = path[0].distanceSq(parentPoint);
            if(distance < 1){
                path.shift();
                if(path.length > 0){
                    walkingDir = Math.getDirection(parentPoint, path[0]);
                }
                else{
                    walking = false;
                    parent.x = goal.x;
                    parent.y = goal.y;
                }
            }
            else{
                parent.x += (walkingDir.x * speed * dt);
                parent.y += (walkingDir.y * speed * dt);
            }
        }
    }

    #if debug
    public function drawGraph(mode: Int = 0x111){
        parent.room.drawer.clear();
        loom.utils.RoomUtils.drawWalkArea(parent.room, parent.room.walkArea, parent.room.exclusionAreas, 0x010100);
        if(mode & 0x010 == 0x010) drawGraphEdges();
        if(mode & 0x100 == 0x100) drawGraphNodes();
        if(mode & 0x001 == 0x001 && graph.length > 1) drawComputedPath();
    }

    public function drawGraphNodes(color: Color = 0x0000FF, clear: Bool = false){
        var drawer: h2d.Graphics = parent.room.drawer;
        if(clear) drawer.clear();
        
        drawer.lineStyle(1, color);
        for (i in 1...graph.length-1){
            var node: AstarNode = graph[i];
            // drawer.drawRect(node.x-1, node.y-1, 3, 3);
            drawer.drawRect(node.x, node.y, 1, 1);
        }
    }

    public function drawGraphEdges(color: Color = 0xFFFFFF, clear: Bool = false){
        var drawer: h2d.Graphics = parent.room.drawer;
        if(clear) drawer.clear();
        drawer.lineStyle(1, color);

        for (node in graph){
            for (neighbor in node.neighbors){
                drawer.moveTo(node.x, node.y);
                drawer.lineTo(graph[neighbor.id].x, graph[neighbor.id].y);
            }
        }
    }

    public function drawComputedPath(color: Color = 0xFF00FF, clear: Bool = false){
        var drawer: h2d.Graphics = parent.room.drawer;
        if(clear) drawer.clear();
        
        var node: AstarNode = goal;
        drawer.lineStyle(1, 0xFF0000);
        drawer.drawRect(node.x-1, node.y-1, 3, 3);
        drawer.lineStyle(1, color);

        while(node.parent != -1){
            drawer.moveTo(node.x, node.y);
            
            if(node.parent == graph.length) node = start;
            else node = graph[node.parent];
            
            drawer.lineTo(node.x, node.y);

            drawer.lineStyle(1, 0xFF0000);
            drawer.drawRect(node.x-1, node.y-1, 3, 3);
            drawer.lineStyle(1, color);
        }
    }
    #end
}