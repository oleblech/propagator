function combineFiles()
    % Combines all files in one .txt file and copies it to clipboard

    % Get the directory of the current script
    scriptDir = fileparts(mfilename('fullpath'));
    
    % Get the list of all .m files in the current directory
    files = dir(fullfile(scriptDir, '*.m'));
    
    % Remove combineFiles.m from the list of files to process
    files = files(~strcmp({files.name}, 'combineFiles.m'));
    
    % Combine the content of the files into a single output
    combinedContent = '';
    for i = 1:length(files)
        fileContent = fileread(fullfile(scriptDir, files(i).name));
        combinedContent = strcat(combinedContent, sprintf('\n\n%% %s\n', files(i).name), fileContent);
    end
    
    % Define the output file name
    outputFileName = 'combinedOutput.txt';
    
    % Write the combined content to the output file
    fileID = fopen(outputFileName, 'w');
    fprintf(fileID, '%s', combinedContent);
    fclose(fileID);
    
    % Copy the combined content to the clipboard
    clipboard('copy', combinedContent);
    
    fprintf('Combined output saved to %s and copied to clipboard.\n', outputFileName);
end
