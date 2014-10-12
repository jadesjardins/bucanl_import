% pop_ImportEMGworksFormat() - Import EMGworks raw files.
%
% Usage:
%   >>  OUTEEG = pop_ImportEMGworksFormat( EEG, FileName, FilePath);
%
% Inputs:
%   EEG       - input EEG continuous dataset
%   FilePath  - Path of target file.
%   FileName  - Name of target file.
%    
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   EEGLAB 

% Copyright (C) <2006>  <James Desjardins>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [EEG com] = pop_ImportEMGwWS(EEG, WSFilePath);

% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

EEG = [];
% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_ExportEMGwWS;
	return;
end;	

% pop up window
% -------------

if nargin < 2
    
    [WSFilePath] = uigetdir('','Select root conversion folder:')
    
end;

% call function sample either on raw data or ICA data
% ---------------------------------------------------

EEG=eeg_emptyset;

GoToRootPathStr=sprintf('%s%s%s','cd ''', WSFilePath, '''')
eval([GoToRootPathStr])

RootDir=[];
RootDir=dir;
RootDir=RootDir(3:length(RootDir));

j=0;
for i=1:length(RootDir);
    if RootDir(i).isdir==1;
        j=j+1;
        SubPath(j)=RootDir(i);
    end
end

for i=1:length(SubPath);
    i
    GoToSubPathStr=sprintf('%s%s%s','cd ''', SubPath(i).name, '''')
    eval([GoToSubPathStr])

    SubDir=[];
    SubDir=dir;
    SubDir=SubDir(3:length(SubDir));
    
    if exist('SesPath');
        clear SesPath
    end
    
    j=0;
    for ii=1:length(SubDir);
        if SubDir(ii).isdir==1;
            j=j+1;
            SesPath(j)=SubDir(ii);
        end
    end
    
    for ii=1:length(SesPath);
        ii
        
        if ii>1;
            eval([GoToSubPathStr])
        end
        
        EEG = ImportEMGwSSFormat(EEG, strcat(WSFilePath,'\', SubPath(i).name, '\', SesPath(ii).name));
        EEG.setname='raw';
        EEG = eeg_checkset( EEG );
        cd ..
        cd ..
        pop_SaveDatasetBatch( EEG, sprintf('%s%s', SubPath(i).name, SesPath(ii).name), 'set' );
        
    end
end

% return the string command
% -------------------------

com = sprintf('[EEG com] = pop_ImportEMGwWS( %s, ''%s'' );',inputname(1), WSFilePath);

return;




