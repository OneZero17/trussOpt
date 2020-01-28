function [nozzleVector, overhangAngle] = getRealNozzleAngleForPath(self, path, memberVector, surface, surfaceAngles, maximumOverhangAngle, maximumB)
    
    pathMiddlePoint = (path(1:3) + path(4:6))/2;
    xIndex = -1;
    yIndex = -1;
    for i = 1:size(surface, 1)-1
        if surface{i, 1}(1) - pathMiddlePoint(1) <= 1e-6 && surface{i+1, 1}(1) - pathMiddlePoint(1) >= -1e-6
            xIndex = i;
            break;
        end
    end
    
    for j = 1:size(surface, 2) - 1
        if surface{1, j}(2) - pathMiddlePoint(2) <= 1e-6 && surface{1, j+1}(2) >= pathMiddlePoint(2)>=-1e-6
          yIndex = j;
          break
        end
    end
    
    surfaceNormalAngles = surfaceAngles{xIndex, yIndex};
    length1 = 1 / tan(surfaceNormalAngles(1));
    length2 = 1 / tan(surfaceNormalAngles(2));
    surfaceNormal = [length1, length2, 1];
    surfaceNormal = surfaceNormal / norm(surfaceNormal);
    angle = atan2(norm(cross(surfaceNormal, memberVector)), dot(surfaceNormal, memberVector));
    
    if angle > pi/2
        angle = pi - angle;
    end
        
    if abs(angle) < maximumOverhangAngle
        nozzleVector = surfaceNormal;
    else
        crossProduct = cross(surfaceNormal, memberVector);
        toBeRotatedAngle = sign(angle) * (abs(angle) - maximumOverhangAngle);
        nozzleVector = rotate_3D(surfaceNormal', 'any', toBeRotatedAngle, crossProduct')';
    end
    
    overhangAngle = angleBetweenVectors(nozzleVector, memberVector);
    
    if overhangAngle > pi/2
        overhangAngle = pi - overhangAngle;
    end
    
    if overhangAngle > maximumOverhangAngle*1.05
        nozzleVector = rotate_3D(surfaceNormal', 'any', -toBeRotatedAngle, crossProduct')';
    end
    
    angleXZ = atan(nozzleVector(3) / sqrt(nozzleVector(1)^2 + nozzleVector(2)^2));
    B = rad2deg(-abs(pi/2 - angleXZ));
    
    if abs(B) > maximumB
        rotationAngle = pi*(abs(B) - maximumB)/180;
        rotationAxis = cross(nozzleVector, [0 0 1]);
        nozzleVector = rotate_3D(nozzleVector', 'any', rotationAngle, rotationAxis')';
    end   
    
    if abs(B) > 50
        BCheck = atan(memberVector(3) / sqrt(memberVector(1)^2 + memberVector(2)^2));
        BCheck = rad2deg(-abs(pi/2 - BCheck));
    end
    
    overhangAngle = angleBetweenVectors(nozzleVector, memberVector);
    
    if overhangAngle > pi/2
        overhangAngle = pi - overhangAngle;
    end
    
end

