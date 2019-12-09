classdef OptOptions < handle

    
    properties
        sigmaT = 1;
        sigmaC = 1
        cellOptimization = 0;
        useVonMises = true;
        nodalSpacing = 0;
        memberAddingBeta = 0.1;
        sectionModulus = [0 0 0];
        jointLength = 0;
        allowExistingBeamVolume = 0;
        outputMosek = false;
        
        %% print plan options
        useCosAngleValue = false;
        useAngleTurnConstraint = true;
    end
    
    methods
        function obj = OptOptions()
        end
    end
end

