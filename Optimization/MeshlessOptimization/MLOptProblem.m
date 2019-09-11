classdef MLOptProblem < OptProblem  
    
    properties
    end
    
    methods
        function obj = MLOptProblem()
        end
        
        function obj = estimateOptObjectNumber(self, groundStructure, loadCases)        
            obj = size(groundStructure.members, 1) + size(groundStructure.nodes, 1);
        end
        
        function createProblem(self, nodes, cellIndices, cellLengths, cellNormals, cellAreas, supportingDomainMap, boundaries, boundaryNormals, loadcaseNum)
            
            objectiveNum = size(nodes, 1) + size(cellIndices, 1) + size(boundaries, 1);
            self.optObjects = cell(objectiveNum, 1);
            self.solverOptions = OptOptions();
            objectNum = 1;
            
            for i=1:size(nodes, 1)
                self.optObjects{objectNum, 1} = MLOptNodeMaster(self.solverOptions.sigmaC, cellAreas(i));
                nodeSlaves = cell(loadcaseNum, 1);
                for j = 1:loadcaseNum
                    nodeSlaves{j, 1} = MLOptNodeSlave();
                end
                self.optObjects{objectNum, 1}.addSlaves(nodeSlaves);
                objectNum = objectNum + 1;
            end
            
            optNodes = self.optObjects(cellfun('isclass', self.optObjects, 'MLOptNodeMaster')); 
            for i = 1:size(cellIndices, 1)
                currentCell = cellIndices{i, 1};
                cellNodeSupportDomain = cell(size(currentCell, 1) - 1, 2);
                for j = 1:size(currentCell, 1)-1
                    currentNode = currentCell(j, 1);
                    supportNodes = supportingDomainMap{currentNode, 1};
                    supportNodeObjects = optNodes(supportNodes);
                    supportCoefficients = supportingDomainMap{currentNode, 3};
                    cellNodeSupportDomain{j, 1} = supportNodeObjects;
                    cellNodeSupportDomain{j, 2} = supportCoefficients';
                end
                self.optObjects{objectNum, 1} = MLOptCellMaster(cellNodeSupportDomain(:, 1), cellLengths{i, 1}, cellNodeSupportDomain(:, 2), cellAreas(i, 1), cellNormals{i, 1});
                cellSlaves = cell(loadcaseNum, 1);
                for j = 1:loadcaseNum
                    cellSlaves{j, 1} = MLOptCellSlave();
                end
                self.optObjects{objectNum, 1}.addSlaves(cellSlaves);
                objectNum = objectNum + 1;
            end
            
            for i = 1:size(boundaries, 1)
                cellNodeSupportDomain = cell(2, 2);
                for j = 1:2
                    currentNode = boundaries(i, j);
                    supportNodes = supportingDomainMap{currentNode, 1};
                    supportNodeObjects = optNodes(supportNodes);
                    supportCoefficients = supportingDomainMap{currentNode, 3};
                    cellNodeSupportDomain{j, 1} = supportNodeObjects;
                    cellNodeSupportDomain{j, 2} = supportCoefficients';
                end
                centralNode = optNodes(boundaries(i, 3));
                self.optObjects{objectNum, 1} = MLOptBoundaryMaster(centralNode, cellNodeSupportDomain(:, 1), boundaries(i, 4), boundaryNormals(i, :), cellNodeSupportDomain(:, 2));
                boundarySlaves = cell(loadcaseNum, 1);
                for j = 1:loadcaseNum
                    boundarySlaves{j, 1} = MLOptBoundarySlave();
                end
                self.optObjects{objectNum, 1}.addSlaves(boundarySlaves);
                objectNum = objectNum + 1;
            end
            
        end
    end
end

