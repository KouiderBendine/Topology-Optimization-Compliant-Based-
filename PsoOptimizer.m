% This file is used to  optimized the output force for a target airfoil profile
% The code uses PSO algorithm as an optimization schema and L1 norm as an
% objective function
% The profile changing with respect to the load is calculated visa Ansys
% APDL
% Code Last update : 06-11-2024

close all
clear all
clc
%%
% Objective function to minimize (returns a vector of 14 outputs)
function score = objective_function(x)
scale=0.4;
fid=fopen('parametreOptimization.inp','w+');
   fprintf(fid,'F1=%f\n'   ,-x(1));
   fprintf(fid,'F2=%f\n'   ,-x(2));
   fprintf(fid,'F3=%f\n'   ,-x(3));
   fprintf(fid,'Loc1=%f\n' ,x( 4));
   fprintf(fid,'Loc2=%f\n' ,x( 5));
   fprintf(fid,'Loc3=%f\n' ,x( 6));
   fprintf(fid,'Teta1=%f\n',x(7));
   fprintf(fid,'Teta2=%f\n',x(8));
   fprintf(fid,'Teta3=%f\n',x(9));
%fprintf(fid,'iter=%f\n',iter);
fclose(fid);

!SET KMP_STACKSIZE=15000k & "C:\Program Files\ANSYS Inc\v241\ansys\bin\winx64\ANSYS241.exe" -b -p ANSYS -i D:\MorphingWings\AnsysMorphing_Wing\Optimization_morphingForce\Morphing_WithSquar.txt -o D:\MorphingWings\AnsysMorphing_Wing\Optimization_morphingForce\ansysout.txt
dataAnsysDeflection = dlmread('AnsysDeformed.txt');
dataMatlabDeflection= dlmread('deformed_profile.txt');

UpperAnsys=scale*dataAnsysDeflection(:,3);
LowerAnsys=scale*dataAnsysDeflection(:,4);

UpperMatlab=dataMatlabDeflection(1:7,2);
LowerMatlab=dataMatlabDeflection(1:7,3);

L1_norm_Upper = sum(abs(UpperMatlab - UpperAnsys));

%L1_norm_Lower = sum(abs(LowerMatlab - LowerAnsys));
%outputs = example_function(x); % Replace 'example_function' with your actual function
    score = L1_norm_Upper;%+L1_norm_Lower; % Sum the 14 outputs equally weighted
end

% PSO parameters
n_particles = 30;  % Number of particles
n_variables = 9;   % Number of variables
n_iterations = 50; % Number of iterations
w = 0.5;            % Inertia weight
c1 = 1.5;           % Cognitive coefficient
c2 = 1.5;           % Social coefficient

% Define variable-specific bounds
bounds = [5, 20;   % First variable bounds
          5, 20;   % Second variable bounds
          5, 20;   % Second variable bounds
          1, 27;    % Fourth variable bounds (integer)
          1, 27;    % Fifth variable bounds (integer)
          62, 86;    % Fifth variable bounds (integer)
          0, 90;    % Third variable bounds
          0, 90
          0, 90];   % Sixth variable bounds

% Initialize particles with specific bounds for each variable
positions = zeros(n_particles, n_variables);
for i = 1:n_variables
    positions(:, i) = bounds(i, 1) + (bounds(i, 2) - bounds(i, 1)) * rand(n_particles, 1);
end

% Initialize velocities
velocities = -1 + 2 * rand(n_particles, n_variables);

% Personal best positions and scores
personal_best_positions = positions;
personal_best_scores = arrayfun(@(i) objective_function(positions(i, :)), 1:n_particles);

% Initialize global best
[global_best_score, idx] = min(personal_best_scores);
global_best_position = personal_best_positions(idx, :);

% Initialize arrays for convergence and variable tracking
convergence = zeros(n_iterations, 1);            % Store best score per iteration
variable_changes = zeros(n_iterations, n_variables); % Store best position of each variable per iteration


% PSO optimization loop
for iter = 1:n_iterations
    for i = 1:n_particles
        %iter

        % Update velocity
        inertia = w * velocities(i, :);
        cognitive = c1 * rand() * (personal_best_positions(i, :) - positions(i, :));
        social = c2 * rand() * (global_best_position - positions(i, :));
        velocities(i, :) = inertia + cognitive + social;
        
        % Update position
        positions(i, :) = positions(i, :) + velocities(i, :);
        
        % Clip each variable's position to its bounds and ensure integers for variables 4 and 5
        for j = 1:n_variables
            positions(i, j) = min(max(positions(i, j), bounds(j, 1)), bounds(j, 2));
            if j == 4 || j == 5 || j == 6
                positions(i, j) = round(positions(i, j)); % Ensure integer values for variables 4 and 5
            end
        end
        
        % Evaluate new position
        score = objective_function(positions(i, :));
        
        % Update personal best if the new position is better
        if score < personal_best_scores(i)
            personal_best_scores(i) = score;
            personal_best_positions(i, :) = positions(i, :);
        end
    end
    
    % Update global best
    [current_best_score, idx] = min(personal_best_scores);
    if current_best_score < global_best_score
        global_best_score = current_best_score;
        global_best_position = personal_best_positions(idx, :);
    end
    
  % Record convergence and variable changes
    convergence(iter) = global_best_score;
    variable_changes(iter, :) = global_best_position;

    % Display iteration results
    fprintf('Iteration %d/%d, Best Score: %.4f\n', iter, n_iterations, global_best_score);
end

% Display final results
disp('Optimal Solution:');
disp(global_best_position);
disp('Objective Function Value:');
disp(global_best_score);

% Plotting results

%%
% Plot convergence
figure(1);
plot(1:n_iterations, convergence, '-o');
xlabel('Iteration');
ylabel('Objective Function Value');
title('Convergence of Objective Function Value');

% Plot variable changes over iterations
figure(2);
plot(1:n_iterations, variable_changes(:, 1), '-o', 'DisplayName', 'Load 1');
hold on;
plot(1:n_iterations, variable_changes(:, 2), '-o', 'DisplayName', 'Load 2');
plot(1:n_iterations, variable_changes(:, 3), '-o', 'DisplayName', 'Load 3');
plot(1:n_iterations, variable_changes(:, 4), '-o', 'DisplayName', 'Loc Load 1');
plot(1:n_iterations, variable_changes(:, 5), '-o', 'DisplayName', 'Loc Load 2');
plot(1:n_iterations, variable_changes(:, 6), '-o', 'DisplayName', 'Loc Load 2');
plot(1:n_iterations, variable_changes(:, 7), '-o', 'DisplayName', 'Teta 1');
plot(1:n_iterations, variable_changes(:, 8), '-o', 'DisplayName', 'Teta 2');
plot(1:n_iterations, variable_changes(:, 9), '-o', 'DisplayName', 'Teta 2');

hold off;
xlabel('Iteration');
ylabel('Variable Values');
title('Changes in Variables Over Iterations');
legend('show');
