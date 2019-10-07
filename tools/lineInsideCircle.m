function flag = lineInsideCircle(line , circleCenter, radius)
    flag = pointInsideCircle(line(1:2), circleCenter, radius) && pointInsideCircle(line(3:4), circleCenter, radius);
end

