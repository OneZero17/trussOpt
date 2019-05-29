classdef GeoGroundStructure < handle
    
    properties
        nodes
        members
    end
    
    methods
        function obj = GeoGroundStructure(nodesVector,membersVector)
            if (nargin > 0)
                obj.nodes = nodesVector;
            end
            if (nargin > 1)
                obj.members = membersVector;
            end
        end
        
        function obj = findNodeIndex(self, x, y)
            for i = 1:size(self.nodes)
                if (self.nodes{i, 1}.x == x && self.nodes{i, 1}.y == y)
                    obj = i;
                    return;
                end
            end
            obj = -1;
        end
        
        function [obj, nodeIndex] = appendNode(self, x, y)
            nodeIndex = size(self.nodes, 1) + 1;
            self.nodes = {self.nodes; GeoNode(x,y, nodeIndex)};
            obj = self;
        end
        
        function [obj, nodeIndex] = findOrAppendNode(self, x,y)
            nodeIndex = self.findNodeIndex(x, y);
            obj = self;
            if nodeIndex == -1
                [obj, nodeIndex] = self.appendNode(x, y);
            end
        end
        
        function obj = createRectangularNodeGrid(self, sizeX, sizeY)
            if (nargin == 0)
                sizeX = 10;
                sizeY = 10;
            end

            self.nodes = cell((sizeX+1)*(sizeY+1), 1);
            nodeNum = 1;
            for i= 0:sizeX
                for j = 0:sizeY
                    self.nodes{nodeNum, 1} = GeoNode(i,j, nodeNum);
                    nodeNum = nodeNum+1;
                end
            end
            obj = self;
        end
        
        function obj = createGroundStructureFromNodeGrid(self, grid)
            if (nargin < 2)
                grid = self.nodes;
            end
            self.members = cell(size(grid,1)*(size(grid,1) - 1)/2, 1);
            memberNum = 1;
            for i = 1:size(grid)
                for j = i+1:size(grid)
                    self.members{memberNum, 1} = GeoMember(grid{i,1}, grid{j,1}, memberNum);
                    memberNum = memberNum + 1;
                end
            end
            obj = self;
        end
        
        function plotMembers(self)
            hold on
            axis square
            for i = 1:size(self.members)
                if (self.members{i,1}.area > 0.001)
                    x1 = [self.members{i,1}.nodeA.x, self.members{i,1}.nodeB.x];
                    y1 = [self.members{i,1}.nodeA.y, self.members{i,1}.nodeB.y];
                    plot(x1, y1, 'LineWidth', self.members{i,1}.area);
                end
            end
        end
        
        function calcMaxMemberPerNode(self)
            nodeConnextion = zeros(size(self.nodes, 1), 1);
            for i = 1:size(self.members, 1)
                
            end
        end
    end
end

