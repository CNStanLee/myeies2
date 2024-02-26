% Clear Workspace
clc;
close all;
clear;
% Load message data file
load('message_rx12.mat'); % Load source message
load('preamble_mat.mat'); % Load preamble data
% unpack the Symbols from the dataset

symbols = yout.message_rx.signals.values;
decode_bits = zeros(1, length(symbols)); % zero padding

% decoding the source message
for i = 1 : (length(symbols) - 1) 
    % find phase different of each symbol
    phase_off = angle(symbols(i+1) / symbols(i));
    % transfer the degree to rad
    phase_off = wrapTo2Pi(phase_off);
    % transform the phase shifting to binary code
    decode_bits(i + 1) = phase_off > 0; 
end

% this will cause one bit loss, cuz first bit has no value to
% compare phase use zero padding

% message structure
% guard preamble preamble data guard

% check decode message
for i = 1 : length(decode_bits)
    %fprinf('%d', decode_bits(i));
    fprintf("%d", round(decode_bits(i)));
end
fprintf("\r");

% msg1
start_index = 277;
end_index = 860;
data_frame1 = decode_bits(start_index : end_index);
% msg2
% start after preamble 164 byte(1312bits) and 4 bit = 1316bits
start_index = 1317;
end_index = 2000-100;
data_frame2 = decode_bits(start_index : end_index);

data_frame = [data_frame1, data_frame2];
asc_txt = char(bin2dec( ...
    reshape( ...
    sprintf('%d', ...
        data_frame(1:floor(length(data_frame) / 8) * 8)), ...
        8, ...
        []).')).';
disp(asc_txt);

%%
receivedSymbols = yout.message_rx.signals.values;
differentialDecodedBits = zeros(1, length(receivedSymbols));
for i = 2:length(receivedSymbols)
    phaseDiff = angle(receivedSymbols(i) / receivedSymbols(i-1));
    phaseDiff = wrapTo2Pi(phaseDiff);
    differentialDecodedBits(i-1) = phaseDiff > 0;
end
startIndex =  length(preamble) + 148;
% 假设消息后也有100个样本的保护带
EndIndex = length(differentialDecodedBits) - 100;
dataBits = differentialDecodedBits(startIndex:EndIndex);
%dataBits = differentialDecodedBits;
% 将比特转换为ASCII文本
numChars = floor(length(dataBits) / 8);
asciiText = char(bin2dec(reshape(sprintf('%d', dataBits(1:8*numChars)), 8, []).')).';
% 显示结果
disp(asciiText);


