%%%% getmetrics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate enhancement ratios comparing two images over several Region of Interest (ROIs).
%
% Return a struct with all the ratios SNR,CNR,ENL, MSE and Beta.
%
% Get SNR, CNR and ENL
% SNR and CNR are in dBs
% CNR and ENL are calculated over logarithm images
%
% Example of use:
% > getmetrics('WCAN',I,EST_IMG,ROINOISE,ROISCNR)
%
%    Name: 'WCAN'
%     SNR: 15.4990
%     CNR: 13.6672
%     ENL: 323.0779
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in June 2021.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ metrics ] = getmetrics( Name, Orig_Image, Esti_Image, ROINOISE, ROISCNR, varargin )

%---Checking Input Arguments
if nargin<1||isempty(Esti_Image), error('Input Argument: Estiamted Image Missing');end

%---Implentation starts here
if (size(Orig_Image)~= size(Esti_Image)) %---Check images size
    error('Error: Input images should be of same size');
else
    metrics.Name = Name;
    
    % Set to 0 NaN values
    Orig_Image(isnan(Orig_Image))=0;
    Esti_Image(isnan(Esti_Image))=0;
    
    [SNROr CNROr ENLOr] = imratios(Orig_Image,ROINOISE,ROISCNR);
    [SNREs CNREs ENLEs] = imratios(Esti_Image,ROINOISE,ROISCNR);
   
    metrics.SNR = SNREs - SNROr;
    metrics.CNR = CNREs - CNROr;
    metrics.ENL = ENLEs - ENLOr;
       
end




