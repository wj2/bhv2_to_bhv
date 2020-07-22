function [ bhv_struct ] = bhv2_to_bhv( bhv2_struct, condpath )

bhv_struct = struct();
bhv_struct.TrialNumber = [bhv2_struct.Trial]';
bhv_struct.BlockNumber = [bhv2_struct.Block]';
bhv_struct.TrialWithinBlock = [bhv2_struct.TrialWithinBlock]';
bhv_struct.ConditionNumber = [bhv2_struct.Condition]';
bhv_struct.AbsoluteTrialStartTime = [bhv2_struct.AbsoluteTrialStartTime]';
bhv_struct.TrialError = [bhv2_struct.TrialError]';
bhv_struct.CodeTimes = cellfun(@(x) x.CodeTimes, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
bhv_struct.CodeNumbers = cellfun(@(x) x.CodeNumbers, ...
    {bhv2_struct.BehavioralCodes}, 'UniformOutput', false);
bhv_struct.ReactionTime = [bhv2_struct.ReactionTime]';
bhv_struct.ObjectStatusRecord = [bhv2_struct.ObjectStatusRecord]';
temp = [bhv2_struct.RewardRecord]';
[temp.RewardOnTime] = temp.StartTimes;
[temp.RewardOffTime] = temp.EndTimes;
temp = rmfield(temp, 'StartTimes');
bhv_struct.RewardRecord = rmfield(temp, 'EndTimes');

bhv_struct.UserVars = struct();
for i = 1:length(bhv2_struct)
    fnames = fields(bhv2_struct(i).UserVars);
    for j = 1:length(fnames)
        bhv_struct.UserVars.(fnames{j}){i} = bhv2_struct(i).UserVars.(fnames{j});
    end
    fnames = fields(bhv2_struct(i).AnalogData);
    for j = 1:length(fnames)
        bhv_struct.AnalogData.(fnames{j}){i} = bhv2_struct(i).AnalogData.(fnames{j});
    end
end
bhv_struct.AnalogData.EyeSignal = bhv_struct.AnalogData.Eye;
% The following are not included, due to format changes.
%    'VariableChanges'
%    'CycleRate'
%    'Ver'
% And the field 'InfoByCond' appears to not be replicated in the bhv2.
objs = {bhv2_struct.TaskObject};
conds = unique([bhv2_struct.Condition]);
columns = max(cellfun(@length, objs));
bhv_struct.TaskObject = [bhv2_struct.TaskObject]';
% cell(length(conds), columns);
% for c = 1:length(conds)
%     cond = conds(c);
%     egs = objs([bhv2_struct.Condition] == cond);
%     eg = egs{1};
%     eg.CurrentConditionInfo
%     l = length(eg);
%     length(conds)
%     for j = 1:l
%         if length(eg{l}) <= 3
%             cstr = sprintf('%s(%d, %d)', eg{l}{:});
%         else
%             cstr = sprintf('%s(%s, %d, %d)', eg{l}{:});
%         end
%         bhv_struct.TaskObject{c, j} = cstr;
%     end
% end

if exist('condpath', 'var')
    cond_whitespace = '\t';
    cond_header = 1;
    txtspec = '%s%s%s%s%s%s%s%s%s%s';
    condfile = textscan(fopen(condpath), txtspec, 'Whitespace', cond_whitespace);
    infoByCond = cell(length(conds), 1);
    for i = 1:length(condfile)
        if strcmp(condfile{i}{1}, 'Info')
            for j = 1:length(conds)
                entr = strsplit(condfile{i}{j+cond_header}, ',');
                st = struct();
                for k = 1:length(entr)/2
                    entrInd = 2*k - 1;
                    field = strrep(entr{entrInd}, '''', '');
                    val = strrep(entr{entrInd+1}, '''', '');
                    st.(field) = val;
                    infoByCond{j} = st;
                end
            end
        end
    end
    bhv_struct.InfoByCond = infoByCond;
end
end

