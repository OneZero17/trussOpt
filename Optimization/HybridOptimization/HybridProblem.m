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
        end
        
        function calcCoefficients(self, matrix)
            for i = 1:size(self.optObjects, 1)
                self.optObjects{i, 1}.calcConstraint(matrix);
                self.optObjects{i, 1}.calcObjective(matrix);
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
            externalEdges = [externalEdges, (1:size(externalEdges))'];
            %left and right edge both excluded
            externalEdges = [externalEdges, zeros(size(externalEdges, 1), 1)];
            for i = 1:size(externalEdges, 1)
                externalEdges(i, end) = meshNodes(externalEdges(i, 2), 2) - meshNodes(externalEdges(i, 3), 2);
            end
            externalEdges(externalEdges(:,end)~=0, :)= [];
            externalEdges(:, end) = [];
            continuumProblemObjects = self.continuumProblem.optObjects;
            trussProblemObjects = self.trussProblem.optObjects;
            optBoundaries = continuumProblemObjects(cellfun('isclass', continuumProblemObjects, 'COptBoundaryMaster'));      
            optFacets = continuumProblemObjects(cellfun('isclass', continuumProblemObjects, 'COptTriangularElementMaster'));  
            optTrussNodes = trussProblemObjects(cellfun('isclass', trussProblemObjects, 'OptNodeMaster'));
            
            %newBoundaryObjects = cell(8*size(overlappingMap, 1), 1);
            %newBoundaryObjectNum = 1;
            hybridObjectNum = 0;
            
            for i = 1:size(overlappingMap, 1)
                currentNode = overlappingMap(i, 2);
                connectedExternalEdges = externalEdges(externalEdges(:, 2) == currentNode | externalEdges(:, 3) == currentNode, :);
%                 connectedIternalEdges = internalEdges(internalEdges(:, 2) == currentNode | internalEdges(:, 3) == currentNode, :);
                externalEdgeObjects = optBoundaries(connectedExternalEdges(:, end));
%                 internalEdgeObjects = cell(size(connectedIternalEdges, 1), 1);
%                 for j = 1:size(connectedIternalEdges)
%                     internalEdgeObjects{j, 1} = COptBoundaryMaster(geoMesh.meshEdges{connectedIternalEdges(j, 1)}, optFacets{connectedIternalEdges(j, 4)});
%                     slaves = cell(loadCaseNum, 1);
%                     for k = 1:loadCaseNum
%                         slaves{k, 1} = COptBoundarySlave();
%                     end
%                     internalEdgeObjects{j, 1}.addSlaves(slaves);
%                 end
%                 
%                 newBoundaryObjects(newBoundaryObjectNum:newBoundaryObjectNum + size(connectedIternalEdges) - 1, 1) = internalEdgeObjects;
%                 newBoundaryObjectNum = newBoundaryObjectNum + size(connectedIternalEdges);
                
                %connectedEdges = [connectedExternalEdges(:, 1:end-1);connectedIternalEdges ];
                %edgeObjects = [externalEdgeObjects; internalEdgeObjects];
                connectedEdges = [connectedExternalEdges(:, 1:end-1)];
                edgeObjects = [externalEdgeObjects];

                linkedNodes = zeros(size(edgeObjects, 1), 1);
                linkedNodes(connectedEdges(:, 2) == currentNode) = 1;
                linkedNodes(connectedEdges(:, 3) == currentNode) = 2;
                hybridNodeMaster = HybridNodeMaster(optTrussNodes{overlappingMap(i, 1), 1}, edgeObjects, linkedNodes);
                
                hybridNodeSlaves = cell(loadCaseNum, 1);
                for k = 1:loadCaseNum
                    hybridNodeSlaves{k, 1} = HybridNodeSlave();
                end
                hybridNodeMaster.addSlaves(hybridNodeSlaves);
                
                hybridObjectNum = hybridObjectNum + 1;
                self.optObjects{hybridObjectNum, 1} = hybridNodeMaster;
            end
            
%             newBoundaryObjects = newBoundaryObjects(~cellfun('isempty', newBoundaryObjects));
%             self.continuumProblem.optObjects = [self.continuumProblem.optObjects; newBoundaryObjects];
        end
    end
end

