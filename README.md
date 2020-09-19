# bash
A collection of useful bash scripts

## Task parallelism

Visualise parallel tasks by providing taskParallelism.sh with start time/stop time/task name like this:

./taskParallelism.sh 13:43:00 13:50:00 "Task 1" 13:47:24 13:49:10 "Task 2" 13:48:59 14:01:11 "Long taskname" 13:40:25 13:44:11 Task4

```
00:00:00                                                                         00:20:46
|          XXXXXXXXXXXXXXXXXXXXXXXXXXX                                           | Task 1     (00:07:00)
|                           XXXXXXX                                              | Task 2     (00:01:46)
|                                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| Long taskn (00:12:12)
|XXXXXXXXXXXXXXX                                                                 | Task4      (00:03:46)
```

The first line shows interval start time as 00:00:00 and time interval length as 00:20:46.
Between the '|' characters the different tasks execution time is indicated by an X.

To the right, the taskname and total execution time is listed.
Note that "Long taskname" was cut short as there is a 10 character limit at the moment.
