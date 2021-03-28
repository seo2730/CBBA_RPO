# CBBA_RPO
CBBA RPO paper supporting data.
The main script is named “aa_MainScript_RPO_CBBA.m”. Open this file and modify the set up variables to configure the proper planning. The “Define agents and tasks” section contains the variables a user will most often set up. The number of agents and tasks are specified in this section as identified in . The orbital parameters and randomization routines are found within the “process_agent_task.m” function. The “process_agent_task.m” function can be modified to change the orbital configuration.

Note, that each time the script “aa_MainScript_RPO_CBBA.m” is executed, a new orbital configuration will be generated based on the information specified inside of the “process_agent_task” function. If a set configuration is necessary, I recommend generating the tasks and agents using that function and then saving that set up to a *.mat file and loading it into the script instead of generating a new set of tasks/agents with the “process_agent_task” function each time. 

Alternatively, a user can run the "aaMainScript_RPO_CBBA_preload.m" script to load an existing scenario.
