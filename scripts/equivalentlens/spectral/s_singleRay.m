clear;
%%
%%
lensName = 'lens/dgauss.22deg.3.0mm-spectral.json';
lensName = 'dgauss.22deg.3.0mm.json';
%lensName = fullfile('fisheye.87deg.3.0mm.json');
lensForward=lensC('filename',lensName)
lens=lensReverse(lensName)




%lens_addfinalsurface(lens,0.1)

filmplane_z=-10.167


 %£Refractive index modifications
%lens.surfaceArray(3).n(2)=1.8

planes.input= -7.9432
%% Check trace

%lensNormal.draw
lensR=lens;
theta=-24
direction=[0 sind(theta) cosd(theta)]
origin = [0 3 filmplane_z]

direction = direction/norm(direction)
direction =  [direction]
[arrival_pos,arrival_dir]=rayTraceSingleRay(lensR,origin,direction,'waveindex',[1])

arrival_dir_flip = arrival_dir;
arrival_dir_flip(2) = -arrival_dir_flip(2)


%%
% Draw pupils
pupilradii =abs([32.0733    20.2974    1.4911])
pupildistances =[ 46.44  -29.0227    1.1928];
colors = {'r','g','b'}
for i=1:numel(pupildistances)

pupilpos=(planes.input+pupildistances(i));

line([1 1]*pupilpos,pupilradii(i)*[1 2],'color',colors{i},'linewidth',2)
line([1 1]*pupilpos,-pupilradii(i)*[1 2],'color',colors{i},'linewidth',2)

end
ylim([-200 200])
alpha=linspace(-50,100,2);
xlim([-inf inf])
for t=1:numel(theta)
    points=origin(t,:)+alpha'.*direction
    line(points(:,3),points(:,2),'color','k','linestyle','-')
end  