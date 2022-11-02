% Wavelet Compounding Adaptive Noise Method
%
% A denoising method based on wavelet decompositions, that works on
% multiple frame data from consecutive positions but with
% varying noise. 
%
% Parameters:
%   img:     Matrix of noisy frames (each slice of the 3D matrix corresponds to a frame)
%   ref:    reference of noise variance
%   Additional parameters:
%       'maxLevel'  - Maximum decomposition level, default: 4
%       'k'     - Parameter k default: 1 (used in weightmode 1, 2, 3, 4)
%       'basis' - Wavelet basis, default: 'haar'
% 
% A calling example:
% imgResult = wcan(imgFrames, refNoise, 'k', 1.1,'maxLevel', 5, 'basis', 'haar');
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in June 2021.
%
%--------------------------------------------------------------------------
function imgRes = wcan(img, ref, varargin)

% Set Standard Values for optional parameters
paramK = 1;
basis = 'haar';
maxLevel = 4;

if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end

% Read Optional Parameters
for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'k'))
        paramK = varargin{k+1};
    elseif (strcmp(varargin{k}, 'basis'))
        basis = varargin{k+1};
    elseif (strcmp(varargin{k}, 'maxLevel'))
        maxLevel = varargin{k+1};
    end
end
img = im2double(img);

%--------------------------------------------------------------------------
% Perform Wavelet Decomposition

numFrames = size(img, 3);

for i = numFrames:-1:1
    [wt(i).approx, wt(i).horizontal, wt(i).vertical, wt(i).diagonal] = swt2(img(:,:,i),maxLevel, basis);
    for l = maxLevel:-1:1
        Coeff(l).approx(:,:,i)  = wt(i).approx(:,:,l);
        Coeff(l).horizontal(:,:,i) = wt(i).horizontal(:,:,l);
        Coeff(l).vertical(:,:,i) = wt(i).vertical(:,:,l);
        Coeff(l).diagonal(:,:,i) = wt(i).diagonal(:,:,l);
    end
end

% Free Memory that is not needed anymore
clear wt;

%--------------------------------------------------------------------------
% Compute new coefficients
CoeffVar = getNoiseSubBands(img,'maxLevel',maxLevel,'basis',basis);
weightsNoiseAdaptive = getNoiseAdaptiveWeight(Coeff, CoeffVar, ref, paramK);
  
%--------------------------------------------------------------------------
% New Wavelet Coeffs 
for l = maxLevel:-1:1    
    Coeff(l).horizontal = Coeff(l).horizontal.*weightsNoiseAdaptive(l).horizontal;
    Coeff(l).vertical = Coeff(l).vertical.*weightsNoiseAdaptive(l).vertical;
    Coeff(l).diagonal = Coeff(l).diagonal.*weightsNoiseAdaptive(l).diagonal;
end

%--------------------------------------------------------------------------
% Averaging
% Calculate approximation coefficients
% 
for l = maxLevel:-1:1
    meanApprox{l} = mean(Coeff(l).approx, 3);
    Coeff(l).approx = [];
end

for l = maxLevel:-1:1
    meanCoeffHorizontal{l} = mean(Coeff(l).horizontal, 3);
    meanCoeffVertical{l} = mean(Coeff(l).vertical, 3);
    meanCoeffDiagonal{l} = mean(Coeff(l).diagonal, 3);
end

for l = maxLevel:-1:1
    meanApproxTemp(:,:,l) = meanApprox{l};
    meanCoeffHorizontalTemp(:,:,l) = meanCoeffHorizontal{l};
    meanCoeffVerticalTemp(:,:,l) = meanCoeffVertical{l};
    meanCoeffDiagonalTemp(:,:,l) = meanCoeffDiagonal{l};
end

imgRes = iswt2(meanApproxTemp, meanCoeffHorizontalTemp, meanCoeffVerticalTemp, meanCoeffDiagonalTemp, basis);

end
