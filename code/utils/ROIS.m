%% ROIS for a single image
%
% This funtcion is used to calculate the ROIS of a single Image.
%
% How to use:
%
%   [ROINOISE ROISCNRC]=ROIS2(I)
%       Input (I): the image, (nROI): number of CNR  regios, (plotSNR):
%       indicate if the SNR area should be drawn in the image
%    
%       Output [ROINOISE ROISCNR]: ROI of noise ROINOISE and ROIS of signal to calculare ROISCNR
%
% Juan Jose Gómez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in July 2020.
%
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ROINOISE ROISCNR]=ROIS4(I,varargin)

nROI=6; 
nrg = nargin;
if nrg >= 2 
    nROI = varargin{1};
end

nHROI=3; 
if nrg >= 3
    nHROI = varargin{2};
end


plotSNR = 'y';
if nrg >= 4 
    plotSNR = varargin{3};
end

figure;
imshow(I,[]);

%% NOISE ROI
[~,Y,IROINOISE,RECTNOISE] = imcrop(I,[]);

xon=round(RECTNOISE(1));
yon=round(RECTNOISE(2));
largon=round(RECTNOISE(3));
anchon=round(RECTNOISE(4));

ROINOISE=[xon yon largon anchon];

p1n=[xon yon];
p2n=[(xon+largon) yon];
p3n=[(xon+largon) (yon+anchon)];
p4n=[xon (yon+anchon)];

%% CNR ROIs
for i=1:nROI
 
    [X,Y,ROISCNRI,RECTCNR] = imcrop(I,[]);

     xoc=round(RECTCNR(1,1));
     yoc=round(RECTCNR(1,2));
     largoc=round(RECTCNR(1,3));
     anchoc=round(RECTCNR(1,4));

     ROISCNR{i,1}=[xoc yoc largoc anchoc];

end

%% Plot the ROIs
hold on;

plot([p1n(1) p2n(1)],[p1n(2) p2n(2)],'w')
plot([p2n(1) p3n(1)],[p2n(2) p3n(2)],'w')
plot([p3n(1) p4n(1)],[p3n(2) p4n(2)],'w')
plot([p4n(1) p1n(1)],[p4n(2) p1n(2)],'w')

for i=1:nROI % Here the ROIS are drawn together in the same figure

     RECTCNRplot=ROISCNR{i,1};

     xoc=RECTCNRplot(1,1);
     yoc=RECTCNRplot(1,2);
     largoc=RECTCNRplot(1,3);
     anchoc=RECTCNRplot(1,4);

     p1=[xoc yoc];
     p2=[(xoc+largoc) yoc];
     p3=[(xoc+largoc) (yoc+anchoc)];
     p4=[xoc (yoc+anchoc)];

     hold on;
      if (i<=nHROI)
        color = 'r';
     else 
        color = 'g';
     end
     plot([p1(1) p2(1)],[p1(2) p2(2)],color)
     plot([p2(1) p3(1)],[p2(2) p3(2)],color)
     plot([p3(1) p4(1)],[p3(2) p4(2)],color)
     plot([p4(1) p1(1)],[p4(2) p1(2)],color) 
     
end   
