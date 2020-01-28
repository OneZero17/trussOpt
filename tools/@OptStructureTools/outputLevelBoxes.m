function outputLevelBoxes(self, structure, zSplitLine, startingPoint, EndPoint, path)
radius = sqrt(abs(structure(:, 7) / pi));

designDomainStartPoint = [-30 -30 -1]
designDomainEndPoint = [80 180 80]
[F, V] = generateCuboid(designDomainStartPoint, designDomainEndPoint);
fileName = [path, sprintf('designDomainBox.stl')];
stlwrite(fileName, F, V);

for memberNum = 1:size(structure, 1)
    currentMember = structure(memberNum, :);
    
    if currentMember(6) >= currentMember(3)
        point1 = currentMember(1:3);
        point2 = currentMember(4:6);
    else
        point1 = currentMember(4:6);
        point2 = currentMember(1:3);
    end
    
    for i = 1:size(zSplitLine, 2) - 1
        currentStartZ = zSplitLine(i);
        currentEndZ = zSplitLine(i+1);
        
        if ~(currentStartZ < point2(3) && currentEndZ > point1(3))
            continue;
        else
            box1StartPoint = [startingPoint(1) startingPoint(2) currentStartZ];
            box1EndPoint = [EndPoint(1) EndPoint(2) currentEndZ];
            
            if abs(currentStartZ - point1(3)) <= 1e-3
                box1StartPoint(3) = box1StartPoint(3) - radius(memberNum, 1) * 1.5;
            end
            
            if abs(currentEndZ - point2(3)) <= 1e-3
                box1EndPoint(3) = box1EndPoint(3) + radius(memberNum, 1) * 1.5;
            end
                 
            if abs(box1EndPoint(3)-box1StartPoint(3)) >1e-3
                [F, V] = generateCuboid(box1StartPoint, box1EndPoint);
                fileName = [path, sprintf('cylinder%dlevel%dbox.stl', memberNum, i)];
                stlwrite(fileName, F, V);
            end
        end
        
%         box2StartPoint = [startingPoint(1) startingPoint(2) currentEndZ];
%         box2EndPoint = [EndPoint(1) EndPoint(2) EndPoint(3) + 5];
%         if abs(box2EndPoint(3) - box2StartPoint(3)) >1e-3
%             [F, V] = generateCuboid(box2StartPoint, box2EndPoint);
%             fileName = [path, sprintf('level%dbox2.stl', i)];
%             stlwrite(fileName, F, V);
%         end
    end
end



    
end

