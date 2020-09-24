clc; clear all;
%Note !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%Code is only right if PIN is arranged from smallest to largest
%This file purpose is to:
%       - Generate the transf.in file for Flow3d. This file contain
%          coordinates of nearby nodes to the substructure
%       - Generate the Flow3d_Interpolating_36_Nodes.tx for interpolation

%% Input data
xyz = xlsread('Pressure Nodes','Coordinates');
data = xlsread('Pressure Nodes','Midas Nodes');
r = data(:,8);  %Radius of each elevation in Flow3d
z = data(:,7);  %Elevation of each horizontal plane in Flow3d
ne = length(z); %Number of elevation
msize = data(:,9);  %Tolerance of space between real node and nearby node
pin =[]; %nodes near substructure

%% Take nodes near circle (on each elevation)
for i = 1:length(xyz)
    for j = 1:ne
        %Check the elevation of node
        if xyz(i,3)==z(j)
            %Check the tolerance: node must be outside of circle and
            %distance must be smaller than tolerance
            if ((sqrt(xyz(i,1)^2+xyz(i,2)^2)-r(j))<=msize) &  ((sqrt(xyz(i,1)^2+xyz(i,2)^2)-r(j))>=0)
                pin = [pin; xyz(i,:)];
                break;
            end
        end
    end
end
coor = xyz; clear xyz;

%% Plot check
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%Copy PIN into excel and arrange from smallest to largest
%If PIN is already arranged in the same trend, don't need to do that
% pin = xlsread('Pressure Nodes','pin');

%Find starting row index of each elevation
id = [];
id = 0;
for i =1:length(pin)-1
    if pin(i,3) ~= pin(i+1,3)
        id = [id; i];
    end
end
id = [id; length(pin)];

%Plot the nearby nodes and exact circle in each elevation
for i = 1:14
    xy = pin(id(i)+1:id(i+1),1:2);
    figure(i)
    scatter(xy(:,1),xy(:,2));
    viscircles([0 0],r(i));
end

%% Generate 36 nodes on each elevation in Flow3d
alpha = 0:pi/18:2*pi-pi/18;
xyz = [];
for i = 1:length(r)
    x = r(i)*cos(alpha);
    y = r(i)*sin(alpha);
    temp = [x' y' z(i)*ones(36,1)];
    xyz = [xyz; temp];
end

%Write out coordinates
fileID = fopen('Flow3d_Interpolating_36_Nodes.txt','w');
formatSpec = '%8.6f   %8.6f   %8.6f   \r\n';
fprintf(fileID,formatSpec,xyz');
fclose(fileID);

%Plot 3d: red dot is original value, blue one is interpolated
scatter3(xyz(:,1),xyz(:,2),xyz(:,3),'o','MarkerFaceColor','blue')
xlabel('X (m)','FontSize',14,'FontName','Arial Narrow');
ylabel('Y (m)','FontSize',14,'FontName','Arial Narrow');
zlabel('Z (m)','FontSize',14,'FontName','Arial Narrow');
hold on
scatter3(pin(:,1),pin(:,2),pin(:,3),'s','MarkerFaceColor','red')
legend('Interpolating Nodes','Flow3d Nodes',...
    'Location','northoutside','Orientation','horizontal');
set (gca, 'FontSize',14);

%% Generate transf.in for Flow3d from pin data
%Write pin data to transf.in format
fileName = 'transf.in';
fileID = fopen(fileName,'w');
%Default format of transf.in in Flow3d
default_string = 'Optional title line 1 \r\nOptional title line 2 \r\nOptional title line 3 \r\n-1 \r\n0  \r\n-70   -35   0 \r\n';
fprintf(fileID,default_string);
fprintf(fileID,'%10.7f      %10.7f      %10.7f  \r\n ',pin');
fclose(fileID);














