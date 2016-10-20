### This script runs through all soundfiles and textgrids in a folder and outputs a list of 1000 F0 values for any labeled interval,
### as well as the duration (s) for that interval
### Pitch window is set at 50-450 Hz 
### Tuuli Morrill, January 2015


form Pitch track file information
	comment Enter directory where soundfiles and textgrids are located
	text inFolder 
	comment Full path of the resulting text file
	text resultfile 
endform

#Check if the result file exists:
if fileReadable (resultfile$)
	pause The file 'resultfile$' already exists. Overwrite?
	filedelete 'resultfile$'
endif

#Write a row with column titles to the result file:
titleline$ = "Filename 'tab$'  IntervalLabel'tab$' IntervalDuration 'tab$'	Time	'tab$'	PointNumber	'tab$'	F0	'newline$'"
fileappend "'resultfile$'" 'titleline$'

Create Strings as file list... fileList 'inFolder$'/*.wav
numFiles = Get number of strings

for i from 1 to numFiles

	select Strings fileList
	fileNameLong$ = Get string... i
	fileNameShort$ = fileNameLong$-".wav"
	Read from file... 'inFolder$'/'fileNameLong$'

#### Get the pitch manipulation object (all the points)
	select Sound 'fileNameShort$'
	To Manipulation: 0.01, 50, 450

#### Interpolate between pitch points
	Extract pitch tier
	Interpolate quadratically: 4, "Semitones"
	To Pitch: 0.01, 50, 450

#### Smooth pitch contour
	Smooth: 5

#### Extract pitch information at each 1/1000 of the phrase (or, 300 points per second seems to work well if you know each file duration)
	Read from file... 'inFolder$'/'fileNameShort$'.TextGrid
	numberOfIntervals = Get number of intervals... 1
		for j from 1 to numberOfIntervals
			startphrase = Get starting point... 1 j
			endphrase = Get end point... 1 j
			soundingLabel$= Get label of interval... 1 j
			phraseduration = endphrase - startphrase
			phrasediv = phraseduration/1000
			pitchpoint = startphrase
				for k from 1 to 1000
					select Pitch 'fileNameShort$'
					f0 = Get value at time: pitchpoint, "semitones re 1 Hz", "Linear"	
					resultline$ = "'fileNameShort$' 'tab$' 'soundingLabel$''tab$' 'phraseduration' 'tab$' 'pitchpoint''tab$' 'k''tab$' 'f0' 'tab$''newline$'"
                			fileappend "'resultfile$'" 'resultline$'
					pitchpoint = startphrase+(k*phrasediv)
				endfor
			Read from file... 'inFolder$'/'fileNameShort$'.TextGrid
			endfor
Remove
endfor


