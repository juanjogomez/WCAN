%
% Example using WCAN method with previously created ROIS and noiseRef
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in June 2021.
%
%-------------------------------------------------------------------------

clear all;
close all;

% add all the subfolders to the path
addpath(genpath(pwd));

% step 1 
% load the ROIS 
% load the noiseRef
% load the volume

rois = load('./conf/volume_rois_1_1.mat');
noise = load('./conf/noiseRef_volumes_1X.mat');
volume_raw = loadstack('./testdata/volume_1_1.tif','uint16');

% step 2
% apply the method
paramK=1;
addmean='no';
numlevels = 4;
sizelimit = 2.^numlevels;
sizeVol = size(volume_raw);
size_1 = floor(sizeVol(1)/sizelimit)*sizelimit;
size_2 = floor(sizeVol(2)/sizelimit)*sizelimit;
imageVol = volume_raw(1:size_1,1:size_2,:);
        
% Add the mean as the last frame
if strcmp(addmean,'yes')
    imageVol(:,:,size(imageVol,3)+1) = mean(imageVol,3);
end

result_wcan = wcan(imageVol,noise.noiseRef,'k', paramK, 'maxLevel', numlevels, 'basis','haar');


% step 3
% get the metrics and plot the results
metrics = getmetrics( 'WCAN', imageVol(1:size(result_wcan,1),1:size(result_wcan,2),1), result_wcan, rois.ROINOISE, rois.ROISCNR );
disp(strcat('Improvement metrics- SNR: ',sprintf('%.2f',metrics.SNR),'dB, CNR: ',sprintf('%.2f',metrics.CNR),', ENL:',sprintf('%.2f',metrics.ENL)));

% save the result
imwrite(result_wcan,'../results/result_test_wcan.png')
