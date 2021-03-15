
%%  Reverse lens test


clear;close all;
ieInit

%%
X=[1.768500	0.225600	1.670000	1.512000
5.089800	0.007200	1.000000	1.512000
1.156500	0.241500	1.670000	1.380000
2.446200	0.196500	1.699000	1.380000
0.765000	0.342300	1.000000	1.140000
0.000000	0.270000	0.000000	1.023000
-0.869700	0.070800	1.603000	1.020000
2.446200	0.363900	1.658000	1.200000
-1.223100	0.011400	1.000000	1.200000
26.223900	0.193200	1.717000	1.200000
-2.383800	0.000000	1.000000	1.200000];
X0=X;


% Reverse order
X=flip(X,1);
% Change curvature sign
X(:,1)=-X(:,1);

% Shift relative distances
X(:,2)=circshift(X(:,2),-1,1);

% shift refractive index relative to paerture

X(1:5,3)= circshift(X(1:5,3),-1);
%-------aperture remains unchanged
X(7:11,3)= circshift(X(7:11,3),-1);


[X0 X]
%% load and modify json

J = jsonread('./lenses/dgauss.22deg.3.0mm.json')

count=1;
for i=1:size(X,1)
    s=J.surfaces(i);
    s.radius=X(i,1);
    s.thickness=X(i,2);
    s.ior=X(i,3);
    s.semi_aperture=0.5*X(i,4);% anders worden de curven te lang getekend
    surfaces(count)=s;
    count=count+1;
end

Jnew=J;
Jnew.name=[J.name '-reverse' ]
Jnew.surfaces =surfaces;
jsonwrite('./lenses/dgauss.22deg.3.0mm-reverse.json',Jnew)




%% Read a lens file and create a lens
lensFileName= fullfile(ilensRootPath,'data','lens','dgauss.22deg.3.0mm.dat');
lens= lensC('fileName', lensFileName)
%lensFileName = fullfile('./lenses/dgauss.22deg.3.0mm-reverse.dat');
lensFileName = fullfile('./dgauss.22deg.3.0mm-reverse.json')
revlens= lensC('fileName', lensFileName)


%%
lens.draw; title('lens')
ax=gca;
revlens.draw; title(' rev')
ax2=gca;
ax2.XLim=ax.XLim;
ax2.Position=ax.Position;