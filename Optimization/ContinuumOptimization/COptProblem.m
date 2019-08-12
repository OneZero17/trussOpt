classdef COptProblem < OptProblem   
    properties
    end
    
    methods
        function obj = COptProblem()
        end
        
        function obj = estimateOptObjectNumber(self, mesh, loadCases)        
            elementNum = size(mesh.meshFacets, 1);
            edgeNum = size(mesh.meshEdges, 1);
            loadcaseNum = size(loadCases, 1);
            obj = elementNum*(1+loadcaseNum) + edgeNum * loadcaseNum * 2;
        end
        
        function obj = createProblem(self, mesh, edges, loadCases, supports, solverOptions, thickness)
            self.optObjects = cell(self.estimateOptObjectNumber(mesh, loadCases), 1);
            self.solverOptions = solverOptions;
            objectNum = 1;
            elementNum = size(mesh.meshFacets, 1);
            edgeNum = size(mesh.meshEdges, 1);
            loadcaseNum = size(loadCases, 1);

            %% Add equiilibrium within an element 
            for i = 1:elementNum
                self.optObjects{objectNum, 1} = COptTriangularElementMaster(solverOptions.sigmaC, mesh.meshFacets{i, 1}, solverOptions.useVonMises, thickness);
                elementSlaves = cell(loadcaseNum, 1);
                for j = 1: loadcaseNum
                    elementSlaves{j, 1} = COptTriangularElementSlave();
                end
                self.optObjects{objectNum, 1}.addSlaves(elementSlaves);
                objectNum = objectNum + 1;
            end
            edges = [edges, [1:size(edges, 1)]'];
            innerEdges = edges(edges(:, 4)~=0, :);
            
            %% Add equilibrium on edge between elements 
            for i = 1: size(innerEdges, 1)
                coptElementA = self.optObjects{innerEdges(i, 3), 1};
                coptElementB = self.optObjects{innerEdges(i, 4), 1};
                self.optObjects{objectNum, 1} = COptEdgeMaster(mesh.meshEdges{innerEdges(i, 6), 1}, coptElementA, coptElementB); 
                edgeSlaves = cell(loadcaseNum, 1);
                for j = 1: loadcaseNum
                    edgeSlaves{j, 1} = COptEdgeSlave();
                end
                self.optObjects{objectNum, 1}.addSlaves(edgeSlaves);
                objectNum = objectNum + 1;
            end
            
            %% Add boundary conditions
            externalEdges = edges(edges(:, 4)==0, :);
            % Add eight columns: node1X fixed, node1Y fixed, node2X fixed,
            % node2Y fixed, node1X load, node1Y load, node2X load, node2Y
            % load

            externalEdges = [externalEdges, zeros(size(externalEdges, 1), 8)];
            externalEdges = [(1:size(externalEdges, 1))', externalEdges];
            for i = 1:size(supports, 1)
                supportID = supports{i, 1}.node;
                node1Supported = externalEdges(externalEdges(:, 2) == supportID, :);
                node2Supported = externalEdges(externalEdges(:, 3) == supportID, :);
                for j = 1:size(node1Supported, 1)
                    externalEdges(node1Supported(j, 1), 8:9) = [supports{i, 1}.fixedX, supports{i, 1}.fixedY];
                end
                for j = 1:size(node2Supported, 1)
                    externalEdges(node2Supported(j, 1), 10:11) = [supports{i, 1}.fixedX, supports{i, 1}.fixedY];
                end
            end
            
            currentObjectNum = objectNum;
            
            for i = 1:size(externalEdges, 1)
                coptElement = self.optObjects{externalEdges(i, 4), 1};
                self.optObjects{objectNum, 1} = COptBoundaryMaster(mesh.meshEdges{externalEdges(i, 7), 1}, coptElement); 
                self.optObjects{objectNum, 1}.node1XSupported = externalEdges(i, 8);
                self.optObjects{objectNum, 1}.node1YSupported = externalEdges(i, 9);
                self.optObjects{objectNum, 1}.node2XSupported = externalEdges(i, 10);
                self.optObjects{objectNum, 1}.node2YSupported = externalEdges(i, 11);
                objectNum = objectNum + 1;
            end
            
            boundarySlaves = cell(size(externalEdges, 1), loadcaseNum);

            for i = 1:loadcaseNum
                loadcase = loadCases{i, 1};
                for j = 1: size(loadcase.loads)
                    loadID = loadcase.loads{j, 1}.nodeIndex;
                    contactedEdges = [externalEdges(externalEdges(:, 2) == loadID & externalEdges(:, 6) == 1, 1); externalEdges(externalEdges(:, 3) == loadID & externalEdges(:, 6) == 1, 1)];
                    edgeTotalLength = 0;
                    for k = 1:size(contactedEdges, 1)
                        edgeTotalLength = edgeTotalLength + mesh.meshEdges{externalEdges(contactedEdges(k), 7), 1}.length;
                    end
                    if (edgeTotalLength ~= 0)
                        if max(externalEdges(:, 2) == loadID & externalEdges(:, 6) == 1) ~= 0
                        externalEdges(externalEdges(:, 2) == loadID & externalEdges(:, 6) == 1, 12:13) = [2 * loadcase.loads{i, 1}.loadX / edgeTotalLength, 2 * loadcase.loads{i, 1}.loadY / edgeTotalLength];
                        end
                        if max(externalEdges(:, 3) == loadID & externalEdges(:, 6) == 1) ~= 0
                        externalEdges(externalEdges(:, 3) == loadID & externalEdges(:, 6) == 1, 14:15) = [2 * loadcase.loads{i, 1}.loadX / edgeTotalLength, 2 * loadcase.loads{i, 1}.loadY / edgeTotalLength];
                        end
                    end
                end
                for j = 1:size(externalEdges, 1)
                    boundarySlaves{j, i} = COptBoundarySlave(externalEdges(j, 12:15)');
                end          
            end
            
            for i = 1 : size(externalEdges, 1)
                self.optObjects{currentObjectNum, 1}.addSlaves(boundarySlaves(i, :)');
                currentObjectNum = currentObjectNum + 1;
            end
            
            self.optObjects = self.optObjects(~cellfun('isempty',self.optObjects));
        end
    end
end

