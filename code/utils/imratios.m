%%%% imratios %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get SNR (Signal to Noise Ratio), CNR (Contrast to Noise Ratio) and 
% ENL (Equivalent Number of Looks Ratio). The ENL is calculated over the 
% first (3 or as indicated in the parameters) ROIS of ROISCNR struct.
%
% SNR is in dBs
% CNR and ENL are calculated over logarithm images
%
% Input:
%
%   (1) Iini: initial image
%   (2) ROINOISE: ROI of the noise to measure later the quality metrics
%   (3) ROISCNR: ROIs of interest to measure the quality metrics (SNR,CNR,ENL) image
%   (4) nHROI(optional): Number of homonegenous regions for the ENL. Default value is 3.      
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in June 2021.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [SNR CNR ENL]=imratios(Iini,ROINOISE,ROISCNR,varargin)

nrg = nargin; 
nHROI=3;
if nrg == 5 
    nHROI = varargin{1};
end

% SNR is calculated over linear images and CNR and ENL over logarithmic
% images. By default the images are in linear scale
I = im2double(Iini);
Ilog=I;
if nrg == 5
    % If the image is in logarithmic scale take the exponential for the SNR
    % ratio
    if strcmp(varargin{2} ,'log')    
        I = exp(im2double(Iini))-1;
        Ilog = I;      
    end
end

% ROI Noise 
NOISE = imcrop(I,ROINOISE);

%%%%% SNR
SNR = 10*log10(mean(I(:))^2/var(NOISE(:)));

%%%%%% CNR over all ROIs
CNR=0;
CNR_SP=0;
nROI=size(ROISCNR,1);
NOISEL = imcrop(Ilog,ROINOISE);

for k=1:nROI    
    C=imcrop(Ilog,ROISCNR{k});            
    CNR = CNR + ((mean2(C)-mean2(NOISEL))/sqrt(std2(C)^2+std2(NOISEL)^2));      
end
CNR=CNR/nROI;

for k=nHROI+1:nROI    
    C=imcrop(Ilog,ROISCNR{k});            
    CNR_SP = CNR_SP + ((mean2(C)-mean2(NOISEL))/sqrt(std2(C)^2+std2(NOISEL)^2));    
end
CNR_SP=CNR_SP/(nROI-nHROI);

%%%%%%% ENL over the nHROI first
ENL=0;
for m=1:nHROI
    E=imcrop(I,ROISCNR{m});    
    ENL = ENL + (mean2(E)^2/std2(E)^2);
        
end
ENL=ENL/nHROI;

end
