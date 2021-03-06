% pop_ImportTextVector() - Import numveric vector from text file.
%
% Usage:
%   >>  OUTEEG = pop_ExportOpenFormat( INEEG, EpochPts, OffsetPts );
%
% Inputs:
%   INEEG       - input EEG continuous dataset
%   EpochPts    - NPts per epoch.
%   OffsetPts   - NPts to offset beginning of each epoch.
%    
% Outputs:
%   OUTEEG  - output dataset
%
% See also:
%   SEGMANTATION, EEGLAB 

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

function [EEG com] = pop_ImportTextVector(EEG, FileName, FilePath);

% the command output is a hidden output that does not have to
% be described in the header
com = ''; % this initialization ensure that the function will return something
          % if the user press the cancel button            

% display help if not enough arguments
% ------------------------------------
if nargin < 1
	help pop_ImportTextVector;
	return;
end;	

% pop up window
% -------------

if nargin < 2
    
    [FileName, FilePath] = uigetfile('*.*','Open Text file:','*.*');
%    FileName = sprintf('%s%s', FilePath, FileName);
    
end;

%EEG=eeg_emptyset;

EEG = ImportTextVector(EEG, FileName, FilePath);

% return the string command
% -------------------------

com = sprintf('[EEG com] = pop_ImportTextVector( %s, ''%s'', ''%s'' );',inputname(1), FileName, FilePath)

return;




