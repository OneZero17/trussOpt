classdef OptProblem < handle
  
    properties
        optObjects
        solverOptions
    end
    
    methods
        function obj = OptProblem()
        end
        
        function [conNum, varNum] = getConAndVarNum(self)
            conNum = 0; varNum = 0;
            for i = 1:size(self.optObjects, 1)
                [conNumToAdd, varNumToAdd] = self.optObjects{i, 1}.getConAndVarNum();
                conNum = conNum + conNumToAdd;
                varNum = varNum + varNumToAdd;
                [slaveConNumToAdd, slaveVarNumToAdd] = self.optObjects{i, 1}.getSlavesConAndVarNum();
                conNum = conNum + slaveConNumToAdd;
                varNum = varNum + slaveVarNumToAdd;
            end
        end
        
        function obj = estimateOptObjectNumber(self, groundStructure, loadCases)        
            obj = size(groundStructure.members, 1) + size(groundStructure.nodes, 1);
        end
        
        function obj = createProblem(self, groundStructure, loadCases, supports, solverOptions)
            self.optObjects = cell(self.estimateOptObjectNumber(groundStructure, loadCases), 1);
            self.solverOptions = solverOptions;
            objectNum = 1;
            
            for i = 1:size(groundStructure.nodes, 1)
                self.optObjects{objectNum, 1} = OptNodeMaster();
                self.optObjects{objectNum, 1}.geoNode = groundStructure.nodes{i, 1};
                nodeSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    nodeSlaves{j, 1} = OptNodeSlave();
                    for k = 1:size(loadCases{j, 1}.loads)
                        if (loadCases{j, 1}.loads{k,1}.nodeIndex == i)
                            nodeSlaves{j, 1}.loadX = loadCases{j, 1}.loads{k,1}.loadX;
                            nodeSlaves{j, 1}.loadY = loadCases{j, 1}.loads{k,1}.loadY;
                        end               
                    end
                    
                    for k = 1: size(supports)
                        if (supports{k, 1}.node == i)
                            nodeSlaves{j, 1}.fixedX = supports{k, 1}.fixedX;
                            nodeSlaves{j, 1}.fixedY = supports{k, 1}.fixedY;
                        end
                    end   
                end
                self.optObjects{objectNum, 1} = self.optObjects{objectNum, 1}.addSlaves(nodeSlaves);
                objectNum = objectNum+1;
            end
            
            for i = 1:size(groundStructure.members, 1)
                self.optObjects{objectNum, 1} = OptMemberMaster();
                self.optObjects{objectNum, 1}.geoMember = groundStructure.members{i,1};
                self.optObjects{objectNum, 1}.sigma = solverOptions.sigma;
                memberSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    memberSlaves{j, 1} = OptMemberSlave();
                    nodeAIndex = groundStructure.members{i,1}.nodeA.index;
                    nodeBIndex = groundStructure.members{i,1}.nodeB.index;
                    memberSlaves{j, 1}.optNodeA = self.optObjects{nodeAIndex, 1}.slaves{j, 1};
                    memberSlaves{j, 1}.optNodeB = self.optObjects{nodeBIndex, 1}.slaves{j, 1};
                end
                self.optObjects{objectNum, 1} = self.optObjects{objectNum, 1}.addSlaves(memberSlaves);
                objectNum = objectNum+1;
            end
            
            obj = self;
        end
        
        function matrix = calcCoefficients(self, matrix)
            for i = 1:size(self.optObjects, 1)
                matrix = self.optObjects{i, 1}.calcConstraint(matrix);
                matrix = self.optObjects{i, 1}.calcObjective(matrix);
            end       
        end
        
        function [obj, matrix] = initializeProblem(self, matrix)
            for i = 1:size(self.optObjects, 1)
                [matrix, self.optObjects{i, 1}] = self.optObjects{i, 1}.initialize(matrix);
            end
            matrix = matrix.initialize();
            matrix = self.calcCoefficients(matrix);
            obj = self;
        end
        
        function feedBackResult(self)
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.feedBackResult();
            end
        end
    end
end

