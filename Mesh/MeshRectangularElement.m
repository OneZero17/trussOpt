classdef MeshRectangularElement < handle

    properties
        nodeIndices = zeros(4, 1);
        edgeIndices = zeros(4, 1);
        %for property neighbours  
        %the first column is element index
        %the second column is corresponding edge index in this facet
        %the third column is the corresponding edge index in the neighbour facet
        neighbours = zeros(4, 3);
        neighbourNum = 0;
        index = 0;
        spacing = 0 ;
    end
    
    methods
        function obj = MeshRectangularElement(nodes, edges, index, spacing)
            if (nargin > 0)
                obj.nodeIndices = nodes;
            end
            if (nargin > 1)
                obj.edgeIndices = edges;
            end
            if (nargin > 2)
                obj.index = index;
            end
            if (nargin > 3)
                obj.spacing = spacing;
            end
        end
        
        function addNeighbour(self, elementIndex, edgeIndex, theOtherEdgeIndex)
            self.neighbourNum = self.neighbourNum + 1;
            self.neighbours(self.neighbourNum,:) = [elementIndex, edgeIndex, theOtherEdgeIndex];
        end
        
        function createFacets(self, mesh)
            [node1, node2, node3, node4] = mesh.meshNodes{self.nodeIndices};
            newX = mean([node1.x, node2.x, node3.x, node4.x]);
            newY = mean([node1.y, node2.y, node3.y, node4.y]);
        end
    end
end

