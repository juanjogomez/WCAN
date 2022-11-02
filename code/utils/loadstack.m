%--------------------------------------------------------------------------
% loadstack
% Read an image stack and output a 3D variable with all the frames 
%
% Juan Jose Gomez Valverde (juanjo.gomez@upm.es)
%
% This version was revised in June 2021.
%
%--------------------------------------------------------------------------
function [ output ] = loadstack( stack_filename, varargin )
    
    nrg = nargin;
    imtype = 'uint16';    
    numcount=1;
    init_depth = 1;
    end_depth = [];
    if (nrg>=2)
        imtype = varargin{1};
    end
    if (nrg>=3)
        numcount = varargin{2};
    end   
    if (nrg>=4)
        init_depth = varargin{3};
    end
    if (nrg>=5)
        end_depth = varargin{4};
    end
    
    % Load image stack     
    InfoImage=imfinfo(stack_filename);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);   
    if ( isempty(end_depth))
        end_depth = nImage;
    end
    InitalImage=zeros(nImage,mImage,NumberImages/numcount,numcount,imtype);
    count = 1;
    for i=1:NumberImages
        z=((i-count)/numcount)+1;
        InitalImage(:,:,z,count)=imread(stack_filename,'Index',i);
        if count==numcount
            count = 1;
        else
            count=count+1;
        end
    end
    
    output = InitalImage(init_depth:end_depth,:,:,:);

end

