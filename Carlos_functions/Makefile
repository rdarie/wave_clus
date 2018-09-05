MATLABPATH:=/Applications/Matlab/MATLAB_R2013b.app/bin/

MEX=$(MATLABPATH)mex
all: temp_match_X.mexmaci64 temp_match_overlap_X.mexmaci64
temp_match.o: temp_match.c
	$(MEX) -c temp_match.c
temp_match_X.mexmaci64: temp_match.o temp_match_X.c
	$(MEX) temp_match_X.c temp_match.o -o temp_match_X.mexmaci64
temp_match_overlap_X.mexmaci64: temp_match.o temp_match_overlap_X.c
	$(MEX) temp_match_overlap_X.c temp_match.o -o temp_match_overlap_X.mexmaci64
clean:
	rm *.o
	rm *.mex*
