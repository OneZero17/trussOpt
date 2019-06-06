function [vars, result] = mosekSolve(matrix, output)
    matrix.deleteEmptyCells();
    prob.c = matrix.getJacobianObjective();
    variableBoundary = matrix.getVariableBoundary();
    prob.blx = variableBoundary(:,1);
    prob.bux = variableBoundary(:,2);
    prob.a = matrix.getJacobianConstraint();
    constraintBoundary = matrix.getConstraintBoundary();
    prob.blc = constraintBoundary(:,1);
    prob.buc = constraintBoundary(:,2);

    % Select interior-point optimizer... (integer parameter)
    param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_INTPNT';
    % ... without basis identification (integer parameter)
    param.MSK_IPAR_INTPNT_BASIS = 'MSK_BI_NEVER';
    
    if (output == 0)
        [r, res]=mosekopt('minimize echo(0)',prob, param);   
    else
        [r, res]=mosekopt('minimize',prob, param); 
    end   
    vars = res.sol.itr.xx;
    result = res.sol.itr.pobjval;
end