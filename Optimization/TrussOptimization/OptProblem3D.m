classdef OptProblem3D < OptProblem
    
    properties
        
    end
    
    methods
        function obj = OptProblem3D()
        end
        
        function obj = createProblem(self, groundStructure, loadCases, supports, solverOptions, jointLength)
            if(nargin < 6)
                jointLength = 0;
            end
            
            self.optObjects = cell(self.estimateOptObjectNumber(groundStructure, loadCases), 1);
            self.solverOptions = solverOptions;
            objectNum = 1;
            
            nodeConnection = groundStructure.calcMemberPerNode();
            
            for i = 1:size(groundStructure.nodes, 1)
                self.optObjects{objectNum, 1} = OptNodeMaster();
                self.optObjects{objectNum, 1}.geoNode = groundStructure.nodes(i, :);
                self.optObjects{objectNum, 1}.connectedMemberNum = nodeConnection(i);
                nodeSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    nodeSlaves{j, 1} = OptNodeSlave3D();
                    for k = 1:size(loadCases{j, 1}.loads)
                        if (loadCases{j, 1}.loads{k,1}.nodeIndex == i)
                            nodeSlaves{j, 1}.loadX = nodeSlaves{j, 1}.loadX + loadCases{j, 1}.loads{k,1}.loadX;
                            nodeSlaves{j, 1}.loadY = nodeSlaves{j, 1}.loadY + loadCases{j, 1}.loads{k,1}.loadY;
                            nodeSlaves{j, 1}.loadZ = nodeSlaves{j, 1}.loadZ + loadCases{j, 1}.loads{k,1}.loadZ;
                        end               
                    end
                    
                    for k = 1: size(supports)
                        if (supports{k, 1}.node == i)
                            nodeSlaves{j, 1}.fixedX = supports{k, 1}.fixedX;
                            nodeSlaves{j, 1}.fixedY = supports{k, 1}.fixedY;
                            nodeSlaves{j, 1}.fixedZ = supports{k, 1}.fixedZ;
                        end
                    end   
                end
                self.optObjects{objectNum, 1}.addSlaves(nodeSlaves);
                objectNum = objectNum+1;
            end
            
            for i = 1:size(groundStructure.members, 1)
                self.optObjects{objectNum, 1} = OptMemberMaster3D(groundStructure.members(i,:), solverOptions.sigmaT, solverOptions.sigmaC, jointLength);
                memberSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    memberSlaves{j, 1} = OptMemberSlave3D();
                    memberSlaves{j, 1}.master = self.optObjects{objectNum, 1};
                    nodeAIndex = groundStructure.members(i, 1);
                    nodeBIndex = groundStructure.members(i, 2);
                    memberSlaves{j, 1}.optNodeA = self.optObjects{nodeAIndex, 1}.slaves{j, 1};
                    memberSlaves{j, 1}.optNodeB = self.optObjects{nodeBIndex, 1}.slaves{j, 1};
                end
                self.optObjects{objectNum, 1}.slaves = memberSlaves;
                objectNum = objectNum+1;
            end     
            obj = self;
        end
        
        function forceList = outputForceList(self, loadCaseNum)
            optMembers = self.optObjects(cellfun('isclass', self.optObjects, 'OptMemberMaster3D')); 
            memberNum = size(optMembers, 1);
            forceList = zeros(memberNum, 1);
            for i = 1:memberNum
                forceList(i, 1) = optMembers{i, 1}.slaves{loadCaseNum, 1}.forceVariable.value;
            end
        end
    end
end

