function result = polyInPoly(mainPoly, checkPoly)
    result = true;
    
    for i = 1:size(checkPoly, 1)
        if ~inpolygon(checkPoly(i, 1), checkPoly(i, 2), mainPoly(:, 1), mainPoly(:, 2))
            result = false;
            break;
        end
    end
end

