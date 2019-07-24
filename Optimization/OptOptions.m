classdef OptOptions < handle

    
    properties
        sigmaT = 1;
        sigmaC = 1
        cellOptimization = 0;
        useVonMises = true;
    end
    
    methods
        function obj = OptOptions()
        end
    end
end

