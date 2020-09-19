#!/bin/bash
# Usage example: ./taskParallelism.sh 10:14:32 10:14:55 task1 10:10:20 10:16:42 task2 10:12:01 10:13:22 task3

# Make sure printf uses dot instead of comma below
export LC_NUMERIC="en_US.UTF8"

# Size of time string '(HH:MM:SS)'
numTimeChars=10
# Max number of characters for task names
taskNameSize=10
# Start and end of time interval 2x'|' and a space after the end
usedParameters=3
# Available columns to use for visualisation of the execution time
numColumns=$(($(tput cols)-$numTimeChars-$taskNameSize-$usedParameters))

if [ $# -lt 3 ]; then
  echo "Input should be at least 3 arguments, two times <hh:mm:ss> and a name, e.g., startTime stopTime name"
  exit 1
fi

if [ $(($# % 3)) -ne 0 ]; then
  echo "Input should be a multiple of three, each entry has two times <hh:mm:ss> and a name, e.g., startTime stopTime name"
  exit 1
fi

# Initial start and end time
startTime=`date "+%s" -d 01/01/2100`
endTime=0

# Regex checking for expected time format HH:MM:SS
re='^[0-9]+:[0-9]+:[0-9]+$'
for v in $@
do
  if [[ $v =~ $re ]]; then
    timeInEpoch=`date "+%s" -d $v`
    if [ "$startTime" -gt "$timeInEpoch" ]; then
      startTime=$timeInEpoch
    fi
    if [ "$endTime" -lt "$timeInEpoch" ]; then
      endTime=$timeInEpoch
    fi
  fi
done

fullInterval=$(($endTime - $startTime))
secondsPerEntry=`bc -l <<< "($fullInterval) / $numColumns"`

# Header
totalHours=$(($fullInterval / 3600))
totalMinutes=$(($fullInterval / 60 - $totalHours * 60))
totalSeconds=$(($fullInterval % 60))
printf "%-${numColumns}s%0.2d:%0.2d:%0.2d\n" "00:00:00" "$totalHours" "$totalMinutes" "$totalSeconds"

# Print the individual tasks execution time
for ((i=1; i<= $#; i = i + 3 )); do
  entryStart=`date "+%s" -d ${@:$i:1}`
  entryEnd=`date "+%s" -d ${@:(($i+1)):1}`

  # Perform floating point arithmetic and store integer result
  startGap=$(printf "%.0f" `bc -l <<< "($entryStart - $startTime) / $secondsPerEntry"`)
  entryLength=$(printf "%.0f" `bc -l <<< "($entryEnd - $entryStart) / $secondsPerEntry"`)

  # Check that the entry fits in the time interval decided by the # of cols in the terminal
  if [ "$entryLength" -eq "0" ]; then
    entryLength=1
  fi
  if [ "$(($startGap+$entryLength))" -ge "$numColumns" ]; then
    # Update length such that startGap + length ends on numColumns - 1
    entryLength=$(($numColumns - $startGap - 1))
  fi

  # Get execution time
  hours=`bc <<< "($entryEnd - $entryStart) / 3600"`
  minutes=`bc <<< "(($entryEnd - $entryStart) / 60) - $hours * 60"`
  seconds=`bc <<< "($entryEnd - $entryStart) % 60"`

  # Create string representation of execution time as entryLength number of X:s
  executionTime=`yes X | head -$entryLength | tr -d "\n"`

  # Print |<Time interval with task execution time represented as X:s>| <Taskname 1-10 characters> <Execution time in format (HH:MM:SS)>
  printf "|%$(($startGap+$entryLength))s%$(($numColumns-$startGap-$entryLength))s %-$((taskNameSize)).$((taskNameSize))s (%0.2d:%0.2d:%0.2d)\n" \
         "${executionTime}" "|" "${@:(($i+2)):1}" \
         "$hours" \
         "$minutes" \
         "$seconds"
done
