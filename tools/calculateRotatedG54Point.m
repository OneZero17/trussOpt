function rotatedPoint = calculateRotatedG54Point(point, angleB, angleC)
   rotationBAxis = [0; 0; 193.24]; 
   
   rotatedPointAroundAxisC = rotate_3D(point, 'any', angleC, [0; 0; 1]);
   relativePointPosition =  rotatedPointAroundAxisC - rotationBAxis;
   relativeRotatedPointAroundAxisBC =  rotate_3D(relativePointPosition, 'any', angleB, [0; 1; 0]);
   rotatedPoint = relativeRotatedPointAroundAxisBC + rotationBAxis;
end

