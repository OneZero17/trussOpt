classdef OptObject
    
    properties
        index
    end
    
    methods
        function obj = OptObject()
        end
        
        function matrix = addConstraint(matrix)
        end
        
        function matrix = initialize(matrix)
        end
        
        function matrix = calcConstraint(matrix)
        end
        
        function matrix = calcObjective(matrix)
        end
    end
end

