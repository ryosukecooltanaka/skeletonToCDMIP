function myvecplot3(M)

% Created by Ryosuke Tanaka 05/06/2020

for ii = 1:size(M,1)
    plot3([0,M(ii,1)],[0,M(ii,2)],[0,M(ii,3)]); hold on
    scatter3(M(ii,1),M(ii,2),M(ii,3),'filled');
end
end