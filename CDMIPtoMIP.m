function MIP = CDMIPtoMIP(tifpath)

% 5/11/20 by RT
% Decode CDMIP images into max intensity map
% For XY alignment between skeleton and images

M = double(imread(tifpath));

% erase color bars and genotype names
M(1:80,951:end,:) = 0; % colorbar on top right corner
M(1:90,1:260,:)   = 0; % genotype names on top left corner

MIP = max(M,[],3);


end
