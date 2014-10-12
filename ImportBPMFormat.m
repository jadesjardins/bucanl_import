
function EEG = ImportBPMFormat(EEG, FileName, FilePath);

EEG.comments=sprintf('%s','Original file: ', FilePath, FileName);

fstruct=load(fullfile(FilePath,FileName));

EEG.data=fstruct.data';
EEG.srate=1000/fstruct.isi;
EEG.nbchan=size(EEG.data,1);
EEG.pnts=size(EEG.data,2);

for i=1:EEG.nbchan;
    EEG.chanlocs(i).labels=deblank(fstruct.labels(i,:));
end
