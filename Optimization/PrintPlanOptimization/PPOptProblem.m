classdef PPOptProblem < OptProblem    
    properties
    end
    
    methods
        function obj = PPOptProblem()
        end
        
        function createProblem(self, splitedMembers, splitedZones)
            zoneNumber = size(splitedMembers, 1);
            self.optObjects = cell(zoneNumber, 1);
            for i = 1:zoneNumber
                zoneMembers = splitedMembers{i, 1};
                length = ((zoneMembers(:, 4) - zoneMembers(:, 2)).^2 + (zoneMembers(:, 3) - zoneMembers(:, 1)).^2).^0.5;
                slope = (zoneMembers(:, 4) - zoneMembers(:, 2)) ./ (zoneMembers(:, 3) - zoneMembers(:, 1));
                angles = atan(slope);
                angles(angles<0) = angles(angles<0) + pi;
                if i>zoneNumber/2
                    angles(angles==0) = angles(angles==0) + pi;
                end
                weights = zoneMembers(:, 5) .* length;
                self.optObjects{i, 1} = PPSlope(angles, weights);
            end
        end
        
        function angles = outputPrintingAngles(self)
            angles = zeros(size(self.optObjects, 1), 1);
            for i = 1:size(self.optObjects, 1)
                angles(i, 1) = self.optObjects{i, 1}.angleVariable.value;
            end
        end
        
    end
end

