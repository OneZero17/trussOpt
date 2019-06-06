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
        
        function initializeIndices(self)
            for i = 1:size(self.nodes, 1)
                self.nodes{i,1}.index = i;
            end
            
            for i = 1:size(self.members, 1)
                self.members{i,1}.index = i;
            end
        end
        
        function obj = findNodeIndex(self, x, y)
            for i = 1:size(self.nodes)
                diff = sqrt((self.nodes{i, 1}.x - x)^2 + (self.nodes{i, 1}.y - y)^2);
                if (diff < 1e-7)
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
        
        function plotMembers(self, plotForce, titleText)
            
            figure
            hold on
            axis equal
            axis off
            maxArea = -1;
            if (nargin > 2)
                title(titleText)
            end
            for i = 1:size(self.members)
                maxArea = max(maxArea, self.members{i,1}.area);
            end
            for i = 1:size(self.members)
                if (self.members{i,1}.area > maxArea / 1000)
                    if (self.members{i,1}.force > 0)
                        color = [1, 1, 1] - (self.members{i,1}.area / maxArea)^0.3 * [1, 1, 0];
                    else
                        color = [1, 1, 1] - (self.members{i,1}.area / maxArea)^0.3 * [0, 1, 1];
                    end
                    x1 = [self.members{i,1}.nodeA.x, self.members{i,1}.nodeB.x];
                    y1 = [self.members{i,1}.nodeA.y, self.members{i,1}.nodeB.y];
                    plot(x1, y1, 'Color', color);
                    if (plotForce ~=0)
                    	xText = x1(1) + (x1(2) -x1(1))/3; 
                        yText = y1(1) + (y1(2) -y1(1))/3; 
                        text(xText, yText, sprintf('%0.2g',self.members{i,1}.force), 'FontSize',15, 'Color', color);
                    end
                end
            end

        end
        
        function nodeConnection = calcMemberPerNode(self)
            nodeConnection = zeros(size(self.nodes, 1), 1);
            for i = 1:size(self.members, 1)
                nodeAIndex = self.members{i, 1}.nodeA.index;
                nodeBIndex = self.members{i, 1}.nodeB.index;
                nodeConnection(nodeAIndex, 1) = nodeConnection(nodeAIndex, 1) + 1;
                nodeConnection(nodeBIndex, 1) = nodeConnection(nodeBIndex, 1) + 1;
            end
        end
    end
end

