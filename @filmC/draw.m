function draw(obj)
% Draw the film on the current figure
%
%

if isa(obj,'filmSphericalC')
    disp('Draw semi-circle')
else
    x = obj.position(3);
    y = obj.size(2);
    line([x x],[-0.5 0.5]*y,'Color','g','linestyle','--');
end

end
