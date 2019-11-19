function [forceList, potentialMemberList, volume] = memberAdding(groundStructure, loadcases, supports, solverOptions)
    potentialMemberList = groundStructure.members;
    addedMemberList = groundStructure.members(:, 9) <= solverOptions.nodalSpacing;
    groundStructure.members = groundStructure.members(addedMemberList, :);
    keepIteration = true;
    iterationNum = 0;
    while keepIteration
        trussProblem3D = OptProblem3D();
        trussProblem3D.createProblem(groundStructure, loadcases, supports, solverOptions);
        [conNum, varNum, objVarNum] = trussProblem3D.getConAndVarNum();
        matrix = ProgMatrix(conNum, varNum, objVarNum);
        trussProblem3D.initializeProblem(matrix);
        [variables, obj, dualValues] = mosekSolve(matrix, 0);
        volume = obj;
        matrix.feedBackResult(variables, dualValues);
        if iterationNum ==0
            fprintf("Itr    Member    MemberAdded    Result\n");
        end
        iterationNum = iterationNum + 1;
        %% Create virtual displacement list
        optPointObjects = trussProblem3D.optObjects(cellfun('isclass', trussProblem3D.optObjects, 'OptNodeMaster'));    
        nodeNum = size(optPointObjects, 1);
        loadCaseNum = size(loadcases, 1);
        virtualDisplacementLists = cell(loadCaseNum, 1);

        for loadCaseNo = 1:loadCaseNum
            virtualDisplacementList = zeros(nodeNum, 3);
            for i = 1 : nodeNum
                constrintX = optPointObjects{i, 1}.slaves{loadCaseNo, 1}.equilibriumConstraintX;
                constrintY = optPointObjects{i, 1}.slaves{loadCaseNo, 1}.equilibriumConstraintY;
                constrintZ = optPointObjects{i, 1}.slaves{loadCaseNo, 1}.equilibriumConstraintZ;
                if constrintX ~= -1
                    virtualDisplacementList(i, 1) = constrintX.dualValue;
                else
                    virtualDisplacementList(i, 1) = 0;
                end
                if constrintY ~= -1
                    virtualDisplacementList(i, 2) = constrintY.dualValue;
                else
                    virtualDisplacementList(i, 2) = 0;
                end
                if constrintZ ~= -1
                    virtualDisplacementList(i, 3) = constrintZ.dualValue;
                else
                    virtualDisplacementList(i, 3) = 0;
                end
            end
            virtualDisplacementLists{loadCaseNo, 1} = virtualDisplacementList;
        end
        
        %% Calculate virtual strain for every member
        memberList = (1:size(potentialMemberList, 1))';  
        toBeCheckedMemberList = potentialMemberList(~addedMemberList, :);
        toBeCheckedMemberList = [memberList(~addedMemberList), toBeCheckedMemberList];
        strainList = zeros(size(toBeCheckedMemberList, 1), 1);
        for i = 1:loadCaseNum
            currentVirtualDisplacementList = virtualDisplacementLists{i, 1};
            tempCheckingList = toBeCheckedMemberList;
            tempCheckingList = [tempCheckingList, currentVirtualDisplacementList(tempCheckingList(:, 2), :), currentVirtualDisplacementList(tempCheckingList(:, 3), :)];

            strains = abs(((tempCheckingList(:, 7) - tempCheckingList(:, 4)).*(tempCheckingList(:, 14) - tempCheckingList(:, 11)) + ...
                              (tempCheckingList(:, 8) - tempCheckingList(:, 5)).*(tempCheckingList(:, 15) - tempCheckingList(:, 12)) + ...
                              (tempCheckingList(:, 9) - tempCheckingList(:, 6)).*(tempCheckingList(:, 16) - tempCheckingList(:, 13))) ./ (tempCheckingList(:, 10).^2));
            strainList = strainList + strains;            
        end
                      
        candidateList = [strainList(strainList>1.001), toBeCheckedMemberList(strainList>1.001)];
        if size(candidateList, 1) > 0
            candidateList = sortrows(candidateList, 'descend');
            candidateNumber = floor(size(candidateList, 1) * solverOptions.memberAddingBeta);
            candidateNumber = max(candidateNumber, 100);
            candidateNumber = min(candidateNumber, size(candidateList, 1));
            recruitedCandidates = candidateList(1:candidateNumber, 2);
            recruitedMember = potentialMemberList(recruitedCandidates, :);
            addedMemberList(recruitedCandidates) = 1;
            groundStructure.members = [groundStructure.members; recruitedMember];
            fprintf("%2d%12d%12d%12.2f\n", iterationNum, size(groundStructure.members, 1), size(recruitedMember, 1), obj);
        else
            keepIteration = false;
        end
    end
    forceList = trussProblem3D.outputForceList(1);
end


