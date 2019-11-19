classdef OptBeamProblem < OptProblem
    properties
    end
    
    methods
        function obj = OptBeamProblem()
        end
        
        function obj = createProblem(self, groundStructure, loadCases, supports, solverOptions)
            if(nargin < 6)
                jointLength = 0;
            end
            
            self.optObjects = cell(self.estimateOptObjectNumber(groundStructure, loadCases), 1);
            self.solverOptions = solverOptions;
            objectNum = 1;
            
            nodeConnection = groundStructure.calcMemberPerNode();
            
            for i = 1:size(groundStructure.nodeGrid, 1)
                self.optObjects{objectNum, 1} = OptBeamNodeMaster();
                self.optObjects{objectNum, 1}.geoNode = groundStructure.nodeGrid(i, :);
                self.optObjects{objectNum, 1}.connectedMemberNum = nodeConnection(i);
                nodeSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    nodeSlaves{j, 1} = OptBeamNodeSlave();
                    for k = 1:size(loadCases{j, 1}.loads)
                        if (loadCases{j, 1}.loads{k,1}.nodeIndex == i)
                            nodeSlaves{j, 1}.loadX = nodeSlaves{j, 1}.loadX + loadCases{j, 1}.loads{k,1}.loadX;
                            nodeSlaves{j, 1}.loadY = nodeSlaves{j, 1}.loadY + loadCases{j, 1}.loads{k,1}.loadY;
                            nodeSlaves{j, 1}.loadMoment = nodeSlaves{j, 1}.loadMoment + loadCases{j, 1}.loads{k,1}.loadMoment;
                        end               
                    end
                    
                    for k = 1: size(supports)
                        if (supports{k, 1}.node == i)
                            nodeSlaves{j, 1}.fixedX = supports{k, 1}.fixedX;
                            nodeSlaves{j, 1}.fixedY = supports{k, 1}.fixedY;
                            nodeSlaves{j, 1}.fixedMoment = supports{k, 1}.fixedMoment;
                        end
                    end   
                end
                self.optObjects{objectNum, 1}.addSlaves(nodeSlaves);
                objectNum = objectNum+1;
            end
            
            for i = 1:size(groundStructure.memberList, 1)
                self.optObjects{objectNum, 1} = OptBeamMemberMaster(groundStructure.memberList(i,:), solverOptions.sigmaT, solverOptions.jointLength, solverOptions.allowExistingBeamVolume>0);
                memberSlaves = cell(size(loadCases, 1), 1);
                for j = 1:size(loadCases, 1)
                    memberSlaves{j, 1} = OptBeamMemberSlave(solverOptions.sectionModulus);
                    memberSlaves{j, 1}.master = self.optObjects{objectNum, 1};
                    nodeAIndex = groundStructure.memberList(i, 1);
                    nodeBIndex = groundStructure.memberList(i, 2);
                    memberSlaves{j, 1}.optNodeA = self.optObjects{nodeAIndex, 1}.slaves{j, 1};
                    memberSlaves{j, 1}.optNodeB = self.optObjects{nodeBIndex, 1}.slaves{j, 1};
                end
                self.optObjects{objectNum, 1}.slaves = memberSlaves;
                objectNum = objectNum+1;
            end
            obj = self;
        end
        
       function result = outputResult(self, loadCaseNo)
            optMembers = self.optObjects(cellfun('isclass', self.optObjects, 'OptBeamMemberMaster')); 
            memberNum = size(optMembers, 1);
            result = zeros(memberNum, 6);
            for i = 1:memberNum
                currentMember = optMembers{i, 1}.slaves{loadCaseNo, 1};
                result(i, 1) = optMembers{i, 1}.totalAreaVariable.value;
                result(i, 2) = currentMember.forceAreaVariable.value;
                result(i, 3) = currentMember.momentAreaVariable.value;
                result(i, 4) = currentMember.forceVariable.value;
                result(i, 5) = currentMember.momentVariableA.value;
                result(i, 6) = currentMember.momentVariableB.value;
            end
       end
        
       function addBeamVolumeConstraint(self, matrix, allowExistingBeamVolume)
           optMembers = self.optObjects(cellfun('isclass', self.optObjects, 'OptBeamMemberMaster')); 
           memberNum = size(optMembers, 1);
           beamVolumeConstraint = matrix.addConstraint(0, allowExistingBeamVolume, memberNum, 'beamVolumeConstraint');
           for i = 1:memberNum
               beamVolumeConstraint.addVariable(optMembers{i, 1}.slaves{1, 1}.momentAreaVariable, 1);
           end
       end
    end
end

