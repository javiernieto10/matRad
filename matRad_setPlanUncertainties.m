function [pln] = matRad_setPlanUncertainties(ct,pln)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matRad_setPlanUncertainties function provides functionalities to define 
% treatment planning uncertainties
% 
% call
%   [cst,pln] = matRad_setPlanUncertainties(ct,cst,pln)
%
% input
%   ct:             ct cube
%   pln:            matRad plan meta information struct
%
% output
%   pln:            matRad's plan meta information struct including a sub-structure 
%                   pln.multScen holding information about multiple treatment plan scenarios
%
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright 2017 the matRad development team. 
% 
% This file is part of the matRad project. It is subject to the license 
% terms in the LICENSE file found in the top-level directory of this 
% distribution and at https://github.com/e0404/matRad/LICENSES.txt. No part 
% of the matRad project, including this file, may be copied, modified, 
% propagated, or distributed except according to the terms contained in the 
% LICENSE file.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~isfield(pln,'robOpt')
   pln.robOpt = false;
end

% define standard deviation of normal distribution - important for probabilistic treatment planning
multScen.rangeRelSD           = 3.5;               % given in [%]   
multScen.rangeAbsSD           = 1;                 % given in [mm]   
multScen.shiftSD              = [2 2 2];           % given in [mm]   

 %% create multiple scenario struc

   
% define parameters for individual treatment planning scenarios 

multScen.numOfCtScen          = ct.numOfCtScen; % number of imported ct scenarios

if ~pln.robOpt
    % a) define shift scenarios
   multScen.numOfShiftScen       = [0 0 0];        % number of shifts in x y and z direction       
   multScen.shiftSize            = [0 0 0];        % maximum shift [mm]  % (e.g. prostate cases 5mm otherwise 3mm)
   multScen.shiftGenType         = 'equidistant';  % equidistant: equidistant shifts, sampled: sample shifts from normal distribution
   multScen.shiftCombType        = 'individual';   % individual: no combination of shift scenarios, 
                                                   % combined: combine shift scenarios, 
                                                   % allcombined: create every possible shift combination
   multScen.shiftGen1DIsotropy   = '+-';           % for equidistant shifts: '+-': positive and negative, '-': negative, '+': positive shift generation 

   % b) define range error scenarios                                                
   multScen.numOfRangeShiftScen  = 0;              % number of absolute and/or relative range scnearios. 
                                                   % if absolute and relative range scenarios are defined then multScen.rangeCombType defines the resulting number of range scenarios
   multScen.maxAbsRangeShift        = 0;           % maximum absolute over and undershoot in mm   
   multScen.maxRelRangeShift        = 0  ;         % maximum relative over and undershoot in % 
   multScen.rangeCombType        = 'combined';     % individual: no combination of absolute and relative range scenarios
                                                   % combined:    combine absolute and relative range scenarios
   multScen.rangeGenType         = 'equidistant';  % equidistant: equidistant range shifts, sampled: sample range shifts from normal distribution
   multScen.scenCombType         = 'individual';   % individual: no combination of scenarios, allcombined: combine all scenarios

else 
   
   % a) define shift scenarios
   multScen.numOfShiftScen       = [2 2 2];        % number of shifts in x y and z direction       
   multScen.shiftSize            = [3 3 3];        % maximum shift [mm]  % (e.g. prostate cases 5mm otherwise 3mm)
   multScen.shiftGenType         = 'equidistant';  % equidistant: equidistant shifts, sampled: sample shifts from normal distribution
   multScen.shiftCombType        = 'individual';   % individual: no combination of shift scenarios, 
                                                   % combined: combine shift scenarios, 
                                                   % allcombined: create every possible shift combination
   multScen.shiftGen1DIsotropy   = '+-';           % for equidistant shifts: '+-': positive and negative, '-': negative, '+': positive shift generation 

   % b) define range error scenarios                                                
   multScen.numOfRangeShiftScen  = 2;              % number of absolute and/or relative range scnearios. 
                                                   % if absolute and relative range scenarios are defined then multScen.rangeCombType defines the resulting number of range scenarios
   multScen.maxAbsRangeShift     = 1;              % maximum absolute over and undershoot in mm   
   multScen.maxRelRangeShift     = 3.5;            % maximum relative over and undershoot in % 
   multScen.rangeCombType        = 'combined';     % individual: no combination of absolute and relative range scenarios; combined:    combine absolute and relative range scenarios
   multScen.rangeGenType         = 'equidistant';  % equidistant: equidistant range shifts, sampled: sample range shifts from normal distribution
   
   
   multScen.scenCombType         = 'individual';   % individual: no combination of scenarios, allcombined: combine all scenarios

end


% create multiScen struct
pln.multScen    = matRad_setMultScen(multScen); % calcProb missing.

%% get probabilities
vMu                    = [0 0 0 0 0];
vSD                    = [multScen.shiftSD multScen.rangeAbsSD multScen.rangeRelSD];

pln.multScen.scenProb  = matRad_calcScenProb(vMu,vSD,pln.multScen.scenForProb,'probBins','normDist');
 
end