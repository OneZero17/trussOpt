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
    fprintf(fid, 'def AddSphere(pt, r):\n');
    fprintf(fid, '    center = Rhino.Geometry.Point3d(pt[0], pt[1], pt[2])\n');
    fprintf(fid, '    sphere = Rhino.Geometry.Sphere(center, r)\n');
    fprintf(fid, '    if scriptcontext.doc.Objects.AddSphere(sphere)!=System.Guid.Empty:\n');
    fprintf(fid, '        scriptcontext.doc.Views.Redraw()\n');
    fprintf(fid, '        return Rhino.Commands.Result.Success\n');
    fprintf(fid, '    return Rhino.Commands.Result.Failure\n');
    fprintf(fid, '\n');
    fprintf(fid, 'if __name__=="__main__":\n');
        
    for i = 1 : memberNum
        currentMember = structure(i, :);
        fprintf(fid, '    AddCylinder([%.2f, %.2f, %.2f], [%.2f, %.2f, %.2f], %.2f)\n', [currentMember(1:6), radius(i)]);
    end
     
    nodeNum = size(Nd, 1);
    for i = 1 : nodeNum
        fprintf(fid, '    AddSphere([%.2f, %.2f, %.2f], %.2f)\n', [Nd(i, :), nodeRadiusList(i)]);
    end  
    
    fprintf(fid, '\n');
    fclose(fid);
end