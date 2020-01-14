function [radius, nodeRadiusList] = getRadiusList(self, structure)
    [Cn, Nd] = self.generateCnAndNdList(structure);
    radius = sqrt(structure(:, 7) / pi);
    nodeRadiusList = zeros(size(Nd, 1), 1);
    
    for i = 1 : size(structure, 1)
        if nodeRadiusList(Cn(i, 1)) < radius(i)
            nodeRadiusList(Cn(i, 1)) = radius(i);
        end
        if nodeRadiusList(Cn(i, 2)) < radius(i)
            nodeRadiusList(Cn(i, 2)) = radius(i);
        end
    end
end

