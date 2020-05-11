function dMap = CDMIPtoDepthMap(tifpath)

% 5/11/20 by RT
% Decode CDMIP images into max intensity depth map
% For Z alignment between skeleton and images
% Returns depth in index for the psychedericrainbow LUT (not necessarily
% original 1um slices?)

% Default parameters
maskThreshold = 10;
torelance = 3; % if LUT and 2nd color match is larger than this value, it is considered unreliable

load('psychedericrainbow.mat');
pr = psychedericrainbow; % it's long!


M = double(imread(tifpath));

% erase color bars and genotype names
M(1:80,951:end,:) = 0; % colorbar on top right corner
M(1:90,1:260,:)   = 0; % genotype names on top left corner

maxIntensity = max(M,[],3);
maskMat = maxIntensity > maskThreshold;
cDepth = M./repmat(maxIntensity,[1,1,3]).*repmat(maskMat,[1,1,3])*255;
dMap = nan(size(M(:,:,1)));

%% Do reverse color lookup
% Primary color
BmaxMask = cDepth(:,:,3)==255; % anterior
GmaxMask = cDepth(:,:,2)==255; % middle
RmaxMask = cDepth(:,:,1)==255; % posterior
% Secondary mask
BRMask = cDepth(:,:,1)>cDepth(:,:,2) & BmaxMask;
BGMask = cDepth(:,:,2)>cDepth(:,:,1) & BmaxMask;
GBMask = cDepth(:,:,3)>cDepth(:,:,1) & GmaxMask;
GRMask = cDepth(:,:,1)>cDepth(:,:,3) & GmaxMask;
RGMask = cDepth(:,:,2)>cDepth(:,:,3) & RmaxMask;
RBMask = cDepth(:,:,3)>cDepth(:,:,2) & RmaxMask;

% Go through sections one by one
% Section 1 (B->R)
s1Ind = find(pr(:,3)==255 & pr(:,1)>pr(:,2));
s1Rval = pr(s1Ind,1);
cDepthR = cDepth(:,:,1);
s1RVec = cDepthR(BRMask(:));
[X,Y] = meshgrid(s1RVec,s1Rval); % we need to do this because LUT is nonlinear
[minError,matchInd] = min(abs(X-Y));
unreliablePixel = minError>torelance;
dMap(BRMask(:)) = s1Ind(matchInd);
dMap(BRMask(unreliablePixel)) = nan;

% Section 2 (B->G)
s2Ind = find(pr(:,3)==255 & pr(:,2)>pr(:,1));
s2Gval = pr(s2Ind,2);
cDepthG = cDepth(:,:,2);
s2GVec = cDepthG(BGMask(:));
[X,Y] = meshgrid(s2GVec,s2Gval); % we need to do this because LUT is nonlinear
[minError,matchInd] = min(abs(X-Y));
unreliablePixel = minError>torelance;
dMap(BGMask(:)) = s2Ind(matchInd);
dMap(BGMask(unreliablePixel)) = nan;

% Section 3 (G->B)
s3Ind = find(pr(:,2)==255 & pr(:,3)>pr(:,1));
s3Bval = pr(s3Ind,3);
cDepthB = cDepth(:,:,3);
s3BVec = cDepthB(GBMask(:));
[X,Y] = meshgrid(s3BVec,s3Bval); % we need to do this because LUT is nonlinear
[minError,matchInd] = min(abs(X-Y));
unreliablePixel = minError>torelance;
dMap(GBMask(:)) = s3Ind(matchInd);
dMap(GBMask(unreliablePixel)) = nan;

% Section 4 (G->R)
s4Ind = find(pr(:,2)==255 & pr(:,1)>pr(:,3));
s4Rval = pr(s4Ind,1);
s4RVec = cDepthR(GRMask(:));
[X,Y] = meshgrid(s4RVec,s4Rval); % we need to do this because LUT is nonlinear
[minError,matchInd] = min(abs(X-Y));
unreliablePixel = minError>torelance;
dMap(GRMask(:)) = s4Ind(matchInd);
dMap(GRMask(unreliablePixel)) = nan;

% Section 5 (R->G)
s5Ind = find(pr(:,1)==255 & pr(:,2)>pr(:,3));
s5Gval = pr(s5Ind,2);
s5GVec = cDepthG(RGMask(:));
[X,Y] = meshgrid(s5GVec,s5Gval); % we need to do this because LUT is nonlinear
[minError,matchInd] = min(abs(X-Y));
unreliablePixel = minError>torelance;
dMap(RGMask(:)) = s5Ind(matchInd);
dMap(RGMask(unreliablePixel)) = nan;


% Section 6 (R->B)
s6Ind = find(pr(:,1)==255 & pr(:,3)>pr(:,2));
s6Bval = pr(s6Ind,3);
s6BVec = cDepthG(RBMask(:));
[X,Y] = meshgrid(s6BVec,s6Bval); % we need to do this because LUT is nonlinear
[minError,matchInd] = min(abs(X-Y));
unreliablePixel = minError>torelance;
dMap(RBMask(:)) = s6Ind(matchInd);
dMap(RBMask(unreliablePixel)) = nan;


end
