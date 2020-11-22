function writeStructureToRhinoScript(self, structure, path)
    memberNum = size(structure, 1);
    [Cn, Nd] = self.generateCnAndNdList(structure);
    [radius, nodeRadiusList] = self.getRadiusList(structure);
    fileName = [path, '\createStructure.py'];
    fid = fopen( fileName, 'wt' );
    fprintf(fid, 'import Rhino \n');
    fprintf(fid, 'import scriptcontext \n');
    fprintf(fid, 'import System.Guid \n');
    fprintf(fid, 'def AddCylinder(pt1, pt2, r): \n');
    fprintf(fid, '    center_point = Rhino.Geometry.Point3d(pt1[0], pt1[1], pt1[2]) \n');
    fprintf(fid, '    height_point = Rhino.Geometry.Point3d(pt2[0], pt2[1], pt2[2]) \n');
    fprintf(fid, '    zaxis = height_point-center_point \n');
    fprintf(fid, '    plane = Rhino.Geometry.Plane(center_point, zaxis)\n');
    fprintf(fid, '    circle = Rhino.Geometry.Circle(plane, r)\n');
    fprintf(fid, '    cylinder = Rhino.Geometry.Cylinder(circle, zaxis.Length)\n');
    fprintf(fid, '    brep = cylinder.ToBrep(True, True)\n');
    fprintf(fid, '    if brep:\n');
    fprintf(fid, '        if scriptcontext.doc.Objects.AddBrep(brep)!=System.Guid.Empty:\n');
    fprintf(fid, '            scriptcontext.doc.Views.Redraw()\n');
    fprintf(fid, '            return Rhino.Commands.Result.Success\n');
    fprintf(fid, '    return Rhino.Commands.Result.Failure\n');
    fprintf(fid, '\n');
    fprintf(fid, 'if __name__=="__main__":\n');
    fprintf(fid, '    AddCylinder([0, 0, 0], [0, 0, 10], 5)\n');
    fprintf(fid, '\n');
%     writematrix([Nd, nodeRadiusList], nodesFileName, 'Delimiter', ',');
% 
%     for i = 1 : memberNum
%         currentMember = structure(i, :);
%         %shrinkLength1 = sqrt(nodeRadiusList(Cn(i, 1))^2 - radius(i, 1)^2);
%         %currentMember = self.shrinkFirstEnd(currentMember, shrinkLength1);
%         %shrinkLength2 = sqrt(nodeRadiusList(Cn(i, 2))^2 - radius(i, 1)^2);
%         %currentMember = self.shrinkSecondEnd(currentMember, shrinkLength2);
%         currentMember(:, 7) = currentMember(:, 7) * 1.01;
%         currentCylinder = self.generateTriangulatedCylinder(currentMember, 1, 6);
%         pointsFileName = [path, '\cp', int2str(i)];
%         connectionsFileName = [path, '\cc', int2str(i)];
%         writematrix(round(currentCylinder.Points, 3), pointsFileName, 'Delimiter', ',');
%         writematrix(currentCylinder.ConnectivityList - 1, connectionsFileName, 'Delimiter', ',');
%     end
%     
% %     nodeNum = size(Nd, 1);
% %     for i = 1 : nodeNum
% %         currentSphere = self.generateTriangulatedSphere(Nd(i, :), nodeRadiusList(i));
% %         pointsFileName = [path, '\sp', int2str(i)];
% %         connectionsFileName = [path, '\sc', int2str(i)];
% %         writematrix(currentSphere.Points, pointsFileName, 'Delimiter', ',');
% %         writematrix(currentSphere.ConnectivityList-1, connectionsFileName, 'Delimiter', ',');
% %     end  
% end