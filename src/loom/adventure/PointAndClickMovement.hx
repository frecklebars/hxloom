package loom.adventure;

using hxd.Key;
using loom.math.MathExtensions;

class AstarNode extends h2d.col.Point {
    public var id: Int;
    public var neighbors: Array<{id: Int, distance: Float}> = [];

    public var parent: Int = -1;
    
    public var distFromStart: Float = 999999999;
    public var distToGoal: Float;

    override public function new(id: Int, x: Float, y: Float) {
        super(x, y);
        this.id = id;
    }

    override function toString():String {
        return "{" + id + "," + x + "," + y + "}";
    }
}

class PointAndClickMovement extends Component {
    private var graph: Array<AstarNode> = [];
    private var graphIds: Array<Int> = [];
    private var queue: Array<AstarNode> = [];
    
    private var start: AstarNode;
    private var goal: AstarNode;

    private var currentNode: AstarNode;

    private var openNodes: Array<AstarNode>;
    private var visitedNodes: Array<AstarNode>;

    public var walking: Bool = false;

    public function new(name: String = "pointandclickmovement") {
        super(name);
    }

    private function makeGraph(walkArea: h2d.col.Polygon, exclusionAreas: Array<h2d.col.Polygon>){
        var concavePoints = Math.getConcavePoints(walkArea);
        for(exclArea in exclusionAreas){
            concavePoints = concavePoints.concat(Math.getConvexPoints(exclArea));
        }
        concavePoints.push(goal);
        concavePoints.insert(0, start);

        for (i in 0...concavePoints.length-1){
            for (j in i...concavePoints.length){
                var point1: h2d.col.Point = concavePoints[i];
                var point2: h2d.col.Point = concavePoints[j];

                if(Math.pointInLineOfSight([walkArea].concat(exclusionAreas), point1, point2)){
                    var apoint1: AstarNode;
                    var apoint2: AstarNode;
                    
                    if(graphIds.contains(i)){
                        apoint1 = findInGraph(i);
                    }
                    else{
                        apoint1 = new AstarNode(i, point1.x, point1.y);
                        graphIds.push(i);
                        graph.push(apoint1);
                    }

                    if(graphIds.contains(j)){
                        apoint2 = findInGraph(j);
                    }
                    else{
                        apoint2 = new AstarNode(j, point2.x, point2.y);
                        graphIds.push(j);
                        graph.push(apoint2);
                    }

                    apoint1.neighbors.push({ id: j, distance: apoint1.distanceSq(apoint2) });
                    // apoint1.distFromStart = apoint1.distanceSq(concavePoints[0]);
                    apoint1.distToGoal = apoint1.distanceSq(concavePoints[concavePoints.length - 1]);
                    
                    apoint2.neighbors.push({ id: i, distance: apoint1.distanceSq(apoint1) });
                    // apoint2.distFromStart = apoint2.distanceSq(concavePoints[0]);
                    apoint2.distToGoal = apoint2.distanceSq(concavePoints[concavePoints.length - 1]);
                }
            }
        }

        haxe.ds.ArraySort.sort(graph, function(a, b): Int {return a.id - b.id;});
        haxe.ds.ArraySort.sort(graphIds, function(a, b): Int {return a - b;});
        start = graph[0];
        start.distFromStart = 0;
        goal = graph[graph.length-1];
        remapGraph();
    }

    private function remapGraph(){
        var idsMap: Map<Int, Int> = [];

        for (i in 0...graphIds.length){
            idsMap.set(graphIds[i], i);
        }

        for (node in graph){
            node.id = idsMap[node.id];
            node.neighbors = [for(n in node.neighbors) {id: idsMap[n.id], distance: n.distance}];
        }
    }

    private function findInGraph(id: Int): AstarNode{
        for (node in graph){
            if(node.id == id) return node;
        }
        return null;
    }

    private function calculatePath(){
        while(openNodes.length > 0){
            currentNode = nextActiveNode();
            visitedNodes.push(currentNode);

            if(currentNode == goal) break;

            for (neighbor in currentNode.neighbors){
                var neighborNode: AstarNode = graph[neighbor.id];
                if(visitedNodes.contains(neighborNode)) continue;

                neighborNode.distFromStart = currentNode.distFromStart + neighbor.distance;
                if(neighborNode.distFromStart < currentNode.distFromStart || !openNodes.contains(neighborNode)){
                    neighborNode.parent = currentNode.id;
                    if(!openNodes.contains(neighborNode)) openNodes.push(neighborNode);
                }
            }

        }
    }

    /**
        Find node with smallest f(x) in openNodes
    **/
    private function nextActiveNode(): AstarNode{
        if(openNodes.length <= 1) return openNodes.shift();

        var nextNode: AstarNode = null;
        var smallestF: Float = 999999999;

        for (node in openNodes){
            var fVal: Float = node.distFromStart + node.distToGoal;
            if(fVal < smallestF){
                nextNode = node;
                smallestF = fVal;
            }
        }

        openNodes.remove(nextNode);
        return nextNode;
    }

    function getComputedPath(): Array<AstarNode>{
        var path: Array<AstarNode> = [goal];

        while(path[0].parent != -1){
            path.insert(0, graph[path[0].parent]);
        }

        return path;
    }

    override function init(){
        super.init();
    }

    override function update(dt: Float){
        super.update(dt);

        if(Key.isPressed(Key.MOUSE_LEFT)){
            visitedNodes = [];
            start = new AstarNode(-1, Std.int(parent.x), Std.int(parent.y));
            goal = new AstarNode(-2, Std.int(parent.room.mouseX), Std.int(parent.room.mouseY));
            graph = [];
            graphIds = [];
            
            makeGraph(parent.room.walkArea, parent.room.exclusionAreas);
            
            openNodes = [graph[0]];
            
            calculatePath();
            var path: Array<AstarNode> = getComputedPath();

            drawGraph(0x101);
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
        
        drawer.lineStyle(1, 0x00FF00);
        drawer.drawRect(graph[0].x-1, graph[0].y-1, 3, 3);
        drawer.lineStyle(1, 0xFF00FF);
        drawer.drawRect(graph[graph.length-1].x-1, graph[graph.length-1].y-1, 3, 3);
        
        drawer.lineStyle(1, color);
        for (i in 1...graph.length-1){
            var node: AstarNode = graph[i];
            drawer.drawRect(node.x-1, node.y-1, 3, 3);
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
        drawer.lineStyle(1, color);

        var node: AstarNode = goal;
        while(node.parent != -1){
            drawer.moveTo(node.x, node.y);
            node = graph[node.parent];
            drawer.lineTo(node.x, node.y);

            drawer.lineStyle(1, 0xFF0000);
            drawer.drawRect(node.x-1, node.y-1, 3, 3);
            drawer.lineStyle(1, color);
        }
    }
    #end
}