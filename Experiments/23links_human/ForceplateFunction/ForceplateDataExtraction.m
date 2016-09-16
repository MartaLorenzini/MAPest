AMTIFileName = 'AMTIdata000.txt';
load('suitTimeVec');

[ forceplate ] = extractForceplateData(AMTIFileName, suitTimeVec, 'outputdir', 'data', 'alldata', 'true'); 