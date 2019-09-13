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
            
            % add optNodes
            for i=1:size(nodes, 1)
                self.optObjects{objectNum, 1} = MLOptNodeMaster(self.solverOptions.sigmaC, cellAreas(i));
                nodeSlaves = cell(loadcaseNum, 1);
                for j = 1:loadcaseNum
                    nodeSlaves{j, 1} = MLOptNodeSlave();
                end
                self.optObjects{objectNum, 1}.addSlaves(nodeSlaves);
                objectNum = objectNum + 1;
            end
            
            % add optCells
            optNodes = self.optObjects(cellfun('isclass', self.optObjects, 'MLOptNodeMaster')); 
            for i = 1:size(cellIndices, 1)
                currentCell = cellIndices{i, 1};
                cellNodeSupportDomain = cell(size(currentCell, 1) - 1, 2);
                for j = 1:size(currentCell, 1)-1
                    currentNode = currentCell(j, 1);
                    supportNodes = supportingDomainMap{currentNode, 1};
                    supportNodeObjects = optNodes(supportNodes);
                    supportCoefficients = supportingDomainMap{currentNode, 2};
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
                
                % add optBoundaryCells               
                boundariesCellNormals = boundaryNormals(boundaries(:, 3)==i, :);
                boundaryFixedCondition = boundaries(boundaries(:, 3)==i, 7:8);
                for j = 1:size(boundariesCellNormals, 1)
                    self.optObjects{objectNum, 1} = MLOptBoundaryCellMaster(cellNodeSupportDomain(:, 1), cellLengths{i, 1}, cellNodeSupportDomain(:, 2), cellAreas(i, 1), boundariesCellNormals(j, :), boundaryFixedCondition(j, 1), boundaryFixedCondition(j, 2));
                    boundaryCellSlaves = cell(loadcaseNum, 1);
                    for k = 1:loadcaseNum
                        boundaryCellSlaves{k, 1} = MLOptBoundaryCellSlave();
                    end
                    self.optObjects{objectNum, 1}.addSlaves(boundaryCellSlaves);
                    objectNum = objectNum + 1;
                end
            end
            

            
            % add optBoundaries
            for i = 1:size(boundaries, 1)
                cellNodeSupportDomain = cell(2, 2);
                for j = 1:2
                    currentNode = boundaries(i, j);
                    supportNodes = supportingDomainMap{currentNode, 1};
                    supportNodeObjects = optNodes(supportNodes);
                    supportCoefficients = supportingDomainMap{currentNode, 2};
                    cellNodeSupportDomain{j, 1} = supportNodeObjects;
                    cellNodeSupportDomain{j, 2} = supportCoefficients';
                end
                centralNode = optNodes(boundaries(i, 3));
                self.optObjects{objectNum, 1} = MLOptBoundaryMaster(centralNode, cellNodeSupportDomain(:, 1), boundaries(i, 4), boundaryNormals(i, :), cellNodeSupportDomain(:, 2), boundaries(i, 7), boundaries(i, 8));
                
                boundarySlaves = cell(loadcaseNum, 1);
                for j = 1:loadcaseNum
                    boundarySlaves{j, 1} = MLOptBoundarySlave(boundaries(i, 5), boundaries(i, 6));
                end
                self.optObjects{objectNum, 1}.addSlaves(boundarySlaves);
                objectNum = objectNum + 1;
            end
        end
        
        function densityList = generateDensityList(self)
            optNodes = self.optObjects(cellfun('isclass', self.optObjects, 'MLOptNodeMaster')); 
            nodeNum = size(optNodes, 1);
            densityList = zeros(nodeNum, 1);
            for i = 1:nodeNum
                densityList(i, 1) = optNodes{i, 1}.densityVariable.value;
            end
        end
        
        function stressList = generateStressList(self)
            optNodes = self.optObjects(cellfun('isclass', self.optObjects, 'MLOptNodeMaster')); 
            nodeNum = size(optNodes, 1);
            stressList = zeros(nodeNum, 3);  
            for i = 1:nodeNum
                stressList(i, 1) = optNodes{i, 1}.slaves{1, 1}.sigmaXXVariable.value;
                stressList(i, 2) = optNodes{i, 1}.slaves{1, 1}.sigmaYYVariable.value;
                stressList(i, 3) = optNodes{i, 1}.slaves{1, 1}.tauXYVariable.value;
            end
        end
    end
end

