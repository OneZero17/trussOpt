classdef HybridProblem < handle

    properties
        continuumProblem
        trussProblem
        hybridMesh
        optObjects;
    end
    
    methods
        function obj = HybridProblem(hybridMesh, continuumProblem, trussProblem)
            if nargin > 0
                obj.hybridMesh = hybridMesh;
            end
            if nargin > 1
                obj.continuumProblem = continuumProblem;
            end
            if nargin > 2
                obj.trussProblem = trussProblem;
            end
        end
        
        function initializeProblem(self, matrix)
            self.trussProblem.initializeProblem(matrix);
            self.continuumProblem.initializeProblem(matrix);
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.initialize(matrix);
            end
            matrix.initialize();
            self.calcCoefficients(matrix);
            self.deleteTrussNodeEquilibriumConstraints(matrix);
        end
        
        function calcCoefficients(self, matrix)
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.calcConstraint(matrix);
                self.optObjects{i, 1}.calcObjective(matrix);
            end       
        end
        
        function addJointLengthToHybridNodes(self, jointlength)
            hybridTrussNodes = cell2mat(self.hybridMesh.nodeWithinRadiusMap(:, 1));
            memberList = self.hybridMesh.groundStructure.getMembersConnectedToNodes(hybridTrussNodes);
            trussProblemObjects = self.trussProblem.optObjects;
            memberObjects = trussProblemObjects(cellfun('isclass', trussProblemObjects, 'OptMemberMaster'));
            for i = 1:size(memberList, 1)
                memberObjects{i, 1}.jointLength = jointlength;
            end
        end
        
        function deleteTrussNodeEquilibriumConstraints(self, matrix)
%             overLappingMap = self.hybridMesh.overLappingMap;
%             trussProblemObjects = self.trussProblem.optObjects;
%             optTrussNodes = trussProblemObjects(cellfun('isclass', trussProblemObjects, 'OptNodeMaster'));           
            for i = 1:size(self.optObjects)
                trussNodeOptObject = self.optObjects{i, 1}.optNode;
                slaveNum = size(trussNodeOptObject.slaves, 1);
                for j = 1:size(slaveNum, 1)
                    nodeSlave = trussNodeOptObject.slaves{j, 1};
                    if nodeSlave.equilibriumConstraintX ~= -1
                        matrix.constraints{nodeSlave.equilibriumConstraintX.index, 1} = [];
                        nodeSlave.equilibriumConstraintX = -1;
                    end
                    
                    if nodeSlave.equilibriumConstraintY ~= -1
                        matrix.constraints{nodeSlave.equilibriumConstraintY.index, 1} = [];
                        nodeSlave.equilibriumConstraintY = -1;
                    end
                end
                
            end           
%             for i = 1:size(overLappingMap, 1)
%                 trussNodeOptObject = optTrussNodes{overLappingMap(i, 1), 1};
%                 slaveNum = size(trussNodeOptObject.slaves, 1);
%                 
%                 for j = 1:size(slaveNum, 1)
%                     nodeSlave = trussNodeOptObject.slaves{j, 1};
%                     if nodeSlave.equilibriumConstraintX ~= -1
%                         matrix.constraints{nodeSlave.equilibriumConstraintX.index, 1} = [];
%                         nodeSlave.equilibriumConstraintX = -1;
%                     end
%                     
%                     if nodeSlave.equilibriumConstraintY ~= -1
%                         matrix.constraints{nodeSlave.equilibriumConstraintY.index, 1} = [];
%                         nodeSlave.equilibriumConstraintY = -1;
%                     end
%                 end
%             end       
        end
        
        function createHybridElementsWithinRadius(self, loadCaseNum)
            nodeWithinRadiusMap = self.hybridMesh.nodeWithinRadiusMap;
            self.optObjects = cell(size(nodeWithinRadiusMap, 1), 1);

            meshEdges = self.hybridMesh.mesh.Edges;
            meshEdges = [(1:size(meshEdges, 1))', meshEdges];
            externalEdges = meshEdges(meshEdges(:, 5) == 0, :);
            externalEdges = [externalEdges, (1:size(externalEdges))'];
%             
%             externalEdges(externalEdges(:,end-1)~=0, :)= [];
            externalEdges(:, end - 1) = [];
            continuumProblemObjects = self.continuumProblem.optObjects;
            trussProblemObjects = self.trussProblem.optObjects;
            optBoundaries = continuumProblemObjects(cellfun('isclass', continuumProblemObjects, 'COptBoundaryMaster'));       
            optTrussNodes = trussProblemObjects(cellfun('isclass', trussProblemObjects, 'OptNodeMaster'));
            
            hybridObjectNum = 0;

            for i = 1:size(nodeWithinRadiusMap, 1)
                connectedNodeNum = size(nodeWithinRadiusMap{i, 2}, 2);
                edgeObjects = cell(connectedNodeNum, 1);
                totalLinkedNodes = zeros(connectedNodeNum, 1);
                addBoundaryNum = 1;
                for j = 1:connectedNodeNum
                    currentNode = nodeWithinRadiusMap{i, 2}(j);
                    connectedExternalEdges = externalEdges(externalEdges(:, 2) == currentNode | externalEdges(:, 3) == currentNode, :);
                    externalEdgeObjects = optBoundaries(connectedExternalEdges(:, end));
                    connectedEdges = connectedExternalEdges(:, 1:end-1);

                    linkedNodes = zeros(size(externalEdgeObjects, 1), 1);
                    linkedNodes(connectedEdges(:, 2) == currentNode) = 1;
                    linkedNodes(connectedEdges(:, 3) == currentNode) = 2;
                    connectedEdgeNum = size(externalEdgeObjects, 1);
                    edgeObjects(addBoundaryNum:addBoundaryNum + connectedEdgeNum - 1, 1) = externalEdgeObjects;
                    totalLinkedNodes(addBoundaryNum:addBoundaryNum + connectedEdgeNum - 1, 1) = linkedNodes;
                    addBoundaryNum = addBoundaryNum + connectedEdgeNum;
                end
                edgeObjects = edgeObjects(~cellfun('isempty', edgeObjects));
                totalLinkedNodes = totalLinkedNodes(~cellfun('isempty', edgeObjects));
                hybridNodeMaster = HybridNodeMaster(optTrussNodes{nodeWithinRadiusMap{i, 1}, 1}, edgeObjects, totalLinkedNodes);
                hybridNodeSlaves = cell(loadCaseNum, 1);
                for k = 1:loadCaseNum
                    hybridNodeSlaves{k, 1} = HybridNodeSlave();
                end
                hybridNodeMaster.addSlaves(hybridNodeSlaves);
                hybridObjectNum = hybridObjectNum + 1;
                self.optObjects{hybridObjectNum, 1} = hybridNodeMaster;
            end
            
        end
        
        function createHybridElements(self, loadCaseNum)

            geoMesh = self.hybridMesh.geoMesh;
            
            overlappingMap = self.hybridMesh.overLappingMap;
            self.optObjects = cell(size(overlappingMap, 1), 1);

            meshEdges = self.hybridMesh.mesh.Edges;
            meshEdges = [(1:size(meshEdges, 1))', meshEdges];
            meshNodes = self.hybridMesh.mesh.Nodes';
            internalEdges = meshEdges(meshEdges(:, 5) ~= 0, :);
            externalEdges = meshEdges(meshEdges(:, 5) == 0, :);
%             externalEdges = [externalEdges, (1:size(externalEdges))'];
%             
%             externalEdges(externalEdges(:,end-1)~=0, :)= [];
%             externalEdges(:, end - 1) = [];
            continuumProblemObjects = self.continuumProblem.optObjects;
            trussProblemObjects = self.trussProblem.optObjects;
            optBoundaries = continuumProblemObjects(cellfun('isclass', continuumProblemObjects, 'COptBoundaryMaster'));      
             
            optTrussNodes = trussProblemObjects(cellfun('isclass', trussProblemObjects, 'OptNodeMaster'));
            
            hybridObjectNum = 0;

            for i = 1:size(overlappingMap, 1)
                currentNode = overlappingMap(i, 2);
                connectedExternalEdges = externalEdges(externalEdges(:, 2) == currentNode | externalEdges(:, 3) == currentNode, :);
                externalEdgeObjects = optBoundaries(connectedExternalEdges(:, end));
                connectedEdges = [connectedExternalEdges(:, 1:end-1)];
                edgeObjects = [externalEdgeObjects];

                linkedNodes = zeros(size(edgeObjects, 1), 2);
                linkedNodes(connectedEdges(:, 2) == currentNode) = 1;
                linkedNodes(connectedEdges(:, 3) == currentNode) = 2;
                
                if size(linkedNodes, 1) == 2
                    elementOfEdge1 = meshEdges(meshEdges(:, 4) == connectedEdges(1, 4) | meshEdges(:, 5) == connectedEdges(1, 4));
                    elementOfEdge2 = meshEdges(meshEdges(:, 4) == connectedEdges(2, 4) | meshEdges(:, 5) == connectedEdges(2, 4));
                    commonEdges = intersect(elementOfEdge1, elementOfEdge2);
                    if ~isempty(commonEdges)
                        linkedNodes(:, 2) = [1; 1];
                    end
                end
                if size(linkedNodes, 1) > 2
                    linkedNodes(:, 2) = zeros(size(linkedNodes, 1), 1);
                end
                hybridNodeMaster = HybridNodeMaster(optTrussNodes{overlappingMap(i, 1), 1}, edgeObjects, linkedNodes);
                
                hybridNodeSlaves = cell(loadCaseNum, 1);
                for k = 1:loadCaseNum
                    hybridNodeSlaves{k, 1} = HybridNodeSlave();
                end
                hybridNodeMaster.addSlaves(hybridNodeSlaves);
                
                hybridObjectNum = hybridObjectNum + 1;
                self.optObjects{hybridObjectNum, 1} = hybridNodeMaster;
            end
        end
    end
end

