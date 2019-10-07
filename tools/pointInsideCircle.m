function flag = pointInsideCircle(point, circleCenter, radius)    
    distance = ((circleCenter(1) - point(1))^2 + (circleCenter(2) - point(2))^2)^0.5;
    flag = distance <= radius ;
end
 