function out = showswcnodes(dataPaths,showFig)

% Created by Ryosuke Tanaka 05/06/2020

% Note: In the coordinate system of SWC in neuprint, positive X/Y/Z each
% corresponds to left, anterior, ventral (Right hand coordinate)
% This function shows the nodes in the native coordinate system

if nargin<2
    showFig = 1;
end

if ~iscell(dataPaths)
    dataPaths = {dataPaths};
end

if showFig
    figure; hold on
end
nCells = length(dataPaths);

% define color scheme
degs = (1:nCells)'/nCells*360;
cols = (1+sind([degs,degs+120,degs+240]))/2;


out = cell(nCells,1);
for ii = 1:nCells
    dataPath = dataPaths{ii};
    M = readswc(dataPath);
    out{ii} = M;
    if showFig
        scatter3(M(:,3),M(:,4),M(:,5),M(:,6),'filled','MarkerFaceColor',cols(ii,:),'MarkerEdgeColor',cols(ii,:));
        drawnow;
    end
end
if showFig
    axis equal
    xlabel('x (\mum)');
    ylabel('y (\mum)');
    zlabel('z (\mum)');
end
end
