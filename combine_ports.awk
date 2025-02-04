#!/usr/bin/awk -f
#awk script realising combination of ports state changes between files
{
  for(i=1; i<=NF; i++){
    state = substr($i, 1, 1)
    number = substr($i, 2)
    if( state ~ /^[cfo]$/ ){
      combinedStates[number] = combinedStates[number] "|"state
      if(!(number in seen)){
         seen[number] = 1
         order[++n] = number
      }
    }
  }
}
END {
  for(i=1; i<=n; i++){
    ENDnumber = order[i]
    combinedStates[ENDnumber]=substr(combinedStates[ENDnumber], 2)
    printf "%s%s ", combinedStates[ENDnumber], ENDnumber
  }
  print ""
}
