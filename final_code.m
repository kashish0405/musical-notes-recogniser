clc;
clear;
close all;
sampling_freq = 44100;	%Sampling frequency of audio signal
window = 2205;           %Size of window to be used for detecting silence
threshold = 600;         %threshold value
dft = [];                %array to store dtf value
start = [];              %array holding start indices of each note
endd = [];                %array holding end   indices of each note
Identified_Notes = [];   %5list of identified notes

array = [1046.50, 1174.66, 1318.51, 1396.91, 1567.98, 1760.00, 1975.53,2093.00, 2349.32, 2637.02, 2793.83, 3135.96, 3520.00, 3951.07,4186.01, 4698.63, 5274.04, 5587.65, 6271.93, 7040.00, 7902.13];
notes = ['C6', 'D6', 'E6', 'F6', 'G6', 'A6', 'B6','C7', 'D7', 'E7', 'F7', 'G7', 'A7', 'B7','C8', 'D8', 'E8', 'F8', 'G8', 'A8', 'B8'];
mute =false;
%% set up song
filename='C:\Users\Kashish Arora\Downloads\Sample.mp3';
[song,Fs] = audioread(filename);
Fs = Fs*4;   % speed up song (original audio file is very slow)
figure 
plot(song(:,1)), title('Entire song')
%% analyse window of song
t1 = 2.9e6;t2=4.9e6; %(change based on song)
y=song(t1:t2);
[~,n]=size(y);
audiowrite('Sample_window.wav',y,Fs);
[y2,Fs2] = audioread('Sample_window.wav');

%Listen to the audio.
sound(y2,Fs2);

%% downsampled by m
%downsampled 20 times using an avg filter

% take out some fo the high freq component as well as  dec the number of
% points in the sample to speed uo calc

clc
m = 20;
Fsm = round(Fs/m);
p = floor(n/m);
y_avg = zeros(1,p);
for i = 1:p
    y_avg(i) = mean(y(m*(i-1)+1:m*i));
end
figure
plot(linspace(0,100,n),abs(y))
hold on
plot(linspace(0,100,p),abs(y_avg))
title('Discrete notes of song')
legend('Original', '20-point averaged and down-sampled')
if ~mute, sound(y_avg,Fsm); end


%% threshold to find notes
% done using moving average threshold, bcoz some notes are significantly
% louder than others
close all
y_thresh = zeros(1,p);
i = 1;
while (i <= p)
    thresh = 5*median(abs(y_avg(max(1,i-5000):i)));
    if (abs(y_avg(i)) > thresh)
        for j = 0:500
            if (i + j <= p)
                y_thresh(i) = y_avg(i);
                i = i + 1;
            end
        end
        i = i + 1400;
    end
    i = i + 1;
end

figure
subplot(2,1,1)
plot(abs(y_avg))
title('Original song')
ylim([0 1.1*max(y_avg)])
subplot(2,1,2)
plot(abs(y_thresh))
title('Detected notes using moving threshold')
        
if ~mute, sound(y_thresh,round(Fsm)); 
end

%% find frequencies of each note
clc; close all

i = 1;
i_note = 0;
while i < p
    j = 1;
    end_note = 0;
    while (((y_thresh(i) ~= 0) || (end_note > 0)) && (i < p))
        note(j) = y_thresh(i);
        i = i + 1;
        j = j + 1;
        if (y_thresh(i) ~= 0)
            end_note = 20;
        else
            end_note = end_note - 1;
        end
        if (end_note == 0)
           if (j > 25)
               note_padded = [note zeros(1,j)]; % pad note with zeros to double size (N --> 2*N-1)
               Note = fft(note_padded);
               Ns = length(note);
               f = linspace(0,(1+Ns/2),Ns);
               [~,index] = max(abs(Note(1:length(f))));
               if (f(index) > 20)
                   i_note = i_note + 1;
                   fundamentals(i_note) = f(index)*2;
                   figure
                   plot(f,abs(Note(1:length(f))))
                   title(['Fundamental frequency = ',num2str(fundamentals(i_note)),' Hz'])
                    
               end
               i = i + 50;
           end
           clear note;
           break
        end
        
    end
    i = i + 1;
end

%% play back notes
amp = 1;
fs = 20500;  % sampling frequency
duration = .5;
recreate_song = zeros(1,duration*fs*length(fundamentals));

for i = 1:length(fundamentals)
    [letter(i,1),freq(i)]= FreqToNote(fundamentals(i));
    values = 0:1/fs:duration;
    a = amp*sin(2*pi*freq(i)*values*2);
    recreate_song((i-1)*fs*duration+1:i*fs*duration+1) = a;
    if ~mute, sound(a,fs); pause(.5); end
end
