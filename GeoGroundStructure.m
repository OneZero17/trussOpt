classdef GeoGroundStructure
    
    properties
        nodes
        members
    end
    
    methods
        function obj = GeoGroundStructure(nodesVector,membersVector)
            if (nargin > 0)
                obj.nodes = nodesVector;
            end
            if (nargin > 1)
                obj.members = membersVector;
            end
        end
    end
end

