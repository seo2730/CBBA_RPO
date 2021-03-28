function scoreVal = compute_sequence_score(assignmentMatrix, Task_Struct)

% assignmentMatrix = [taskID, weekNum]
numTasks = size(assignmentMatrix,1);
scoreVal = 0;
for iTask = 1:numTasks
    tID = assignmentMatrix(iTask,1);
    scoreVal = scoreVal + Task_Struct(tID).score;
end

