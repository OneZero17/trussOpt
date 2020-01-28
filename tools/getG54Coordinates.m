function G54coordinates = getG54Coordinates(point, direction)
    if direction(3)<0
        direction = -direction;
    end
    
    angleXZ = atan(direction(3) / sqrt(direction(1)^2 + direction(2)^2));
    angleYZ = atan(direction(2) / direction(1));
    B = -abs(pi/2 - angleXZ);
    
    if direction(1) <=0 && direction(2)>=0
        angleYZ = angleYZ + pi;
    elseif direction(1) <=0 && direction(2)<=0
        angleYZ = angleYZ - pi;
    end

%     if direction(1) >=0 && direction(2)>=0
%         angleYZ = angleYZ - pi;
%     end
%     
%     if direction(1) <=0 && direction(2)>=0
%         angleYZ = angleYZ - pi;
%     end
%     
%     if direction(1) >=0 && direction(2)<=0
%         angleYZ = angleYZ + pi;
%     end
%     
%     if direction(1) <=0 && direction(2)<=0
%         angleYZ = angleYZ + pi;
%     end
%     if angleXZ < 0
%         angleXZ = angleXZ + pi;
%     end
% 
%     if angleXZ < pi/2
%         B = pi/2 - angleXZ;
%     else
%         B = angleXZ - pi/2;
%     end
%     if direction(1) < 0
%         B = -B;
%     end
    
    C = -angleYZ;
    rotatedPoint = calculateRotatedG54Point(point', B, C);
    G54coordinates = [rotatedPoint; rad2deg(B); rad2deg(C)];
%     if isnan(G54coordinates(1))
%         xx =0.0;
%     end
end

