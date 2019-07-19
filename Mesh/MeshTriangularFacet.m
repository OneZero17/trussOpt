classdef MeshTriangularFacet < handle

    properties
        nodeA = GeoNode();
        nodeB = GeoNode();
        nodeC = GeoNode();
        edgeA = MeshEdge();
        edgeB = MeshEdge();
        edgeC = MeshEdge();
        area = 0;
        shapeFunction = zeros(3, 3);
        density = 0;
    end
    
    methods
        function obj = MeshTriangularFacet(nodes, edges)
            if (nargin > 0)
                obj.nodeA = nodes(1, 1);
                obj.nodeB = nodes(2, 1);
                obj.nodeC = nodes(3, 1);
                coordinateX = [obj.nodeA.x, obj.nodeB.x, obj.nodeC.x];
                coordinateY = [obj.nodeA.y, obj.nodeB.y, obj.nodeC.y];
                obj.area = polyarea(coordinateX, coordinateY);
            end
            if (nargin > 1)
                obj.edgeA = edges{1, 1};
                obj.edgeB = edges{2, 1};
                obj.edgeC = edges{3, 1};
            end
        end
        
        function calcShapeFunction(self)
            x1 = self.nodeA.x;
            x2 = self.nodeB.x;
            x3 = self.nodeC.x;
            y1 = self.nodeA.y;
            y2 = self.nodeB.y;
            y3 = self.nodeC.y; 
            self.shapeFunction = [x2*y3 - x3*y2, y2-y3, x3-x2;
                                  x3*y1 - x1*y3, y3-y1, x1-x3;
                                  x1*y2 - x2*y1, y1-y2, x2-x1];
        end
    end
end

