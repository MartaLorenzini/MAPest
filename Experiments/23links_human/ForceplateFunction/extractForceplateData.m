function [ forceplate ] = extractForceplateData(AMTIFilename, suitTime, varargin )
%EXTRACTFORCEPLATEDATA allows to create a .mat stucture contatining all forceplate data 
% acquired during the Xsens experiment.
% 
% Inputs 
% -  AMTIFilename : the name of  file that contain the forceplate data;
% -  suitTime : time data from the xsens suit;
% -  outputDir : (optional) the directory where saving the output.
% -  allData : (optional) if true the function returns not only the cut data but all the data genereted by the forceplates.
% Outputs
% -  forceplate : data of the acquisition in a .mat format. 

options = struct(   ...
    'OUTPUTDIR', '',...
    'ALLDATA',  false... 
    );

% read the acceptable names
optionNames = fieldnames(options);

% count arguments
nArgs = length(varargin);
if round(nArgs/2)~=nArgs/2
    error('number of input is wrong')
end

for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
    inpName = upper(pair{1}); % make case insensitive

    if any(strcmp(inpName,optionNames))
        % overwrite options. If you want you can test for the right class here
        % Also, if you find out that there is an option you keep getting wrong,
        % you can use "if strcmp(inpName,'problemOption'),testMore,end"-statements
        options.(inpName) = pair{2};
    else
        error('%s is not a recognized parameter name',inpName)
    end
end

%% Load and read file .txt
delimiterIn = '\t';
AMTIData = dlmread(AMTIFilename, delimiterIn);

%% Create data struct for all data coming from the forceplates
allData =[];

% PROPERTIES
allData.properties.frameRate = 1000;
allData.properties.nrOfPlateform = 2;
nrOfFrames = size(AMTIData,1);
allData.properties.nrOfFrame = nrOfFrames;

% TIME
allData.time.unixTime = AMTIData(:,19)';
allData.time.standardTime = AMTIData(:,17)';

% PLATEFORMS
allData.plateforms.plateform1.frames = AMTIData(:,1)';
allData.plateforms.plateform1.forces = AMTIData(:,2:4)';
allData.plateforms.plateform1.moments = AMTIData(:,5:7)';
allData.plateforms.plateform2.frames = AMTIData(:,9)';
allData.plateforms.plateform2.forces = AMTIData(:,10:12)';
allData.plateforms.plateform2.moments = AMTIData(:,13:15)';

%% Function to determine the forceplate data corresponding to the suit data
forceplateTime = allData.time.unixTime;
timeIndex = timeCmp(suitTime,forceplateTime);

cutData = AMTIData(timeIndex,:);

%% Create data struct for cut data corresponding to the suit
data = [];

% PROPERTIES
data.properties.frameRate = 1000;
data.properties.nrOfPlateform = 2;
nrOfFrames = size(timeIndex,1);
data.properties.nrOfFrame = nrOfFrames;

% TIME
data.time.unixTime = cutData(:,17)';
data.time.standardTime = cutData(:,19)';

% PLATEFORMS
data.plateforms.plateform1.frames = cutData(:,1)';
data.plateforms.plateform1.forces = cutData(:,2:4)';
data.plateforms.plateform1.moments = cutData(:,5:7)';
data.plateforms.plateform2.frames = cutData(:,9)';
data.plateforms.plateform2.forces = cutData(:,10:12)';
data.plateforms.plateform2.moments = cutData(:,13:15)';

%% Create data struct
forceplate = [];

if (options.ALLDATA == 1)
    forceplate.data = data;
    forceplate.allData = allData;
else 
    forceplate.data = data;
end


%% Save data in a file.mat
if not(isempty(options.OUTPUTDIR))
    filename = 'forceplateData.mat';
    dir = fullfile(pwd, options.OUTPUTDIR);
    if ~exist(dir,'dir')
        mkdir(dir);
    end
    save(fullfile(options.OUTPUTDIR, filename),'forceplate');
end
end

function [timeIdx] = timeCmp(suitT,forceplateT)
lenSuit = length(suitT);
lenFp = length(forceplateT);
timeIdx = zeros(lenSuit, 1);
for i=1:lenSuit
    for j=1:lenFp
        if (timeIdx(i)==0)
            if (isequal(round(suitT(i)),round(forceplateT(j)))==1)
                timeIdx(i)=j;
            else
                if (round(suitT(i))<round(forceplateT(j)))           
                    timeIdx(i)=j;
                end
            end
        end
    end
end
end


