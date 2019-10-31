classdef GeoGroundStructure < handle
    
    properties
        nodeGrid
        memberList
        nodes
        members
        continuumNodeNum = 0;
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
        
        function appendNodes(self, newNodes)
            self.nodeGrid = [self.nodeGrid; newNodes];
            self.nodeGrid = unique(self.nodeGrid, 'rows');
        end
        
        function createCustomizedNodeGrid(self, xStart, yStart, xEnd, yEnd, xSpacing, ySpacing)
            xSpacingNumber = floor((xEnd-xStart)/xSpacing);
            ySpacingNumber = floor((yEnd-yStart)/ySpacing);
            x = 0 : xSpacingNumber;
            y = 0 : ySpacingNumber;
            [X,Y] = meshgrid(x,y);
            points = [X(:), Y(:)];
            if xSpacingNumber == 0
                xSpacingNumber = 1;
            end
            if ySpacingNumber == 0
                ySpacingNumber = 1;
            end
            points(:, 1) = points(:, 1) *(xEnd - xStart)/xSpacingNumber + xStart;
            points(:, 2) = points(:, 2) *(yEnd - yStart)/ySpacingNumber + yStart;
            self.nodeGrid = points;
        end
        
        function createMemberListFromNodeGrid(self)
            nodes = self.nodeGrid;
            nodeNum = size(nodes, 1);
            memberList = zeros(nodeNum * (nodeNum - 1) / 2, 6);
            addedMemberNumber = 0;
            
            for i = 1:(nodeNum-self.continuumNodeNum)
                memberList(addedMemberNumber+1 : addedMemberNumber+nodeNum - i, 1) = repmat(i, nodeNum - i, 1);
                memberList(addedMemberNumber+1 : addedMemberNumber+nodeNum - i, 2) = (i+1):nodeNum;
                memberList(addedMemberNumber+1 : addedMemberNumber+nodeNum - i, 3:4) = repmat(nodes(i,:), nodeNum - i, 1);
                memberList(addedMemberNumber+1 : addedMemberNumber+nodeNum - i, 5:6) = nodes(i+1:end, :);
                addedMemberNumber = addedMemberNumber + nodeNum - i;
            end
            self.memberList = memberList(memberList(:, 1)~=0, :);
        end
        
        function connectedMembers = getMembersConnectedToNodes(self, nodeList)
            nodeNum = size(nodeList, 1);
            connectedMembers = cell(nodeNum, 1);
            memberIndex = (1:size(self.memberList, 1))';
            for i = 1:nodeNum
                connectedMembers{i, 1} = memberIndex(self.memberList(:, 1) == nodeList(i, 1) | self.memberList(:, 2) == nodeList(i, 1));
            end
            connectedMembers = cell2mat(connectedMembers);
            connectedMembers = unique(connectedMembers);
        end
        
        function createNodesFromGrid(self)
            nodeNum = size(self.nodeGrid, 1);
            self.nodes = cell(nodeNum, 1);
            for i = 1:nodeNum
                self.nodes{i, 1} = GeoNode(self.nodeGrid(i, 1),self.nodeGrid(i, 2), i);
            end     
        end
        
        function volume = calculateVolume(self)
            volume = 0;
            for i = 1:size(self.members, 1)
                volume = volume + self.members{i, 1}.length * self.members{i, 1}.area;
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
        
        function nodeIndex = findOrAppendNode(self, x,y)
            nodeIndex = self.findNodeIndex(x, y);
            if nodeIndex == -1
                nodeIndex = self.appendNode(x, y);
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
        
       function createGroundStructureFromMemberList(self)
           memberNum = size(self.memberList, 1);
           self.members = cell(memberNum, 1);
           for i = 1:memberNum
               self.members{i, 1} = GeoMember(self.nodes{self.memberList(i, 1),1}, self.nodes{self.memberList(i, 2),1}, i);
           end
       end
       
               
       function structure = createOptimizedStructureList(self)
           memberNum = size(self.members, 1);
           structure = zeros(memberNum, 5);
           addedMemberNo = 0;
           maxArea = 0;
           for i = 1:size(self.members)
               maxArea = max(maxArea, self.members{i,1}.area);
           end
           for i = 1:size(self.members)
               coefficient = self.members{i,1}.area / maxArea;
               if coefficient > 1 / 50
                   addedMemberNo = addedMemberNo + 1;
                   structure(addedMemberNo, :) = [self.members{i,1}.nodeA.x, self.members{i,1}.nodeA.y, self.members{i,1}.nodeB.x, self.members{i,1}.nodeB.y, self.members{i,1}.area];
               end
           end
           structure(addedMemberNo+1:end, :) = [];
       end
        
       function plotMembers(self, varargin)
            p = inputParser;
            addOptional(p,'figureNumber',1, @isnumeric);
            addOptional(p,'force', false, @islogical);
            addOptional(p,'title','', @ischar);
            addOptional(p,'nodalForce', false, @islogical);
            addOptional(p,'nodalForcePlottingRatio', -1, @isnumeric);
            addOptional(p, 'blackAndWhite', false, @islogical);
            addOptional(p, 'plotGroundStructure', false, @islogical);
            addOptional(p,'plotNodeNumber', false, @islogical);
            addOptional(p,'plotMemberNumber', false, @islogical);
            parse(p,varargin{:});
            plotForce = p.Results.force;
            titleText = p.Results.title;
            nodalForce = p.Results.nodalForce;
            blackAndWhite = p.Results.blackAndWhite;
            nodalForcePlottingRatio = p.Results.nodalForcePlottingRatio;
            plotGroundStructure = p.Results.plotGroundStructure;
            figureNo = p.Results.figureNumber;
            plotNodeNumber = p.Results.plotNodeNumber;
            plotMemberNumber = p.Results.plotMemberNumber;
            
            fig = figure(figureNo);
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
                coefficient = self.members{i,1}.area / maxArea;
                if plotGroundStructure
                    coefficient = 1;
                end
                if coefficient > 1 / 1000                 
                    if blackAndWhite
                        color = [0, 0, 0];
                    else
                        if (self.members{i,1}.force > 0)
                        color = [1, 1, 1] - coefficient^0.3 * [1, 1, 0];
                        else
                        color = [1, 1, 1] - coefficient^0.3 * [0, 1, 1];
                        end
                    end

                    x1 = [self.members{i,1}.nodeA.x, self.members{i,1}.nodeB.x];
                    y1 = [self.members{i,1}.nodeA.y, self.members{i,1}.nodeB.y];
                    if plotGroundStructure
                        width = 0.001;
                    else
                        width = self.members{i,1}.area;
                    end
                    coordinates = getLineCornerCoordinates([x1;y1], self.members{i,1}.length, width);
                    %plot(x1, y1, 'Color', color, 'LineWidth', radius);
                    fill (coordinates(1,:), coordinates(2,:), color, 'EdgeColor', color);
                    if plotMemberNumber
                        text(mean(coordinates(1,:)), mean(coordinates(2,:)), sprintf('%d',i), 'FontSize',10, 'Color', [0,0,0]);
                    end
                    if (plotForce ~=0)
                    	xText = x1(1) + (x1(2) -x1(1))/3; 
                        yText = y1(1) + (y1(2) -y1(1))/3; 
                        text(xText, yText, sprintf('%0.2g',self.members{i,1}.force), 'FontSize',15, 'Color', color);
                    end
                end
            end
            
            
            if plotNodeNumber             
                for i = 1:size(self.nodes)
                        text(self.nodes{i, 1}.x, self.nodes{i, 1}.y, sprintf('%d',i), 'FontSize',10, 'Color', [0,0,0]);
                end              
            end
            
            if nodalForce
                nodalForces = self.calcNodeForceDensity();
                maxNodalForce = max(nodalForces);
%                 for i = 1:size(self.nodes)
%                     if (nodalForces(i) > 0)
%                         plot(self.nodes{i, 1}.x, self.nodes{i, 1}.y,'o', 'MarkerEdgeColor', [0.2,0.2,0.2], 'MarkerFaceColor', [0.2,0.2,0.2], 'MarkerSize', 10*nodalForces(i)/maxNodalForce);
%                     end
%                 end
                
                for i = 1:size(self.nodes)
                    if (nodalForces(i) > maxNodalForce/10)
                        plot(self.nodes{i, 1}.x, self.nodes{i, 1}.y,'o', 'MarkerEdgeColor', [0.2,0.2,0.2], 'MarkerFaceColor', [0.2,0.2,0.2], 'MarkerSize', 10);
                    end
                end
                
            end
        end
        
        function obj = calcNodeForceDensity(self)
            obj = zeros(size(self.nodes, 1), 1);
            
            for i = 1:size(self.members)
                currentMember = self.members{i, 1};
                obj(currentMember.nodeA.index) = obj(currentMember.nodeA.index) + currentMember.area;
                obj(currentMember.nodeB.index) = obj(currentMember.nodeB.index) + currentMember.area;
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

