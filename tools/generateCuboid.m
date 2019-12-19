function [F,V] = generatecuboid(startingPoint, endPoint)
    x = endPoint(1) - startingPoint(1);
    y = endPoint(2) - startingPoint(2);
    z = endPoint(3) - startingPoint(3);
    
    V = [startingPoint;
         startingPoint(1) + x, startingPoint(2), startingPoint(3)
         startingPoint(1) + x, startingPoint(2) + y, startingPoint(3)
         startingPoint(1), startingPoint(2) + y, startingPoint(3)
         startingPoint(1), startingPoint(2), startingPoint(3) + z
         startingPoint(1) + x, startingPoint(2), startingPoint(3) + z
         startingPoint(1) + x, startingPoint(2) + y, startingPoint(3)+z
         startingPoint(1), startingPoint(2) + y, startingPoint(3)+z];
    
    F =[1 4 2
        2 4 3
        5 1 2
        5 2 6
        3 6 2
        7 6 3
        1 5 4
        5 8 4
        8 5 6
        7 8 6
        4 8 7
        4 7 3];
    
end

