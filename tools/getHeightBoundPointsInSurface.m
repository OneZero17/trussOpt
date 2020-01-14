function [lowerBound, upperBound] = getHeightBoundPointsInSurface(box, zGrid, splintLineX, splintLineY)
   point1 = box([1 3 5]);
   point2 = box([2 4 6]);
%    if member(3) <= member(6)
%        point1 = member(1:3);
%        point2 = member(4:6);
%    else
%        point1 = member(4:6);
%        point2 = member(1:3);      
%    end


   for i = 1:size(splintLineX, 2)-1
       if splintLineX(i+1)>= point1(1) && splintLineX(i)<= point1(1)
           point1xLocation = i;
       end
       if splintLineX(i+1)>= point2(1) && splintLineX(i)<= point2(1)
           point2xLocation = i;
       end
   end
   
   for i = 1:size(splintLineY, 2)-1
       if splintLineY(i+1)>= point1(2) && splintLineY(i)<= point1(2)
           point1yLocation = i;
       end
       if splintLineY(i+1)>= point2(2) && splintLineY(i)<= point2(2)
           point2yLocation = i;
       end       
   end
   
   lowerBound = min([zGrid{point1xLocation, point1yLocation}(3), zGrid{point1xLocation+1, point1yLocation}(3), zGrid{point1xLocation, point1yLocation+1}(3), zGrid{point1xLocation+1, point1yLocation+1}(3)]);
   upperBound = max([zGrid{point2xLocation, point2yLocation}(3), zGrid{point2xLocation+1, point2yLocation}(3), zGrid{point2xLocation, point2yLocation+1}(3), zGrid{point2xLocation+1, point2yLocation+1}(3)]);
   
end

