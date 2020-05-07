function out = readswc(dataPath)
% Read SWC formatted text files provided by neuPrint and others
% return matrix containing SWC data

fid = fopen(dataPath,'r');
out = [];
inHeader = 1;
while ~feof(fid)
    tline = fgetl(fid);
    if inHeader
        % if everything can be converted into numbers, you are already out
        % of the header region of the file.
        if ~any(isnan(cellfun(@str2double,strsplit(tline))))
            inHeader = 0;
        end
    end
    
    if ~inHeader
        out = [out; cellfun(@str2double,strsplit(tline))];
    end
end
end