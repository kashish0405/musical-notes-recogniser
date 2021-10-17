# Musical Notes Recogniser
## Introduction
Musical sounds each have a certain pitch that we can differentiate as notes. The goal in this project is to create a system that recognizes these musical sound waves and determines the note's pitch and octave according to the standard piano middle C scale.  

In this project, I also analyzed a simple series of musical sounds and determine each of their respective notes simultaneously.
## Implementation
- Define notes and the frequency they have.
- Read the sound data and define the window size to evaluate the sound.  
- For each evaluation window, take the FFT and check which note has the frequency closest to the maximum amplitude.
