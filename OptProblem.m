classdef OptProblem
  
    properties
        optObjects
    end
    
    methods
        function obj = OptProblem(inputArg1,inputArg2)
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function obj = createProblem(self)
        end
    end
end

