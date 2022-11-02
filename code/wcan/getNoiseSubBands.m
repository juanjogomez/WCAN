%--------------------------------------------------------------------------
% getNoiseSubBands
% Calculation of the noise variance for all subbands in img_ini
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in July 2020.
%
%--------------------------------------------------------------------------
function noiseSB = getNoiseSubBands(img_ini, varargin)

    img_ini = mat2gray(img_ini);
    basis='haar';
    maxLevel=4;
    numFrames = size(img_ini, 3);
               
    % 2^Level has to divide the size of the image.
    img = zeros(ceil(size(img_ini,1)/2^maxLevel)*2^maxLevel, ceil(size(img_ini,2)/2^maxLevel)*2^maxLevel, numFrames);
    img(1:size(img_ini,1),1:size(img_ini,2),:) = img_ini;
    
    % crop limits
    sz_img= size(img);
    per_sz = 0.15; % percentage out in each size        

    % Read Optional Parameters
    for k = 1:2:length(varargin)
        if (strcmp(varargin{k}, 'basis'))
            basis = varargin{k+1};
        elseif (strcmp(varargin{k}, 'maxLevel'))
            maxLevel = varargin{k+1};
        end
    end
    
    %--------------------------------------------------------------------------
    % Perform Wavelet Decomposition
    disp('Perform Wavelet Decomposition...');
    for i = numFrames:-1:1
        [wt(i).approx, wt(i).horizontal, wt(i).vertical, wt(i).diagonal] = swt2(img(:,:,i),maxLevel, basis);      
        for l = maxLevel:-1:1
            Coeff(l).approx(:,:,i)  = wt(i).approx(round(per_sz*sz_img(1)):round((1-per_sz)*sz_img(1)),round(per_sz*sz_img(2)):round((1-per_sz)*sz_img(2)),l);
            Coeff(l).horizontal(:,:,i) = wt(i).horizontal(round(per_sz*sz_img(1)):round((1-per_sz)*sz_img(1)),round(per_sz*sz_img(2)):round((1-per_sz)*sz_img(2)),l);
            Coeff(l).vertical(:,:,i) = wt(i).vertical(round(per_sz*sz_img(1)):round((1-per_sz)*sz_img(1)),round(per_sz*sz_img(2)):round((1-per_sz)*sz_img(2)),l);
            Coeff(l).diagonal(:,:,i) = wt(i).diagonal(round(per_sz*sz_img(1)):round((1-per_sz)*sz_img(1)),round(per_sz*sz_img(2)):round((1-per_sz)*sz_img(2)),l);
        end
    end        
    
    disp('Get Variance for each level...');
    for l = maxLevel:-1:1
        noiseSB(l).approxVar = var(Coeff(l).approx(:));
        noiseSB(l).approxMedian = median(Coeff(l).approx(:));
        noiseSB(l).verticalVar = var(Coeff(l).vertical(:));
        noiseSB(l).verticalMedian = median(Coeff(l).vertical(:));
        noiseSB(l).horizontalVar = var(Coeff(l).horizontal(:));
        noiseSB(l).horizontalMedian = median(Coeff(l).horizontal(:));
        noiseSB(l).diagonalVar = var(Coeff(l).diagonal(:));
        noiseSB(l).diagonalMedian = median(Coeff(l).diagonal(:));
    end   
        
end