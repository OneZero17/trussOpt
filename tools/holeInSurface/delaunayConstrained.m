function [DT,xyz,ind] = delaunayConstrained(primary,secondary,varargin)
%
%
%     Copyright (C) 2015  Devin C Prescott
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
%     
%     Author:
%     Devin C Prescott
%     devin.c.prescott@gmail.com
    %% Combine Shapes     
    for i = 1:length(secondary)
        if i ~= 1
            shape = union(secondary{i},shape,'rows');
        else
            shape = union(secondary{1},primary(:,1:2),'rows');
        end
    end
    %% Find Incicies
    B = {};
    for i = 1:length(secondary)
        B{i} = getPointInds(shape,secondary{i});
    end
    C = [];
    for i = 1:length(B)
        C(length(C)+1:length(C)+length(B{i}),:)=B{i};
    end
    %% Delaunay Triangulation
    DT = delaunayTriangulation(shape(:,1:2),C);
    %% Plotting
    if nargin > 2 
        if any(strcmpi(varargin,{'plot','mesh'}))
            triplot(DT.ConnectivityList(isInterior(DT), :),DT.Points(:,1),DT.Points(:,2))
        end
        if any(strcmpi(varargin,{'plot','borders'}))
            % Plot Boarders
            for i = 1:length(B)
                plotBorder(shape,B{i});
            end
        end
    end
    
    %% Reindex Z and Recreate Z Data
    ind = [];
    xyz = [DT.Points(:,1),DT.Points(:,2)];
    if size(primary,2) == 3
        ind = arrayfun(@(x,y) find(x==DT.Points(:,1) & y==DT.Points(:,2)),...
        primary(:,1),primary(:,2),'UniformOutput',false);
        ind = cell2mat(ind);
        
        z = NaN(length(DT.Points),1);
        for i = 1:length(primary(:,3))
            z(ind(i))=primary(i,3);
        end
    end
    xyz = [xyz,z];
end

function A = getPointInds(primary,secondary)
    A = arrayfun(@(x,y) find(x==primary(:,1) & y==primary(:,2)),...
        secondary(:,1),secondary(:,2),...
        'UniformOutput',false);
    % A = sum(reshape(cell2mat(A)',[size(primary,1),length(secondary)]),2);
    A = cell2mat(A);
    A = [A(1:end-1),A(2:end);A(end),A(1)];
end

function plotBorder(primary,boarder)
    boarder = boarder';
    for i = 1:numel(boarder)-1
        hold on
        x1 = primary(boarder(i),1); x2 = primary(boarder(i+1),1);
        y1 = primary(boarder(i),2); y2 = primary(boarder(i+1),2);
        plot([x1,x2],[y1,y2],'LineWidth',2,'Color','red')
        hold off
    end
end