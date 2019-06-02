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
            nodes  = cell(splitNum*4, 1);
            spacing = size/splitNum;
            nodeNum = 0;    
            for i = 1:splitNum
                node = GeoNode(xStart + spacing * (i - 1), yStart);
                nodeNum = nodeNum+1;
                nodes{nodeNum} = node;
            end
            
            for i = 1:splitNum
                node = GeoNode(xStart + size, yStart + spacing * (i - 1));
                nodeNum = nodeNum+1;
                nodes{nodeNum} = node;
            end
            
            for i = 1:splitNum
                node = GeoNode(xStart + size - spacing * (i - 1), yStart + size);
                nodeNum = nodeNum+1;
                nodes{nodeNum} = node;
            end
            
            for i = 1:splitNum
                node = GeoNode(xStart, yStart + size - spacing * (i - 1));
                nodeNum = nodeNum+1;
                nodes{nodeNum} = node;
            end
            
            obj = CellComplexSquare(nodes, splitNum);
            self.nodes = [self.nodes; nodes];
        end
    end
end

