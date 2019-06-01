classdef CellSimpleSquare < CellBasic
  
    properties
        size
    end
    
    methods
        function obj = CellSimpleSquare(nodes, members)
            obj.nodes = nodes;
            obj.members = members;
        end
       
    end
end

