function [titles,data] = flacHistories(input_file,output_file)
% This function opens the history file "input_file" from FLAC.
% The histories are read automatically, including a common x-axis.
% The titles are returned as the single row cell "tiltes".
% The data are returned as the multi row matrix "data".
% If an "output_file" is given, everything is exported for future use.

% Create empty arrays
titles={};
data=[];

% Only read if file exists
if exist(input_file,'file')==2

    % Open history file
    hisfile=fopen(input_file);

    % Initialize history counter
    iCols=0;
    comTitle=false;
    
    % Read the input file
    while ~feof(hisfile)
        nextline=fgetl(hisfile);
        % Check if a new history is found
        if startsWith(nextline,'History')
            % Update indices
            ilines=0;
            iCols=iCols+1;
            % Read headers
            nextline=fgetl(hisfile); %2nd line (not used)
            nextline=fgetl(hisfile); %3rd line (tiles processed below)
            xtitle=strtrim(nextline(1:27));
            ytitle=strtrim(nextline(29:55));
            % Check for common x-axis
            if iCols>2 && strcmp(xtitle,cell2mat(titles(1)))
                comTitle=true; % Only keep y-axis
                titles(iCols)={ytitle};
            else
                comTitle=false; % Keep both x- and y- axes
                iCols=iCols+1;
                titles(iCols-1)={xtitle};
                titles(iCols)={ytitle};
            end
            nextline=fgetl(hisfile); %4th line (not used)
        else
            % Update indices
            ilines=ilines+1;
            % Read data
            datacell=textscan(nextline,'%f %f');
            if comTitle
                data(ilines,iCols)=cell2mat(datacell(2)); % Only keep y-axis
            else
                data(ilines,[iCols-1,iCols])=cell2mat(datacell); % Keep both x- and y- axes
            end
        end
    end

    % Close history file
    fclose(hisfile);
end

% Export file if output_file is defined
if exist('output_file','var')
    writecell(titles,output_file);
    writematrix(data,output_file,'WriteMode','append')
end

end
