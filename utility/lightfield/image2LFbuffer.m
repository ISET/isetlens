% This function take the 3 channel, 2D light field sensor image and
% "shuffles" the data into a light field buffer: LF(t,s,v,u,3)

% img should have dimensions (yRes,xRes,3)
% (s,t) is the index of the microlens (t,s in MATLAB coord)
% (u,v) is the index of the subaperture (v,u in MATLAB coord)

% U,V are the size of the microlens, i.e. the number of pixels underneath
% (typically 9x9)
% S,T are the number of microlens 

function LFbuffer = image2LFbuffer(img,S,T)

[yRes,xRes,C] = size(img);
V = yRes/T; 
U = xRes/S;

LFbuffer = zeros(T,S,V,U,C);

for kv = 1:V
    for ku = 1:U
        LFbuffer(:,:,kv,ku,:) = ...
            img(kv:V:end, ku:U:end,:);
    end
end

end