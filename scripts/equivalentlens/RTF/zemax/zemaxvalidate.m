close all
filmdistance_mm=2.167 % mm
lens=lensC('file','zemax_dgauss.22deg.3.0mm_aperture0.6.json')
lens=lensC('file','dgauss.22deg.50.0mm_aperture6.0.json')

addPlane=outputPlane(filmdistance_mm);

newlens = addPlane(lens);


objdistance=-11.0131-0.9094
origin=[0 0.9689 objdistance];thetas=-5
origin=[0 2.9674305456 objdistance];thetas=-15
origin=[0 4.030825325 objdistance];thetas=-20


phi=0

direction=[sind(thetas').*sind(phi) sind(thetas')*cosd(phi) cosd(thetas')]

[arrival_pos,arrival_dir]=rayTraceSingleRay(lens,origin,direction);
xlim([objdistance 4]);
axis equal



outputs = [arrival_pos arrival_dir]