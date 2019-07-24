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
    % All cones
    [FQ, gQ, cQ] = matrix.getCoefficientOfConicConstraints();
    [rcode, res] = mosekopt('symbcon echo(0)');
    cQ = [res.symbcon.MSK_CT_QUAD*ones(size(cQ, 1), 1), cQ];
    recQ = zeros(1, size(cQ, 1)*size(cQ, 2));
    for i = 1:size(cQ)
        recQ(i*2-1:i*2)=cQ(i,:);
    end
    prob.f = FQ;
    prob.g = gQ;
    prob.cones = recQ;
    %prob = optimizeMatrix(prob);
    % Select interior-point optimizer... (integer parameter)
    
    %param.MSK_IPAR_OPTIMIZER = 'MSK_OPTIMIZER_INTPNT';
    % ... without basis identification (integer parameter)
    %param.MSK_IPAR_INTPNT_BASIS = 'MSK_BI_NEVER';
    if (output == 0)
        [r, res]=mosekopt('minimize echo(0)',prob);   
    else
        [r, res]=mosekopt('minimize',prob); 
    end
    
    vars = res.sol.itr.xx;
    result = res.sol.itr.pobjval;
end


function prob = optimizeMatrix(prob)

    linkconstraint = -1*ones(size(prob.blc));
    linkNum = 0;
    for i = 1:size(prob.blc,1)
        if (prob.blc(i) == 0 && prob.buc(i)==0)
            if (size(find(prob.a(i,:)>0), 2) == 1) && (size(find(prob.a(i,:)==1), 2) == 1)
                linkNum = linkNum + 1;
                linkconstraint(linkNum) = i;
            end
        end
    end

    size(linkconstraint)
    toBeDeletedVariables = [];
    for i = 1:size(linkconstraint, 1)      
        toBeDeletedVariable = find(prob.a(linkconstraint(i),:)==1);
        toBeDeletedVariables = [toBeDeletedVariables, toBeDeletedVariable];
        replacingVariable = find(prob.a(linkconstraint(i),:)<0);
        for j = 1:size(replacingVariable)
            prob.a(:,replacingVariable(j)) = prob.a(:,replacingVariable(j)) + prob.a(:,toBeDeletedVariable) * -prob.a(i,replacingVariable(j));
            prob.c(replacingVariable(j)) = prob.c(replacingVariable(j)) + prob.c(toBeDeletedVariable) * -prob.a(i,replacingVariable(j));
        end
    end
    prob.a(:,toBeDeletedVariables)=[];
    prob.c(:,toBeDeletedVariables)=[];
    prob.blx(:,toBeDeletedVariables)=[];
    prob.bux(:,toBeDeletedVariables)=[];
    prob.blc(:,toBeDeletedVariables)=[];
    prob.buc(:,toBeDeletedVariables)=[];
        
end