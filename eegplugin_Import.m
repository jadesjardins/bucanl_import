% eegplugin_Import() - Import menu.
function eegplugin_Import(fig,try_strings,catch_strings);


% get handle for "import data" submenu.
importmenu=findobj(fig,'tag','import data');

% Create cmd.
cmdIERPsF='[EEG LASTCOM] = pop_ImportERPscoreFormat( EEG );';
finalcmdIERPsF=[try_strings.no_check cmdIERPsF catch_strings.new_and_hist];

cmdIInstC='[EEG LASTCOM] = pop_ImportInstCFormat( EEG );';
finalcmdIInstC=[try_strings.no_check cmdIInstC catch_strings.new_and_hist];

cmdIBPMF='[EEG LASTCOM] = pop_ImportBPMFormat( EEG );';
finalcmdIBPMF=[try_strings.no_check cmdIBPMF catch_strings.new_and_hist];

cmdIBDF='[EEG LASTCOM] = pop_ImportBDFFormat( EEG );';
finalcmdIBDF=[try_strings.no_check cmdIBDF catch_strings.new_and_hist];

cmdIBVArF='[EEG LASTCOM] = pop_ImportBVARawFormat(EEG);';
finalcmdIBVArF=[try_strings.no_check cmdIBVArF catch_strings.new_and_hist];

cmdIBVAmF='[EEG LASTCOM] = pop_ImportBVAMarkerFormat(EEG);';
finalcmdIBVAmF=[try_strings.no_check cmdIBVAmF catch_strings.new_and_hist];

cmdIEGIEF='[EEG LASTCOM] = pop_ImportEGIEFormat(EEG);';
finalcmdIEGIEF=[try_strings.no_check cmdIEGIEF catch_strings.new_and_hist];

cmdIMULF='[EEG LASTCOM] = pop_ImportMULFormat(EEG);';
finalcmdIMULF=[try_strings.no_check cmdIMULF catch_strings.new_and_hist];

cmdEMGwF='[EEG LASTCOM] = pop_ImportEMGwFormat(EEG);';
finalcmdEMGwF=[try_strings.no_check cmdEMGwF catch_strings.new_and_hist];

cmdEMGwSSF='[EEG LASTCOM] = pop_ImportEMGwSSFormat(EEG);';
finalcmdEMGwSSF=[try_strings.no_check cmdEMGwSSF catch_strings.new_and_hist];

cmdEMGwWS='[EEG LASTCOM] = pop_ImportEMGwWS(EEG);';
finalcmdEMGwWS=[try_strings.no_check cmdEMGwWS catch_strings.new_and_hist];

cmdITV='[EEG LASTCOM] = pop_ImportTextVector(EEG);';
finalcmdITV=[try_strings.no_check cmdITV catch_strings.new_and_hist];

% add format labels to "Import" menu.
uimenu(importmenu,'label','ERPscore Format','callback',finalcmdIERPsF,'separator', 'on');
uimenu(importmenu,'label','Instep .c Format','callback',finalcmdIInstC);
uimenu(importmenu,'label','Biopac Matlab exported','callback',finalcmdIBPMF);
uimenu(importmenu,'label','BioSemi ".bdf" Format','callback',finalcmdIBDF);
uimenu(importmenu,'label','Read vector from text file.','callback',finalcmdITV);

EMGwmenu=uimenu(importmenu, 'label', 'EMGworks');
uimenu(EMGwmenu,'label','Single EMGworks raw file','callback',finalcmdEMGwF); 
uimenu(EMGwmenu,'label','Read Multiple EMGwork files from folder','callback',finalcmdEMGwSSF); 
uimenu(EMGwmenu,'label','Comvert multiple files to SET format','callback',finalcmdEMGwWS); 

BVAmenu=uimenu(importmenu, 'label', 'Brain Vision');
uimenu(BVAmenu,'label','BVA Raw file','callback',finalcmdIBVArF); 
uimenu(BVAmenu,'label','BVA Marker file','callback',finalcmdIBVAmF); 

EGImenu=uimenu(importmenu, 'label', 'EGI');
uimenu(EGImenu,'label','EGI event export','callback',finalcmdIEGIEF); 

BESAmenu=uimenu(importmenu, 'label', 'BESA');
uimenu(BESAmenu,'label','BESA .mul file','callback',finalcmdIMULF);
