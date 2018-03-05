function obj = plotPhaseSpace(obj)
% Plots the phase-space representation of the rays

    angles = toProjectedAngles(obj);
    
    %% plot the projection onto the x-z plane first
    position = obj.origin(:,1);
    theta_x = angles(:,1);
    
    vcNewGraphWin;
    subplot(1,2,1);
    plot(position, theta_x, 'o', 'MarkerSize', 2);  
    xlabel('x');
    ylabel('\theta_x');
    
    %% plot the projection onto the x-z plane
    position = obj.origin(:,2);
    theta_y = angles(:,2);
    
    %vcNewGraphWin;
    subplot(1,2,2);
    plot(position, theta_y, 'o', 'MarkerSize', 2);  
    xlabel('y');
    ylabel('\theta_y');    
    
end
