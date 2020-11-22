function [newMemberList, toBeDeletedMemberList] = deleteMembersViolatePrintingPlan(memberList, splitedZones, zoneAngles, nozzleMaxAngle)
    slope = (memberList(:, 6) - memberList(:, 4)) ./ (memberList(:, 5) - memberList(:, 3));
    angles = atan(slope);
    angles(angles<0) = angles(angles<0) + pi;
    memberList = [(1:size(memberList, 1))', memberList, angles];
    zoneNum = size(zoneAngles, 1);
    
    if size(memberList, 1) == 0
        newMemberList = [];
        toBeDeletedMemberList = [];
        return
    end
    toBeDeletedMemberList(size(memberList, 1), 1) = 0;
    addedDeletedMember = 1;
    for i = 1:zoneNum
        zoneAngle = zoneAngles(i);
        zoneStart = splitedZones(i);
        zoneEnd = splitedZones(i + 1);
        contactMembersPart1 = memberList((memberList(:, 4) >= zoneStart & memberList(:, 4) <= zoneEnd) & (memberList(:, 6) >= zoneStart & memberList(:, 6) <= zoneEnd), :);   
        
        contactMembersPart2 = memberList((memberList(:, 4) >= zoneStart & memberList(:, 4) < zoneEnd) & memberList(:, 6) > zoneEnd, :);  
        
        contactMembersPart3 = memberList((memberList(:, 4) > zoneStart & memberList(:, 4) <= zoneEnd) & memberList(:, 6) < zoneStart, :); 
        
        contactMembersPart4 = memberList((memberList(:, 6) >= zoneStart & memberList(:, 6) < zoneEnd) & memberList(:, 4) > zoneEnd, :);  
        
        contactMembersPart5 = memberList((memberList(:, 6) > zoneStart & memberList(:, 6) <= zoneEnd) & memberList(:, 4) < zoneStart, :); 
        
        contactMembersPart6 = memberList((memberList(:, 4) < zoneStart & memberList(:, 6) > zoneEnd) | (memberList(:, 6) < zoneStart & memberList(:, 4) > zoneEnd), :);
        
        contactMembers = [contactMembersPart1; contactMembersPart2; contactMembersPart3; contactMembersPart4; contactMembersPart5; contactMembersPart6];
        toBeDeletedMembers = contactMembers(abs(contactMembers(:, end) - zoneAngle) > nozzleMaxAngle, :);
        toBeDeletedMemberList(addedDeletedMember:addedDeletedMember+size(toBeDeletedMembers, 1) - 1, :) = toBeDeletedMembers(:, end - 1);
        addedDeletedMember = addedDeletedMember + size(toBeDeletedMembers, 1);
        memberList = setdiff(memberList, toBeDeletedMembers, 'rows');
    end
    toBeDeletedMemberList = toBeDeletedMemberList(toBeDeletedMemberList ~= 0);
    newMemberList = memberList(:, 2:7);
end

