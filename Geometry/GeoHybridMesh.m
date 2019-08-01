classdef GeoHybridMesh < handle

    properties
        groundStructure
        mesh
        geoMesh
        overLappingMap
    end
    
    methods
        function obj = GeoHybridMesh(groundStructure, mesh, geoMesh)
            if nargin > 0
                obj.groundStructure = groundStructure;
            end
            if nargin > 1
                obj.mesh = mesh;
            end
            if nargin > 2
                obj.geoMesh = geoMesh;
            end
        end
        
        function findOverlappingNodes(self)
            gNodes = self.groundStructure.nodeGrid;
            mNodes = self.mesh.Nodes';
            combinedList = [gNodes;mNodes];
            
            index = (1:size(combinedList, 1))';
            [~,~,ic] = unique(combinedList,'rows');
            
            sortedIc = sort(ic);
            diff = [0; sortedIc]-[sortedIc; 0];
            duplicateIndex = sortedIc(diff==0);
            
            overlappingMap = zeros(size(duplicateIndex, 1), 2);
            for i = 1:size(duplicateIndex, 1)
                overlappingMap(i,:) = index(ic == duplicateIndex(i))';
            end
            
            overlappingMap(:, 2) = overlappingMap(:, 2) - size(gNodes, 1);
            self.overLappingMap = overlappingMap;
        end
        
        function initializeContinuumMesh(self)
            edges = createMeshEdges(self.mesh);
            self.geoMesh = Mesh(matlabMesh);
            self.geoMesh.createEdges(edges);
        end
    end
end

