dataDir = '/home/ivan/Documents/ResearchDocs/minConsciousEEG/Alice_Set_Files/';
dataFormat = '.set';
saveDir = '/home/ivan/Documents/ResearchDocs/brianData/';
eogchannels = 38:39;
stimNames = {'Forward' 'Backward'};
stimLengths = [37037 37039];
numStims = length(stimLengths);

load([dataDir 'aliceRuns.mat'], 'runs')
load([dataDir 'subjectColors.mat'])

masterRuns = runs;

for currentFiles = 2:length(masterRuns)

  runs = masterRuns(1:currentFiles)
  runs = runs([runs.dataQuality]>0);

  ISCdata = {};
  refSubjects = {};
  fs = runs(1).fs;

  for i = 1:numStims
    ISCdata{i} = [];
    for j = 1:length(runs)
      ISCdata{i} = cat(3, ISCdata{i}, runs(j).extract(i));
    end
    refSubjects{i} = find([runs.subject]<300);
  end

  [isc persub w a] = multiStimISC(ISCdata, refSubjects, fs);

  for j = 1:length(runs)
    for i = 1:numStims
      runs(j).ISC{i} = persub{i}(:,j);
    end
  end

  s = [runs.subject];
  sunique = unique(s);

  for i = 1:length(sunique)

    subjects(i) = Subject();
    subjects(i) = subjects(i).setID(sunique(i));
    subjects(i).color = colors(sunique(i),:);
    current = runs([runs.subject]==sunique(i));

    for j = 1:length(current)
      subjects(i) = subjects(i).addRun(current(j));
    end

  end

  save([saveDir 'aliceSubjects_Processed'], 'subjects', '-v7.3')

  newMakeChart(subjects, a)

  set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
  saveas(gcf, [saveDir 'files2-' num2str(currentFiles) '_topoplots'], 'png')
  close

  set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
  saveas(gcf, [saveDir 'files2-' num2str(currentFiles) '_ISC'], 'png')
  close

end
