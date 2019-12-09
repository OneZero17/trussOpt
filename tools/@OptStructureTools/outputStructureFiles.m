function outputStructureFiles(self, structure, path)
    memberNum = size(structure, 1);
    for i = 1 : memberNum
        currentMember = structure(i, :);
        currentCylinder = self.generateTriangulatedCylinder(currentMember, 1, 20);
        pointsFileName = [path, '\cp', int2str(i)];
        connectionsFileName = [path, '\cc', int2str(i)];
        writematrix(currentCylinder.Points, pointsFileName, 'Delimiter', ',');
        writematrix(currentCylinder.ConnectivityList - 1, connectionsFileName, 'Delimiter', ',');
    end
    
    [Cn, Nd] = self.generateCnAndNdList(structure);
    radius = sqrt(structure(:, 7) / pi);
    nodeRadiusList = zeros(size(Nd, 1), 1);
    
    for i = 1 : memberNum
        if nodeRadiusList(Cn(i, 1)) < radius(i)
            nodeRadiusList(Cn(i, 1)) = radius(i);
        end
        if nodeRadiusList(Cn(i, 2)) < radius(i)
            nodeRadiusList(Cn(i, 2)) = radius(i);
        end
    end
    
    nodesFileName = [path, '\sp'];
    writematrix([Nd, nodeRadiusList], nodesFileName, 'Delimiter', ',');
%     nodeNum = size(Nd, 1);
%     for i = 1 : nodeNum
%         currentSphere = self.generateTriangulatedSphere(Nd(i, :), nodeRadiusList(i));
%         pointsFileName = [path, '\sp', int2str(i)];
%         connectionsFileName = [path, '\sc', int2str(i)];
%         writematrix(currentSphere.Points, pointsFileName, 'Delimiter', ',');
%         writematrix(currentSphere.ConnectivityList-1, connectionsFileName, 'Delimiter', ',');
%     end  
end

