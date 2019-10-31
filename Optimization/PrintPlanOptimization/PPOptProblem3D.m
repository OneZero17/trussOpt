classdef PPOptProblem3D < OptProblem
    properties
        facetMap
    end
    
    methods
        function obj = PPOptProblem3D()
        end
        
        function createProblem(self, splitedMembers, nozzleMaxAngle)
            xZoneNumber = size(splitedMembers, 1);
            yZoneNumber = size(splitedMembers{1, 1}, 1);
            self.optObjects = cell(3 * xZoneNumber * yZoneNumber - xZoneNumber - yZoneNumber, 1);
            self.facetMap = cell(xZoneNumber, yZoneNumber);
            addedObjectNumber = 0;
            for i = 1:xZoneNumber
                for j = 1:yZoneNumber
                    zoneMembers = splitedMembers{i, 1}{j, 1};
                    length = ((zoneMembers(:, 4) - zoneMembers(:, 1)).^2 + (zoneMembers(:, 5) - zoneMembers(:, 2)).^2 + (zoneMembers(:, 6) - zoneMembers(:, 3)).^2).^0.5;
                    XZslope = (zoneMembers(:, 6) - zoneMembers(:, 3)) ./ (zoneMembers(:, 4) - zoneMembers(:, 1));
                    XZangles = atan(XZslope);
                    YZslope = (zoneMembers(:, 6) - zoneMembers(:, 3)) ./ (zoneMembers(:, 5) - zoneMembers(:, 2));
                    YZangles = atan(YZslope);
                    
                    XZangles(XZangles<0) = XZangles(XZangles<0) + pi;
                    YZangles(YZangles<0) = YZangles(YZangles<0) + pi;
                    if i > xZoneNumber/2
                        XZangles(XZangles==0) = XZangles(XZangles==0) + pi;
                    end
                    
                    if j > yZoneNumber/2
                        YZangles(YZangles==0) = YZangles(YZangles==0) + pi; 
                    end
                    
                    weights = zoneMembers(:, 7) .* length;
                    addedObjectNumber = addedObjectNumber + 1;
                    self.optObjects{addedObjectNumber, 1} = PPFacet([XZangles, YZangles], weights, nozzleMaxAngle);
                    self.facetMap{i, j} = self.optObjects{addedObjectNumber, 1};
                end
            end
            
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
        end
        
        function angles = outputPrintingAngles(self)
            angles = cell(size(self.facetMap, 1), size(self.facetMap, 2));
            
            for i = 1 : size(self.facetMap, 1)
                for j = 1 : size(self.facetMap, 2)
                    angles{i, j} = [self.facetMap{i, j}.xAngleVariable.value, self.facetMap{i, j}.yAngleVariable.value];
                end
            end
        end
        
    end
end

