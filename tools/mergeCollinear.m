function outputStructure = mergeCollinear(structure)
    structureTools = OptStructureTools;
    [Cn, Nd] = structureTools.generateCnAndNdList(structure);
    Cn = [Cn, (1:size(Cn))'];
    NodeConnectionList = cell(size(Nd, 1), 1);
    
    duplicated = true;
    while duplicated
        duplicated = false;
        for i = 1 : size(Nd, 1)
            connectedMembers = Cn(Cn(:, 1) == i | Cn(:, 2) == i, :);
            NodeConnectionList{i, 1} = connectedMembers;
        end

        for i = 1:size(NodeConnectionList, 1)
            currentMembers = NodeConnectionList{i, 1};
            if ~isempty(currentMembers)
            currentMemberVectors = Nd(currentMembers(:, 2), :) - Nd(currentMembers(:, 1), :);
            currentMemberVectors = currentMemberVectors ./vecnorm(currentMemberVectors')';
            zNegatives = currentMemberVectors(:, 3) < 0;
            currentMemberVectors(zNegatives, :) = - currentMemberVectors(zNegatives, :);
            memberIndices = (1:size(currentMembers, 1))';

            [uniqueVectors, map1, map2] = unique(currentMemberVectors, 'rows' );
            [count, ~, idxcount] = histcounts(map2,numel(map1));
            idxkeep = count(idxcount) > 1;
            duplicatedMembers = memberIndices(idxkeep);
                if ~isempty(duplicatedMembers)
                    uniqueDuplicatedVectors = unique(currentMemberVectors(duplicatedMembers, :), 'rows');
                    toBeDeletedCells = cell(size(uniqueDuplicatedVectors, 1), 1);
                    newMemberCells = cell(size(uniqueDuplicatedVectors, 1), 1);
                    for j = 1:size(uniqueDuplicatedVectors, 1)
                        toBeDeletedMemberIndices = memberIndices(currentMemberVectors(:, 1) == uniqueDuplicatedVectors(j, 1)& currentMemberVectors(:, 2) == uniqueDuplicatedVectors(j, 2)& currentMemberVectors(:, 3) == uniqueDuplicatedVectors(j, 3));
                        if abs(currentMembers(toBeDeletedMemberIndices(1, 1), 3) -  currentMembers(toBeDeletedMemberIndices(2, 1), 3)) < 1e-5
                            duplicated = true;
                            toBeDeletedMembers = currentMembers(toBeDeletedMemberIndices, end);
                            newMemberIndices = reshape(currentMembers(toBeDeletedMemberIndices, 1:2), [], 1);
                            indiceCount = sum(newMemberIndices == newMemberIndices');
                            newIndices = newMemberIndices(indiceCount==1);
                            newMember = [newIndices', currentMembers(toBeDeletedMemberIndices(1, 1), 3),0];
                            Cn(toBeDeletedMembers, :)=[];
                            Cn = [Cn; newMember];
                            Cn(:, end) = (1:size(Cn, 1))';
                            break;
                        end
                    end
                    if duplicated
                        break;
                    end
                end
            end
        end
    end
    
    outputStructure = [Nd(Cn(:, 1), :), Nd(Cn(:, 2), :), Cn(:, 3)];
end

