classdef GeoMember
    %UNTITLED3 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        nodeA
        nodeB
        length
    end
    
    methods
        function obj = GeoMember(aNode,bNode)
            if (nargin > 0)
                obj.nodeA = aNode;
            end
            if (nargin > 1)
                obj.nodeB = bNode;
                obj.length = aNode.calcDistance(bNode);
            end
        end
    end
end

