function pointStressList = calculatePointStress(stressList,supportDomainMap)
    pointNum = size(supportDomainMap, 1);
    pointStressList = zeros(pointNum, 3);
    for i = 1 : pointNum
        currentSupportingNodes = supportDomainMap{i, 1};
        currentSupportingDomain = supportDomainMap{i, 2};
        stress = stressList(currentSupportingNodes, :);
        pointStressList(i, :) = stress' * currentSupportingDomain';
    end
end

