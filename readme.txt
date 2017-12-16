1) What's working and what's not?
	Everything worked!

2) Success rate
	100% for int_float, float_int, and float_float.
	With the exception for float_int where we get the correct output but the auto-grader graded us wrong.

3) How to run the bench?
	All the components are in the root folder. All the test bench are in the bench folders separated by the function name
	Just add everything to ModelSim, and add the benchs to it and run it. I also make separate ROMs for each functions inside the bench folders.

4) What I changed in the test bench?
	I modify the bench to use my top instead of the dummy. Also for int_float, I modified the input location from 1,2 to 0,1 because that is what we expected in our program.

5) Assembler
	We have included the assembler inside java_things folder. Please compile first before use. 