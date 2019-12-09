function outputConnectivity(self, structure, path)
    [Cn, Nd] = self.generateCnAndNdList(structure);
    nodeNum = size(Nd, 1);
    nodeConnectionList = cell(nodeNum, 1);
    memberIndex = (1:size(Cn, 1))';
    maximumMemberPerNode = 0;
    for i = 1:nodeNum
        nodeConnectionList{i, 1} = memberIndex(Cn(:, 1) == i | Cn(:, 2) == i)';
        if size(nodeConnectionList{i, 1}, 2) > maximumMemberPerNode
            maximumMemberPerNode = size(nodeConnectionList{i, 1}, 2);
        end
    end
    
    nodeMemberList = zeros(nodeNum, maximumMemberPerNode);
    
    for i = 1:nodeNum
        currentConnection = nodeConnectionList{i, 1};
        for j = 1:size(currentConnection, 2)
            nodeMemberList(i, j) = currentConnection(j);
        end
    end
    
    memberNodeFileName = [path, '\memberNode'];
    nodeMemberFileName = [path, '\nodeMember'];
    
    writematrix(Cn(:, [1 2]) - 1, memberNodeFileName, 'Delimiter', ',');
    writematrix(nodeMemberList - 1, nodeMemberFileName, 'Delimiter', ',');
end

