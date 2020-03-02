function maximumAreaList = getMaximumAreaList(self, structure)
    nodeMemberList = self.outputConnectivity(structure, []);
    [Cn, Nd] = self.generateCnAndNdList(structure);
    
    maximumArea = zeros(size(Nd, 1), 1);
    for i = 1:size(Nd, 1)
        for j = 1:size(nodeMemberList, 2)
            if nodeMemberList(i, j) == 0
                break;
            end
            
            if Cn(nodeMemberList(i, j), 3) > maximumArea(i, 1)
                maximumArea(i, 1) = Cn(nodeMemberList(i, j), 3);
            end
        end
    end
    
    maximumAreaList = zeros(size(Cn, 1), 2);
    
    for i = 1:size(maximumAreaList, 1)
        maximumAreaList(i, 1) = maximumArea(Cn(i, 1), 1);
        maximumAreaList(i, 2) = maximumArea(Cn(i, 2), 1);
    end
end

