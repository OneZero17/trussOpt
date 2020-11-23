classdef GeoGroundStructure3D < handle
    
    properties
        nodes
        members
    end
    
    methods
        function obj = GeoGroundStructure3D()

        end
        
        function nodeConnection = calcMemberPerNode(self)
            nodeConnection = zeros(size(self.nodes, 1), 1);
            for i = 1:size(self.members, 1)
                nodeAIndex = self.members(i, 1);
                nodeBIndex = self.members(i, 2);
                nodeConnection(nodeAIndex, 1) = nodeConnection(nodeAIndex, 1) + 1;
                nodeConnection(nodeBIndex, 1) = nodeConnection(nodeBIndex, 1) + 1;
            end
        end
        
        function structure = createOptimizedStructureList(self, forceList)
           memberNum = size(self.members, 1);
           areaList = abs(forceList);
           maxArea = max(areaList);
           structure = zeros(memberNum, 7);
           addedMemberNo = 0;
           
           for i = 1:size(areaList)
               coefficient = areaList(i, 1) / maxArea;
               if coefficient > 1 / 1000
                   addedMemberNo = addedMemberNo + 1;
                   structure(addedMemberNo, :) = [self.members(i, 3:8), forceList(i)];
               end
           end
           structure(addedMemberNo+1:end, :) = [];
        end
       
        function deleteHorizontalMembers(self)
            zDiff = abs(self.members(:, 8) - self.members(:, 5));
            self.members = self.members(zDiff > 1e-6, :);
        end
        
        function deleteNearHorizontalMembers(self, threshold)
            threshold = pi*threshold / 180;
            zDiff = abs(self.members(:, 8) - self.members(:, 5));
            memberVector = self.members(:, [6 7 8]) - self.members(:, [3 4 5]);
            memberLength = vecnorm(memberVector')';
            sinValues = zDiff./memberLength;
            angleValues = asin(sinValues);
            self.members = self.members(angleValues > threshold, :);
        end
        
        function createCustomizedNodeGrid(self, boxStartPoint, boxEndPoint, spacing)
            xSpacingNumber = floor((boxEndPoint(1)-boxStartPoint(1)) / spacing(1));
            ySpacingNumber = floor((boxEndPoint(2)-boxStartPoint(2)) / spacing(2));
            zSpacingNumber = floor((boxEndPoint(3)-boxStartPoint(3)) / spacing(3));
            x = 0 : xSpacingNumber;
            y = 0 : ySpacingNumber;
            z = 0 : zSpacingNumber;
            [X,Y,Z] = meshgrid(x,y,z);
            points = [X(:), Y(:), Z(:)];
            if xSpacingNumber == 0
                xSpacingNumber = 1;
            end
            if ySpacingNumber == 0
                ySpacingNumber = 1;
            end
            if zSpacingNumber == 0
                zSpacingNumber = 1;
            end
            points(:, 1) = points(:, 1) * (boxEndPoint(1) - boxStartPoint(1)) / xSpacingNumber + boxStartPoint(1);
            points(:, 2) = points(:, 2) * (boxEndPoint(2) - boxStartPoint(2)) / ySpacingNumber + boxStartPoint(2);
            points(:, 3) = points(:, 3) * (boxEndPoint(3) - boxStartPoint(3)) / zSpacingNumber + boxStartPoint(3);
            self.nodes = points;
        end
        
        function createMembersFromNodes(self)
            nodes = self.nodes;
            nodeNum = size(nodes, 1);
            memberList = zeros(nodeNum * (nodeNum - 1) / 2, 8);
            addedMemberNumber = 0;
            
            for i = 1:nodeNum
                memberList(addedMemberNumber+1 : addedMemberNumber + nodeNum - i, 1) = repmat(i, nodeNum - i, 1);
                memberList(addedMemberNumber+1 : addedMemberNumber + nodeNum - i, 2) = (i+1):nodeNum;
                memberList(addedMemberNumber+1 : addedMemberNumber + nodeNum - i, 3:5) = repmat(nodes(i,:), nodeNum - i, 1);
                memberList(addedMemberNumber+1 : addedMemberNumber + nodeNum - i, 6:8) = nodes(i+1:end, :);
                addedMemberNumber = addedMemberNumber + nodeNum - i;
            end
            
            self.members = memberList(memberList(:, 1)~=0, :);
            memberVectors = self.members(:, 6:8) - self.members(:, 3:5);
            memberLength = (memberVectors(:, 1).^2 + memberVectors(:, 2).^2 + memberVectors(:, 3).^2).^0.5;
            self.members = [self.members, memberLength];
        end
        
        function obj = findNodeIndex(self, node)
            nodeCoordinates = self.nodes;
            nodeNumber = (1:size(nodeCoordinates, 1))';
            diffMatrix = nodeCoordinates - node;
            diff = (diffMatrix(:, 1).^2 + diffMatrix(:, 2).^2 + diffMatrix(:, 3).^2).^0.5;
            obj = nodeNumber(diff < 1e-7);
            if size(obj, 1) > 1
                fprintf("More than one nodes have been found for the target position (%.4f, %.4f, %.4f)\n", node);
            elseif isempty(obj)
                obj = -1;
                fprintf("No node has been found for the target position (%.4f, %.4f, %.4f)\n", node);
            end
        end
        
        function plotMembers(self, forceList, varargin)
            p = inputParser;
            addOptional(p,'figureNumber',1, @isnumeric);
            parse(p,varargin{:});
            figureNo = p.Results.figureNumber;
            
            fig = figure(figureNo);
            hold on
            axis equal
            areaList = abs(forceList);
            maxArea = max(areaList);
            xlabel('x')
            ylabel('y')
            zlabel('z')
            grid on
            view([1 1 0.5])
            for i = 1:size(self.members, 1)
                coefficient = (areaList(i, 1) / maxArea)^0.2;
                if coefficient > 1 / 100   
                    if (forceList(i) > 0)
                    color = [1, 1, 1] - coefficient^0.3 * [1, 1, 0];
                    else
                    color = [1, 1, 1] - coefficient^0.3 * [0, 1, 1];
                    end
                    color = [0.3 0.3 0.3];
                    width = coefficient * 6;
                    plot3([self.members(i, 3), self.members(i, 6)], [self.members(i, 4), self.members(i, 7)], [self.members(i, 5), self.members(i, 8)], 'LineWidth', width, 'Color', color);
                end
            end
        end
    end
end

