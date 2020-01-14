function outputStructureFiles(self, structure, path)
    memberNum = size(structure, 1);
    [Cn, Nd] = self.generateCnAndNdList(structure);
    [radius, nodeRadiusList] = self.getRadiusList(structure);
    nodesFileName = [path, '\sp'];
    writematrix([Nd, nodeRadiusList], nodesFileName, 'Delimiter', ',');

    for i = 1 : memberNum
        currentMember = structure(i, :);
        shrinkLength1 = sqrt(nodeRadiusList(Cn(i, 1))^2 - radius(i, 1)^2);
        currentMember = self.shrinkFirstEnd(currentMember, shrinkLength1);
        shrinkLength2 = sqrt(nodeRadiusList(Cn(i, 2))^2 - radius(i, 1)^2);
        currentMember = self.shrinkSecondEnd(currentMember, shrinkLength2);
        currentMember(:, 7) = currentMember(:, 7) * 1.01;
        currentCylinder = self.generateTriangulatedCylinder(currentMember, 1, 30);
        pointsFileName = [path, '\cp', int2str(i)];
        connectionsFileName = [path, '\cc', int2str(i)];
        writematrix(round(currentCylinder.Points, 3), pointsFileName, 'Delimiter', ',');
        writematrix(currentCylinder.ConnectivityList - 1, connectionsFileName, 'Delimiter', ',');
    end
    
%     nodeNum = size(Nd, 1);
%     for i = 1 : nodeNum
%         currentSphere = self.generateTriangulatedSphere(Nd(i, :), nodeRadiusList(i));
%         pointsFileName = [path, '\sp', int2str(i)];
%         connectionsFileName = [path, '\sc', int2str(i)];
%         writematrix(currentSphere.Points, pointsFileName, 'Delimiter', ',');
%         writematrix(currentSphere.ConnectivityList-1, connectionsFileName, 'Delimiter', ',');
%     end  
end

