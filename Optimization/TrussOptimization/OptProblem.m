classdef OptProblem < handle
  
    properties
        optObjects
        solverOptions
    end
    
    methods
        function obj = OptProblem()
        end
        
        function [conNum, varNum, objVarNum] = getConAndVarNum(self)
            conNum = 0; varNum = 0; objVarNum= 0;
            for i = 1:size(self.optObjects, 1)
                [conNumToAdd, varNumToAdd, objVarNumToAdd] = self.optObjects{i, 1}.getConAndVarNum();
                conNum = conNum + conNumToAdd;
                varNum = varNum + varNumToAdd;
                objVarNum = objVarNum + objVarNumToAdd;
                if isa(self.optObjects{i, 1}, 'OptObjectMaster')
                    [slaveConNumToAdd, slaveVarNumToAdd, slaveObjVarNumToAdd] = self.optObjects{i, 1}.getSlavesConAndVarNum();
                    conNum = conNum + slaveConNumToAdd;
                    varNum = varNum + slaveVarNumToAdd;
                    objVarNum = objVarNum + slaveObjVarNumToAdd;
                end
            end
        end
        
        function obj = estimateOptObjectNumber(self, groundStructure, loadCases)        
            obj = size(groundStructure.members, 1) + size(groundStructure.nodes, 1);
        end
        
        function obj = createProblem(self, groundStructure, loadCases, supports, solverOptions)
            self.optObjects = cell(self.estimateOptObjectNumber(groundStructure, loadCases), 1);
            self.solverOptions = solverOptions;
            objectNum = 1;
            
            nodeConnection = groundStructure.calcMemberPerNode();
            
            for i = 1:size(groundStructure.nodes, 1)
                self.optObjects{objectNum, 1} = OptNodeMaster();
                self.optObjects{objectNum, 1}.geoNode = groundStructure.nodes{i, 1};
                self.optObjects{objectNum, 1}.connectedMemberNum = nodeConnection(i);
                nodeSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    nodeSlaves{j, 1} = OptNodeSlave();
                    for k = 1:size(loadCases{j, 1}.loads)
                        if (loadCases{j, 1}.loads{k,1}.nodeIndex == i)
                            nodeSlaves{j, 1}.loadX = nodeSlaves{j, 1}.loadX + loadCases{j, 1}.loads{k,1}.loadX;
                            nodeSlaves{j, 1}.loadY = nodeSlaves{j, 1}.loadY + loadCases{j, 1}.loads{k,1}.loadY;
                        end               
                    end
                    
                    for k = 1: size(supports)
                        if (supports{k, 1}.node == i)
                            nodeSlaves{j, 1}.fixedX = supports{k, 1}.fixedX;
                            nodeSlaves{j, 1}.fixedY = supports{k, 1}.fixedY;
                        end
                    end   
                end
                self.optObjects{objectNum, 1}.addSlaves(nodeSlaves);
                objectNum = objectNum+1;
            end
            

            for i = 1:size(groundStructure.members, 1)
                self.optObjects{objectNum, 1} = OptMemberMaster(groundStructure.members{i,1}, solverOptions.sigmaT, solverOptions.sigmaC);
                memberSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    memberSlaves{j, 1} = OptMemberSlave();
                    memberSlaves{j, 1}.master = self.optObjects{objectNum, 1};
                    nodeAIndex = groundStructure.members{i,1}.nodeA.index;
                    nodeBIndex = groundStructure.members{i,1}.nodeB.index;
                    memberSlaves{j, 1}.optNodeA = self.optObjects{nodeAIndex, 1}.slaves{j, 1};
                    memberSlaves{j, 1}.optNodeB = self.optObjects{nodeBIndex, 1}.slaves{j, 1};
                end
                self.optObjects{objectNum, 1}.slaves = memberSlaves;
                objectNum = objectNum+1;
            end
                  
            obj = self;
        end
        
        function optMember = getOptmemberByIndex(self, cellGrid, index)
            optmemberNo = index + size(cellGrid.nodes, 1);
            optMember = self.optObjects{optmemberNo, 1};
        end
        
        function createCellLinks(self, cellGrid)
            optLinkObjects = cell(5*size(cellGrid.cells, 1)*size(cellGrid.cells, 2), 1);
            linkNum = 0;
            innerToBoundRatio = 1/ sqrt(2);
            for i = 1 : size(cellGrid.cells, 1)
                for j =  1 : size(cellGrid.cells, 2)
                    % create links of cell inner members
                    inclinedMemberAIndex = cellGrid.cells{i, j}.members{5, 1}.index;
                    inclinedMemberBIndex = cellGrid.cells{i, j}.members{6, 1}.index;
                    inclinedMemberA = self.getOptmemberByIndex(cellGrid, inclinedMemberAIndex);
                    inclinedMemberB = self.getOptmemberByIndex(cellGrid, inclinedMemberBIndex);
                    link = OptMemberLink();
                    link.linkedMemberA = inclinedMemberA;
                    link.linkedMemberB = inclinedMemberB;
                    link.coefficient = 1;
                    linkNum = linkNum + 1;
                    optLinkObjects{linkNum, 1} = link;
                    
                    % create links of cell boundary members
                    for k = 1:4
                        boundMember = self.getOptmemberByIndex(cellGrid, cellGrid.cells{i, j}.members{k, 1}.index);
                        if (k == 1 && j ==1) || (k == 2 && i == size(cellGrid.cells, 1)) || (k == 3 && j == size(cellGrid.cells, 2)) || (k == 4 && i == 1)
                            link = OptMemberLink();
                            link.linkedMemberA = boundMember;
                            link.linkedMemberB = inclinedMemberA;
                            link.coefficient = innerToBoundRatio;
                            linkNum = linkNum + 1;
                            optLinkObjects{linkNum, 1} = link;
                        else
                            link = OptThreeMemberLink();
                            link.linkedMemberA = boundMember;
                            link.linkedMemberB = inclinedMemberA;
                            link.coefficientB = innerToBoundRatio;
                            if k == 1
                                link.linkedMemberC = self.getOptmemberByIndex(cellGrid, cellGrid.cells{i, j-1}.members{5, 1}.index);
                            elseif k == 2   
                                link.linkedMemberC = self.getOptmemberByIndex(cellGrid, cellGrid.cells{i+1, j}.members{5, 1}.index);
                            elseif k == 3  
                                link.linkedMemberC = self.getOptmemberByIndex(cellGrid, cellGrid.cells{i, j+1}.members{5, 1}.index);
                            elseif k == 4  
                                link.linkedMemberC = self.getOptmemberByIndex(cellGrid, cellGrid.cells{i-1, j}.members{5, 1}.index);
                            end
                            link.coefficientC = innerToBoundRatio;    
                            linkNum = linkNum + 1;
                            optLinkObjects{linkNum, 1} = link;
                        end                      
                    end
                end
            end
                   
            self.optObjects = [self.optObjects; optLinkObjects];
        end
        
        function createComplexCellLinks(self, cellGrid, maxArea, boundMemberCoefficient)
            memberNumPerCell = size(cellGrid.cells{1, 1}.members, 1);
            optLinkObjects = cell((memberNumPerCell+1)*size(cellGrid.cells, 1)*size(cellGrid.cells, 2), 1);
            optLinkObjectNum = 0;
            
            for i=1:size(cellGrid.cells, 1)
                for j = 1:size(cellGrid.cells, 2)
                    currentCell = cellGrid.cells{i, j};
                    optCell = OptCell(maxArea);
                    currentCell.optCell = optCell;
                end
            end
            
            for i=1:size(cellGrid.cells, 1)
                for j = 1:size(cellGrid.cells, 2)
                    currentCell = cellGrid.cells{i, j};
                    optLinkObjectNum = optLinkObjectNum+1;
                    optCell = currentCell.optCell;
                    optLinkObjects{optLinkObjectNum, 1} = optCell;
                    
                    for k=1:4
                        if (k == 1 && j ==1) || (k == 2 && i == size(cellGrid.cells, 1)) || (k == 3 && j == size(cellGrid.cells, 2)) || (k == 4 && i == 1)
                            for l = 1:size(currentCell.boundMembers, 2)
                                currentMember = currentCell.boundMembers{k, l};
                                optMember = self.getOptmemberByIndex(cellGrid, currentMember.index);
                                link = OptMemberLink();
                                link.linkedMemberA = optMember;
                                link.linkedMemberB = optCell;
                                link.coefficient = (currentMember.length * currentCell.splitNum)/boundMemberCoefficient;
                                optLinkObjectNum = optLinkObjectNum+1;
                                optLinkObjects{optLinkObjectNum, 1} = link;
                            end
                        else
                            for l = 1:size(currentCell.boundMembers, 2)
                                currentMember = currentCell.boundMembers{k, l};
                                optMember = self.getOptmemberByIndex(cellGrid, currentMember.index);
                                link = OptThreeMemberLink();
                                link.linkedMemberA = optMember;
                                link.linkedMemberB = optCell;
                                link.coefficientB = (currentMember.length * currentCell.splitNum)/boundMemberCoefficient;
                                if k == 1
                                    link.linkedMemberC = cellGrid.cells{i, j-1}.optCell;
                                elseif k == 2   
                                    link.linkedMemberC = cellGrid.cells{i+1, j}.optCell;
                                elseif k == 3  
                                    link.linkedMemberC = cellGrid.cells{i, j+1}.optCell;
                                elseif k == 4  
                                    link.linkedMemberC = cellGrid.cells{i-1, j}.optCell;
                                end
                                link.coefficientC = (currentMember.length * currentCell.splitNum)/boundMemberCoefficient;  
                                optLinkObjectNum = optLinkObjectNum+1;
                                optLinkObjects{optLinkObjectNum, 1} = link;
                            end
                        end
                    end
                    
                    for k = 1:size(currentCell.innerMembers, 1)
                        currentMember = currentCell.innerMembers{k, 1};
                        optMember = self.getOptmemberByIndex(cellGrid, currentMember.index);
                        link = OptMemberLink();
                        link.linkedMemberA = optCell;
                        link.linkedMemberB = optMember;
                        link.coefficient = 1/currentMember.length;
                        optLinkObjectNum = optLinkObjectNum+1;
                        optLinkObjects{optLinkObjectNum, 1} = link;
                    end           
                end
            end   
            self.optObjects = [self.optObjects; optLinkObjects];
        end
        
        function matrix = calcCoefficients(self, matrix)
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.calcConstraint(matrix);
                self.optObjects{i, 1}.calcObjective(matrix);
            end       
        end
        
        function [obj, matrix] = initializeProblem(self, matrix)
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.initialize(matrix);
            end
            matrix = matrix.initialize();
            matrix = self.calcCoefficients(matrix);
            obj = self;
        end
        
        function feedBackResult(self, loadCaseNum)
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.feedBackResult(loadCaseNum);
            end
        end
    end
end

