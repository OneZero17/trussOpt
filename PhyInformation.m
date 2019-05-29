classdef PhyInformation
 
    properties
        loadCases
        supports
    end
    
    methods
        function obj = PhyInformation(inputLoadCases, inputSupports)
            if (nargin>0)
                obj.loadCases = inputLoadCases;
            end
            if(nargin > 1)
                obj.supports = inputSupports;
            end
        end
    end
end

