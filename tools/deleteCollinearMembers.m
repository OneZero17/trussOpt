function newMemberList = deleteCollinearMembers(nodes, memberList)
    
    NodeConnectionList = cell(size(nodes, 1), 1);
    for i = 1 : size(nodes, 1)
        connectedMembers = memberList(memberList(:, 1) == i, :);
        NodeConnectionList{i, 1} = connectedMembers;
    end
    
    for i = 1 : size(nodes, 1)
        currentMembers = NodeConnectionList{i, 1};
        localMemberList = (1:size(currentMembers, 1))';
        if ~isempty(currentMembers)
            memberVectors = currentMembers(:, 6:8) - currentMembers(:, 3:5);
            normalizedMemberVectors = memberVectors;
            for j = 1:size(memberVectors, 1)
                normalizedMemberVectors(j, :) = normalizedMemberVectors(j, :) / norm(normalizedMemberVectors(j, :));
            end
            sortedVectors = sortrows(normalizedMemberVectors);
            uniqueVectors = unique(sortedVectors, 'rows');
            toBeDeleteMemberCells = cell(size(uniqueVectors, 1), 1);
            for j = 1:size(uniqueVectors, 1)
                sameVectorMembers = localMemberList(normalizedMemberVectors(:, 1)==uniqueVectors(j, 1) & normalizedMemberVectors(:, 2)==uniqueVectors(j, 2) & normalizedMemberVectors(:, 3)==uniqueVectors(j, 3));
                sameVectorMembersLengths = zeros(size(sameVectorMembers, 1), 1);
                for k = 1:size(sameVectorMembers, 1)
                    sameVectorMembersLengths(k, 1) = norm(memberVectors(sameVectorMembers(k, 1), :));
                end
                %sameVectorMembersLengths = vecnorm(memberVectors(sameVectorMembers, :)')';
                
                [~, miniIndex] = min(sameVectorMembersLengths);
                toBedeletedMembers = sameVectorMembers(setdiff((1:size(sameVectorMembers, 1))', miniIndex));
                if ~isempty(toBedeletedMembers)
                    toBeDeleteMemberCells{j, 1} = toBedeletedMembers;
                end
            end
            totalToBeDeletedMembets = cell2mat(toBeDeleteMemberCells);
            NodeConnectionList{i, 1}(totalToBeDeletedMembets, :)=[];
        end
    end
    newMemberList = cell2mat(NodeConnectionList);
end

