% Unshuffle a tiled image of the different sub aperture views back into a
% LF buffer

function LFbuffer = SubApertureViews2LFbuffer(img,S,T)
    
[yRes,xRes,C] = size(img);
V = yRes/T;
U = xRes/S;

LFbuffer = zeros(T,S,V,U,C);

for ks = 1:S
    for kt = 1:T
        LFbuffer(kt,ks,:,:,:) = ...
            img(kt:T:end, ks:S:end,:);
    end
end

end