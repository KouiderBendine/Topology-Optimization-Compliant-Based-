% This code tests the aerodynamic performance of a NACA 0024
% Last Update : 12-02-2024
% Author: K. Bendine

% Inputs
airfoil_name = 'NACA0024';
alpha_i = -10;
alpha_f = 20;
alpha_step = 2;
Re = 1000000;
MAC = 0.15;
n_iter = 100;
Xloc = 0.45;
Yloc = 0;
Degreee = [-10, -5, 0, 5, 10, 15, 20]; % Airfoil Deflection Angle

% %% XFOIL input file writer
for Degree = Degreee
    input_file = fopen(sprintf('%dinput_file.in', Degree), 'w');
    fprintf(input_file, 'LOAD %s.dat\n', airfoil_name);
    fprintf(input_file, '%s\n', airfoil_name);
    fprintf(input_file, 'GDES\n');
    fprintf(input_file, 'flap\n');
    fprintf(input_file, '%.2f\n', Xloc);
    fprintf(input_file, '%.2f\n', Yloc);
    fprintf(input_file, '%d\n', Degree);
    fprintf(input_file, 'exec\n\n');
    fprintf(input_file, 'PPAR\n\n\n');
    fprintf(input_file, 'PSAV %dAirfoil.txt\n\n', Degree);
    fprintf(input_file, 'PANE\n');
    fprintf(input_file, 'OPER\n');
    fprintf(input_file, 'Visc %d\n', Re);
    fprintf(input_file, 'm %.2f\n', MAC);
    fprintf(input_file, 'PACC\n');
    fprintf(input_file, '%dpolar_file.txt\n\n', Degree);
    fprintf(input_file, 'ITER %d\n', n_iter);
    fprintf(input_file, 'ASeq %d %d %d\n', alpha_i, alpha_f, alpha_step);
    fprintf(input_file, '\n\n');
    fprintf(input_file, 'quit\n');
    fclose(input_file);

    FileIN = sprintf('xfoil.exe <%dinput_file.in', Degree);
    system(FileIN);
end

if exist('polar_file.txt', 'file')
    delete('polar_file.txt');
end

% Plot AOA vs CL
markers = {'o', 's', 'D', '*', 'x', '^', 'v', '<', '>', 'h', 'p'};
figure(1);
cmap = colormap('parula');

for i = 1:length(Degreee)
    Degree = Degreee(i);
    FileINn = sprintf('%dpolar_file.txt', Degree);

    % Load polar data
    try
        polar_data = dlmread(FileINn, '', 12, 0);
    catch ME
        fprintf("Error loading file '%s': %s\n", FileINn, ME.message);
        continue;
    end

    % Get a unique color for each iteration
    color = cmap(round(i / length(Degreee) * size(cmap, 1)), :);
    marker = markers{mod(i - 1, length(markers)) + 1};

    % Plot CL vs AOA
    plot(polar_data(1:14, 1), polar_data(1:14, 2), ...
        'LineStyle', '-', 'Marker', marker, 'Color', color, 'DisplayName', sprintf('%d\x00b0', Degree));
    hold on;
end

xlabel('Angle Of Attack');
ylabel('CL');
legend;
hold off;

% Plot AOA vs CD
figure(2);
hold on;
for i = 1:length(Degreee)
    Degree = Degreee(i);
    FileINn = sprintf('%dpolar_file.txt', Degree);

    % Load polar data
    try
        polar_data = dlmread(FileINn, '', 12, 0);
    catch ME
        fprintf("Error loading file '%s': %s\n", FileINn, ME.message);
        continue;
    end

    % Get a unique color for each iteration
    color = cmap(round(i / length(Degreee) * size(cmap, 1)), :);
    marker = markers{mod(i - 1, length(markers)) + 1};

    % Plot CD vs AOA
    plot(polar_data(1:14, 1), polar_data(1:14, 3), 'LineStyle', '-', ...
        'Marker', marker, 'Color', color, 'DisplayName', sprintf('%d\x00b0', Degree));
end

xlabel('Angle Of Attack');
ylabel('CD');
legend;
hold off;

% Plot AOA vs CL/CD
figure(3);
hold on;
for i = 1:length(Degreee)
    Degree = Degreee(i);
    FileINn = sprintf('%dpolar_file.txt', Degree);

    % Load polar data
    try
        polar_data = dlmread(FileINn, '', 12, 0);
    catch ME
        fprintf("Error loading file '%s': %s\n", FileINn, ME.message);
        continue;
    end

    % Get a unique color for each iteration
    color = cmap(round(i / length(Degreee) * size(cmap, 1)), :);
    marker = markers{mod(i - 1, length(markers)) + 1};

    % Plot CL/CD vs AOA
    plot(polar_data(1:14, 1), polar_data(1:14, 2) ./ polar_data(1:14, 3), ...
        'LineStyle', '-', 'Marker', marker, 'Color', color, 'DisplayName', sprintf('%d\x00b0', Degree));
end

xlabel('Angle Of Attack');
ylabel('CL/CD');
legend;
hold off;

% Plot Airfoil Geometry
figure(4);
hold on;
for i = 1:length(Degreee)
    Degree = Degreee(i);
    FileINn = sprintf('%dAirfoil.txt', Degree);

    % Load airfoil data
    try
        dataBuffer = dlmread(FileINn, '', 3, 0);
    catch ME
        fprintf("Error loading file '%s': %s\n", FileINn, ME.message);
        continue;
    end

    XB = dataBuffer(:, 1);
    YB = dataBuffer(:, 2);

    % Extract upper and lower airfoil data
    XB_U = XB(YB >= 0);
    XB_L = XB(YB < 0);
    YB_U = YB(YB >= 0);
    YB_L = YB(YB < 0);

    % Get a unique color for each iteration
    color = cmap(round(i / length(Degreee) * size(cmap, 1)), :);

    % Plot upper and lower surfaces
    plot(XB_U, YB_U, 'Color', color, 'DisplayName', sprintf('%d\x00b0', Degree));
    plot(XB_L, YB_L, 'Color', color);
end

ylim([-0.3, 0.3]);
xlabel('X-Coordinate');
ylabel('Y-Coordinate');
legend;
hold off;