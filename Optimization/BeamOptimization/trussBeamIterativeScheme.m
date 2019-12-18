function [trussSolution, beamSolution] = trussBeamIterativeScheme(groundStructure, loadcases, supports, solverOptions)
    trussProblem = OptProblem();
    trussProblem.createProblem(groundStructure, loadcases, supports, solverOptions);
    [conNum, varNum, objVarNum] = trussProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    trussProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 1);
    matrix.feedBackResult(result);
    trussProblem.feedBackResult(1);
    trussSolution = groundStructure.createOptimizedStructureList();

    estimatedAlpha = calculateBeamAlpha(max(trussSolution(:, end)), 'square');
    
    solverOptions.sectionModulus = [0, 0, estimatedAlpha];
    beamProblem = OptBeamProblem();
    beamProblem.createProblem(groundStructure, loadcases, supports, solverOptions);
    [conNum, varNum, objVarNum] = beamProblem.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    beamProblem.initializeProblem(matrix);
    result = mosekSolve(matrix, 1);
    matrix.feedBackResult(result);
    beamSolution = beamProblem.outputResult(1);
end

