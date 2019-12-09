classdef PPOptProblem3D < OptProblem
    properties
        facetMap
    end
    
    methods
        function obj = PPOptProblem3D()
        end
        
        
        
        function createProblem(self, splitedMembers, nozzleMaxAngle, maxTurnAngle, solverOptions, knowAngleValue)
            xZoneNumber = size(splitedMembers, 1);
            yZoneNumber = size(splitedMembers{1, 1}, 1);
            self.optObjects = cell(3 * xZoneNumber * yZoneNumber - 2, 1);
            self.facetMap = cell(xZoneNumber, yZoneNumber);
            addedObjectNumber = 0;
            for i = 1:xZoneNumber
                for j = 1:yZoneNumber
                    zoneMembers = splitedMembers{i, 1}{j, 1};
                    length = ((zoneMembers(:, 4) - zoneMembers(:, 1)).^2 + (zoneMembers(:, 5) - zoneMembers(:, 2)).^2 + (zoneMembers(:, 6) - zoneMembers(:, 3)).^2).^0.5;
                    
                    if solverOptions.useCosAngleValue
                        XZVectors = [zoneMembers(:, 4), zoneMembers(:, 6)] - [zoneMembers(:, 1), zoneMembers(:, 3)];
                        XZVectors(XZVectors(:, 2) < 0, :) = - XZVectors(XZVectors(:, 2) < 0, :);
                        XZLength = (vecnorm(XZVectors'))';
                        XZangles = XZVectors(:, 1) ./ XZLength;
                        
                        YZVectors = [zoneMembers(:, 5), zoneMembers(:, 6)] - [zoneMembers(:, 2), zoneMembers(:, 3)];
                        YZVectors(YZVectors(:, 2) < 0, :) = - YZVectors(YZVectors(:, 2) < 0, :);
                        YZLength = (vecnorm(YZVectors'))';
                        YZangles = YZVectors(:, 1) ./ YZLength;
                    else
                        XZslope = (zoneMembers(:, 6) - zoneMembers(:, 3)) ./ (zoneMembers(:, 4) - zoneMembers(:, 1));
                        XZangles = atan(XZslope);
                        YZslope = (zoneMembers(:, 6) - zoneMembers(:, 3)) ./ (zoneMembers(:, 5) - zoneMembers(:, 2));
                        YZangles = atan(YZslope);

                        XZangles(XZangles<0) = XZangles(XZangles<0) + pi;
                        YZangles(YZangles<0) = YZangles(YZangles<0) + pi;
                        if i > xZoneNumber/2
                            XZangles(XZangles == 0) = XZangles(XZangles==0) + pi;
                        end
                        if j > yZoneNumber/2
                            YZangles(YZangles == 0) = YZangles(YZangles==0) + pi; 
                        end
                    end
                    
                    weights = zoneMembers(:, 7) .* length;
                    addedObjectNumber = addedObjectNumber + 1;
                    if ~isempty(knowAngleValue)
                        self.optObjects{addedObjectNumber, 1} = PPFacet([XZangles, YZangles], weights, nozzleMaxAngle, solverOptions.useCosAngleValue, knowAngleValue{i, j});
                    else
                        self.optObjects{addedObjectNumber, 1} = PPFacet([XZangles, YZangles], weights, nozzleMaxAngle, solverOptions.useCosAngleValue);
                    end
                    self.facetMap{i, j} = self.optObjects{addedObjectNumber, 1};
                end
            end
            
            %% add facet connection constraint
            for i = 2 : xZoneNumber
                for j = 1 : yZoneNumber
                    addedObjectNumber = addedObjectNumber + 1;
                    self.optObjects{addedObjectNumber, 1} = PPOptYAngleLink(self.facetMap{1, j}, self.facetMap{i, j});
                end
            end
            
            for j = 2 : yZoneNumber
                for i = 1 : xZoneNumber
                    addedObjectNumber = addedObjectNumber + 1;
                    self.optObjects{addedObjectNumber, 1} = PPOptXAngleLink(self.facetMap{i, 1}, self.facetMap{i, j});
                end
            end
            
            %% add turn angle constraint
            if solverOptions.useAngleTurnConstraint
                for i = 1:xZoneNumber - 1
                    addedObjectNumber = addedObjectNumber + 1;
                    self.optObjects{addedObjectNumber, 1} = PPOptXAngleLink(self.facetMap{i + 1, 1}, self.facetMap{i, 1}, maxTurnAngle, 1);
                end

                for j = 1:yZoneNumber - 1
                    addedObjectNumber = addedObjectNumber + 1;
                    self.optObjects{addedObjectNumber, 1} = PPOptYAngleLink(self.facetMap{1, j + 1}, self.facetMap{1, j}, maxTurnAngle, 1);
                end
            end
        end
        
        function angles = outputPrintingAngles(self, splitedStructures, solverOptions)
            splitedStructuresMap = cell(size(self.facetMap, 1), size(self.facetMap, 2));
            for i = 1:size(self.facetMap, 1)
                splitedStructuresMap(i, :) =  splitedStructures{i, 1}';  
            end
            
            angles = cell(size(self.facetMap, 1), size(self.facetMap, 2));
            
            for i = 1 : size(self.facetMap, 1)
                for j = 1 : size(self.facetMap, 2)
                    if solverOptions.useCosAngleValue
                        angles{i, j} = [acos(self.facetMap{i, j}.xAngleVariable.value), acos(self.facetMap{i, j}.yAngleVariable.value)];
                    else
                        angles{i, j} = [self.facetMap{i, j}.xAngleVariable.value, self.facetMap{i, j}.yAngleVariable.value];
                    end
                end
            end
            
            for i = 1: size(angles, 1)
                currentSlice = cell2mat(splitedStructuresMap(i, :)');
                if isempty(currentSlice)
                    for j = 1:size(angles, 2)
                        angles{i, j}(1) = pi/2;
                    end
                end
            end
    
            for j = 1:size(angles, 2)
                currentSlice = cell2mat(splitedStructuresMap(:, j));
                if isempty(currentSlice)
                    for i = 1:size(angles, 1)
                        angles{i, j}(2) = pi/2;
                    end
                end
            end
        end     
    end
end

