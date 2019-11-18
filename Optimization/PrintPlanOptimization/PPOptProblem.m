classdef PPOptProblem < OptProblem    
    properties
    end
    
    methods
        function obj = PPOptProblem()
        end
        
        function createProblem(self, splitedMembers, nozzleMaxAngle, maxTurnAngle)
            zoneNumber = size(splitedMembers, 1);
            self.optObjects = cell(zoneNumber*2 - 1, 1);
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
                self.optObjects{i, 1} = PPSlope(angles, weights, nozzleMaxAngle);
            end
            
            for i = 1:zoneNumber - 1
                linkedSegmenetA = self.optObjects{i, 1};
                linkedSegmenetB = self.optObjects{i + 1, 1};
                self.optObjects{zoneNumber + i, 1} = PPOptAngleLink(linkedSegmenetB, linkedSegmenetA, maxTurnAngle);
            end
        end
        
        function angles = outputPrintingAngles(self)
            optAngles = self.optObjects(cellfun('isclass', self.optObjects, 'PPSlope'));
            angles = zeros(size(optAngles, 1), 1);
            for i = 1:size(optAngles, 1)
                angles(i, 1) = optAngles{i, 1}.angleVariable.value;
            end
        end
        
    end
end

