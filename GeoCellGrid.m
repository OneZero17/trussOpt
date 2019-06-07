classdef GeoCellGrid < GeoGroundStructure

    properties
        cells
    end
    
    methods
        function obj = GeoCellGrid(cellXNum, cellYNum)
            if(nargin > 0)
                obj.cells = cell(cellXNum, cellYNum);
            end
        end
        
        function obj = getCellXY(self, xIndex, yIndex)
            obj = self.cells(xIndex, yIndex);
        end
        
        function initializeCellNodesAndMembers(self)
            nodeNum = 0;
            memberNum = 0;
            for i=1:size(self.cells, 1)
                for j = 1:size(self.cells, 2)
                    nodeNum = nodeNum + size(self.cells{i,j}.nodes, 1);
                    memberNum = memberNum + size(self.cells{i,j}.members, 1);
                end
            end
            
            self.nodes = cell(nodeNum, 1);
            self.members = cell(memberNum, 1);
            startNodeNum = 1;
            startMemberNum = 1;
            for i=1:size(self.cells, 1)
                for j = 1:size(self.cells, 2)
                    currentNodes = self.cells{i,j}.nodes;
                    currentMembers = self.cells{i,j}.members;
                    endNodeNum = startNodeNum+size(currentNodes, 1) - 1;
                    endMemberNum = startMemberNum + size(currentMembers, 1) - 1;
                    self.nodes(startNodeNum:endNodeNum, 1) = currentNodes;
                    self.members(startMemberNum:endMemberNum, 1) = currentMembers;
                    startNodeNum = endNodeNum+1;
                    startMemberNum = endMemberNum+1;
                end
            end
        end
        
        function cell = createPhaseOneCell(self, xStart, yStart, size)
            node1 = GeoNode(xStart, yStart);
            node2 = GeoNode(xStart + size, yStart);
            node3 = GeoNode(xStart + size, yStart+size);
            node4 = GeoNode(xStart, yStart+size);

            member1 = GeoMember(node1, node2);
            member2 = GeoMember(node2, node3);
            member3 = GeoMember(node3, node4);
            member4 = GeoMember(node4, node1);
            member5 = GeoMember(node1, node3);
            member6 = GeoMember(node2, node4); 
            nodes = {node1; node2; node3; node4};
            members = {member1; member2; member3; member4; member5; member6};
            newNodes = nodes;
            newMembers = members;
            self.nodes = [self.nodes; newNodes];
            self.members = [self.members; newMembers];
            cell = CellSimpleSquare(nodes, members);
            cell.size = size;
            
        end

        function cell = createPharseTwoCell(self, pharseOneCell)
            size = pharseOneCell.size;
            node1 = pharseOneCell.nodes{2, 1};
            node2 = GeoNode(node1.x + size, node1.y);
            node3 = GeoNode(node1.x + size, node1.y + size);
            node4 = pharseOneCell.nodes{3, 1};

            member1 = GeoMember(node1, node2);
            member2 = GeoMember(node2, node3);
            member3 = GeoMember(node3, node4);
            member4 = pharseOneCell.members{2,1};
            member5 = GeoMember(node1, node3);
            member6 = GeoMember(node2, node4); 
            nodes = {node1; node2; node3; node4};
            members = {member1; member2; member3; member4; member5; member6};
            newNodes = {node2; node3};
            newMembers = {member1; member2; member3; member5; member6};
            self.nodes = [self.nodes; newNodes];
            self.members = [self.members; newMembers];
            cell = CellSimpleSquare(nodes, members);
            cell.size = size;
        end

        function cell = createPharseThreeCell(self, pharseOneCell)
            size = pharseOneCell.size;
            node1 = pharseOneCell.nodes{4, 1};
            node2 = pharseOneCell.nodes{3, 1};
            node3 = GeoNode(node1.x + size, node1.y + size);
            node4 = GeoNode(node1.x, node1.y + size);

            member1 = pharseOneCell.members{3,1};
            member2 = GeoMember(node2, node3);
            member3 = GeoMember(node3, node4);
            member4 = GeoMember(node4, node1);
            member5 = GeoMember(node1, node3);
            member6 = GeoMember(node2, node4); 
            nodes = {node1; node2; node3; node4};
            members = {member1; member2; member3; member4; member5; member6};
            newNodes = {node3; node4};
            newMembers = {member2; member3; member4; member5; member6};
            self.nodes = [self.nodes; newNodes];
            self.members = [self.members; newMembers];
            cell = CellSimpleSquare(nodes, members);
            cell.size = size;
        end 

        function cell = createPharseFourCell(self, pharseTwoCell, pharseThreeCell)
            size = pharseTwoCell.size;
            node1 = pharseTwoCell.nodes{4, 1};
            node2 = pharseTwoCell.nodes{3, 1};
            node3 = GeoNode(node1.x + size, node1.y + size);
            node4 = pharseThreeCell.nodes{3, 1};

            member1 = pharseTwoCell.members{3, 1};
            member2 = GeoMember(node2, node3);
            member3 = GeoMember(node3, node4);
            member4 = pharseThreeCell.members{2, 1};
            member5 = GeoMember(node1, node3);
            member6 = GeoMember(node2, node4); 
            nodes = {node1; node2; node3; node4};
            members = {member1; member2; member3; member4; member5; member6};
            newNodes = {node3};
            newMembers = {member2; member3; member5; member6};
            self.nodes = [self.nodes; newNodes];
            self.members = [self.members; newMembers];
            cell = CellSimpleSquare(nodes, members);
            cell.size = size;
        end
        
        function obj = createPharseOneComplexCell(self, xStart, yStart, size, splitNum)    
            obj = CellComplexSquare(xStart, yStart, size, splitNum);
            obj.boundnodes = cell(4, splitNum+1);
            obj.boundMembers = cell(4, splitNum);
            for i = 1:4
                obj.createBoundNodes(i);
            end
            obj.addBoundEndNode();
            for i = 1:4
                obj.createBoundMembers(i);
            end
            obj.createInnerMembers();
        end
        
        function obj = createPharseTwoComplexCell(self, pharseOneCell)    
            obj = CellComplexSquare(pharseOneCell.xStart + pharseOneCell.size, pharseOneCell.yStart, pharseOneCell.size, pharseOneCell.splitNum);
            obj.boundnodes = cell(4, pharseOneCell.splitNum+1);
            obj.boundMembers = cell(4, pharseOneCell.splitNum);
            obj.boundnodes(4,:) = flip(pharseOneCell.boundnodes(2,:));
            obj.createBoundNodes(1, pharseOneCell.boundnodes{2, 1});
            obj.createBoundNodes(2);
            obj.createBoundNodes(3);
            obj.addBoundEndNode();
            obj.boundMembers(4,:) = flip(pharseOneCell.boundMembers(2,:));
            for i = 1:3
                obj.createBoundMembers(i);
            end
            obj.createInnerMembers();
        end
        
        function obj = createPharseThreeComplexCell(self, pharseOneCell)    
            obj = CellComplexSquare(pharseOneCell.xStart , pharseOneCell.yStart + pharseOneCell.size, pharseOneCell.size, pharseOneCell.splitNum);
            obj.boundnodes = cell(4, pharseOneCell.splitNum+1);
            obj.boundMembers = cell(4, pharseOneCell.splitNum);
            obj.boundnodes(1,:) = flip(pharseOneCell.boundnodes(3,:));
            obj.createBoundNodes(2, pharseOneCell.boundnodes{3, 1});
            obj.createBoundNodes(3);
            obj.createBoundNodes(4);
            obj.addBoundEndNode();
            obj.boundMembers(1,:) = flip(pharseOneCell.boundMembers(3,:));
            for i = 2:4
                obj.createBoundMembers(i);
            end
            obj.createInnerMembers();
        end
        
       function obj = createPharseFourComplexCell(self, pharseTwoCell, pharseThreeCell)    
            obj = CellComplexSquare(pharseTwoCell.xStart, pharseTwoCell.yStart + pharseTwoCell.size, pharseTwoCell.size, pharseTwoCell.splitNum);
            obj.boundnodes = cell(4, pharseTwoCell.splitNum+1);
            obj.boundMembers = cell(4, pharseTwoCell.splitNum);
            obj.boundnodes(1,:) = flip(pharseTwoCell.boundnodes(3,:));
            obj.createBoundNodes(2, pharseTwoCell.boundnodes{3, 1});
            obj.createBoundNodes(3);
            obj.boundnodes(4,:) = flip(pharseThreeCell.boundnodes(2,:));
            obj.addBoundEndNode();
            
            obj.boundMembers(1,:) = flip(pharseTwoCell.boundMembers(3,:));
            for i = 2:3
                obj.createBoundMembers(i);
            end
            obj.boundMembers(4,:) = flip(pharseThreeCell.boundMembers(2,:));
            obj.createInnerMembers();
        end
    end
end

