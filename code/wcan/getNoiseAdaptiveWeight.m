%--------------------------------------------------------------------------
% getNoiseAdaptiveWeight
% Computes the weight for the wavelet compunding denoising based on the 
% noise in all the subbands of a reference image
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in June 2021.
%
%--------------------------------------------------------------------------
function weight = getNoiseAdaptiveWeight(Coeff, CoeffVar, CoeffVarRef, paramK)

    numFrames = size(Coeff(1).horizontal, 3);

    if isreal(Coeff(1).horizontal)
        disp('Computing noise adaptive weight for real coefficients...');
    else
        disp('Computing noise adaptive weight for complex coefficients...');
        for l = 1:length(Coeff)
            Coeff(l).horizontal = abs(Coeff(l).horizontal);
            Coeff(l).vertical = abs(Coeff(l).vertical);
            Coeff(l).diagonal = abs(Coeff(l).diagonal);
        end
    end

    coeffVarAdaptive = getAdaptiveNoise(CoeffVar,CoeffVarRef);

    for l = 1:length(Coeff)   
        for m = 1:numFrames
            weight(l).horizontal(:,:,m) = getWeight(Coeff(l).horizontal(:,:,m),Coeff(l).horizontal(:,:,[1:(m-1) m+1:end]),coeffVarAdaptive(l).horizontalVar, paramK);
            weight(l).vertical(:,:,m) = getWeight(Coeff(l).vertical(:,:,m), Coeff(l).vertical(:,:,[1:(m-1) m+1:end]),coeffVarAdaptive(l).verticalVar, paramK);
            weight(l).diagonal(:,:,m) = getWeight(Coeff(l).diagonal(:,:,m), Coeff(l).diagonal(:,:,[1:(m-1) m+1:end]),coeffVarAdaptive(l).diagonalVar, paramK);
        end
    end

end

function coeffVarAdaptive = getAdaptiveNoise(CoeffVar,CoeffVarRef)
    for l = 1:length(CoeffVar)        
        coeffVarAdaptive(l).horizontalVar = CoeffVarRef(l).horizontalVar/sqrt(abs(CoeffVar(l).horizontalVar-CoeffVarRef(l).horizontalVar));
        coeffVarAdaptive(l).verticalVar = CoeffVarRef(l).verticalVar/sqrt(abs(CoeffVar(l).verticalVar-CoeffVarRef(l).verticalVar));
        coeffVarAdaptive(l).diagonalVar = CoeffVarRef(l).diagonalVar/sqrt(abs(CoeffVar(l).diagonalVar-CoeffVarRef(l).diagonalVar));
    end
end

%
% getWeight
%
function weigth = getWeight(img, imgOthers, CoeffVarRef, paramK)

   weigth = abs(img.*sqrt(var(img(:)/CoeffVarRef)));

    for m=1:size(imgOthers,3)    
        img_other = (imgOthers(:,:,m));
        varOther = var(img_other(:));
        weigth = weigth + sqrt(varOther/CoeffVarRef); 
    end
    weigth = 1-abs(weigth./(size(imgOthers,3)+1));

    varNoise = CoeffVarRef/sqrt(abs(var(img(:))-CoeffVarRef));
    weigth(abs(img)>paramK*varNoise)=1;

end