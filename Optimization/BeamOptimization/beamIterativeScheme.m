function beamSolution = beamIterativeScheme(groundStructure, loadcases, supports, solverOptions, initialAlpha, prepreexistingBeamVolume, preExistingMembers)
    keepIterating = true;
    newAlpha = initialAlpha;
    solverOptions.sectionModulus = [0, 0, newAlpha];
    beamProblem = OptBeamProblem();
    beamProblem.createProblem(groundStructure, loadcases, supports, solverOptions, preExistingMembers);
    [conNum, varNum, objVarNum] = beamProblem.getConAndVarNum();
    oldSolution = 0;
    while keepIterating
        matrix = ProgMatrix(conNum, varNum, objVarNum);
        beamProblem.initializeProblem(matrix);
        if prepreexistingBeamVolume~=0
            beamProblem.addBeamVolumeConstraint(matrix, prepreexistingBeamVolume);
        end
        [result, newSolution] = mosekSolve(matrix, 0);
        matrix.feedBackResult(result);
        difference = abs((newSolution - oldSolution) / newSolution);
        if difference < 0.01
            keepIterating = false;
        else
            beamProblem.updateSectionModulus();
        end
        fprintf("new volume:%.4f, old volume:%.4f, difference:%.2f %%\n", newSolution, oldSolution, difference*100)
        oldSolution = newSolution;
    end
    
    beamSolution = beamProblem.outputResult(1);  
end

