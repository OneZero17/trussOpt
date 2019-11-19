function [forceList, obj] = fullGroundStructure(groundStructure, loadcases, supports, solverOptions)
    trussProblem3D = OptProblem3D();
    trussProblem3D.createProblem(groundStructure, loadcases, supports, solverOptions);
    [conNum, varNum, objVarNum] = trussProblem3D.getConAndVarNum();
    matrix = ProgMatrix(conNum, varNum, objVarNum);
    trussProblem3D.initializeProblem(matrix);
    [variables, obj, dualValues] = mosekSolve(matrix, 0);
    fprintf("Optimized volume is %.2f\n", obj);
    matrix.feedBackResult(variables, dualValues);
    forceList = trussProblem3D.outputForceList(1);
end

