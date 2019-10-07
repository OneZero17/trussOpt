function results = lineXCircle(member, circleCenter, radius)   
    slope = (member(2, 2) - member(1, 2)) / (member(2, 1) - member(1, 1));
    intercept = member(1, 2) - member(1, 1) * slope;
    if slope == inf
        intercept = member(1, 1);
    end        
    
    [xout, yout] = linecirc(slope, intercept, circleCenter(1), circleCenter(2), radius);
    results = [xout', yout'];
    xmin = min(member(:, 1)); xmax = max(member(:, 1)); ymin = min(member(:, 2)); ymax = max(member(:, 2));
    results = results(results(:, 1)>=xmin & results(:, 1) <= xmax & results(:, 2)>=ymin & results(:, 2)<=ymax, :);
end

