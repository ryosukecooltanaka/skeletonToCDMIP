function out = showswcnodesByCellType(cellName,showFig)

% Created by Ryosuke Tanaka 05/06/2020
% Show all the SWC files stored in /swc/<celltype> folder
% cells are color coded

if nargin<2
    showFig = 1;
end
    files = dir(['./swc/',cellName,'/*.txt']);
    nFiles = length(files);
    dataPaths = cell(nFiles,1);
    for ii = 1:nFiles
        dataPaths{ii} = [files(ii).folder,'/',files(ii).name];
    end
    out = showswcnodes(dataPaths,showFig);
end