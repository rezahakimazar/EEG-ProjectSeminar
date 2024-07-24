%% Extract Values from the GrandAverageEEG for your statistical analysis
% Assuming GrandAverageEEG is a 4D double array with dimensions: subjects, conditions, channels, time

% Define the time window you are interested in
time_window = find(EEG.times >= 300 & EEG.times <= 400);  % specific time window you want to extract. recall that this is not in ms, but in timepoints in your EEG struct

% Define the specific electrode you are interested in
%elec = 2; %Fz
%elec = 23; %Cz
% elec = 12; %Pz 

elec = [13, 43, 51, 52]

% Get the indices of the time window in the GrandAverageEEG array
 

% Preallocate cell array to store the data
% We will store data in the format: Subject, Condition, Time, Value
data_to_save = {};

% Iterate over subjects
for subject = 1:5 % 1:6 % you can also keep the original subject IDs, by using the method used in the other scripts.
    % Iterate over conditions
    for condition = 1:4
        % Extract the data for the current subject, condition, and the specific channel at the specified time window
        
        values = squeeze(mean(GrandAverageEEG(subject, condition, elec, time_window),3));
        
        % Add the data to the cell array
        for t = 1:length(time_window)
            data_to_save = [data_to_save; {subject, condition, time_window(t), values(t)}];
        end
    end
end

% Convert the cell array to a table
data_table = cell2table(data_to_save, 'VariableNames', {'Subject', 'Condition', 'Time_point', 'Value'});

% Save the table as a CSV file
writetable(data_table, 'extracted_data_300-400.csv');

disp('Data has been extracted and saved to extracted_data.csv');
