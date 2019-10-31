classdef OptOptions < handle

    
    properties
        sigmaT = 1;
        sigmaC = 1
        cellOptimization = 0;
        useVonMises = true;
        nodalSpacing = 0;
        memberAddingBeta = 0.1;
    end
    
    methods
        function obj = OptOptions()
        end
    end
end

