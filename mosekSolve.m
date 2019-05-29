function res = mosekSolve(matrix, output)
    matrix = matrix.deleteEmptyCells();
    prob.c = matrix.getJacobianObjective();
    variableBoundary = matrix.getVariableBoundary();
    prob.blx = variableBoundary(:,1);
    prob.bux = variableBoundary(:,2);
    prob.a = matrix.getJacobianConstraint();
    constraintBoundary = matrix.getConstraintBoundary();
    prob.blc = constraintBoundary(:,1);
    prob.buc = constraintBoundary(:,2);

    if (output == 0)
        [r, res]=mosekopt('minimize echo(0)',prob);   
    else
       [r, res]=mosekopt('minimize',prob);    
end