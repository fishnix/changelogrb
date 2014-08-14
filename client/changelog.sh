#!/usr/bin/env bash
# Basic changelog shell client to submit change records to the API


TEMPFILE="/tmp/$(basename $0).$$.tmp"
# set defaults
CL_SERVER="localhost"
CL_PORT="4567"
CL_TOKEN=""
CL_USER=""
CL_HOSTNAME=""
CL_CRITICALITY=""
CL_DESCRIPTION=""
CL_BODY=""
CL_ARGS="CL_SERVER CL_PORT CL_TOKEN CL_USER CL_HOSTNAME CL_CRITICALITY CL_DESCRIPTION"

list_args ()
{
  echo "Listing arguments:"
  for arg in ${CL_ARGS}; do
    echo ${arg} ${!arg}
  done
}

# does some basic validation of parameters
check_args ()
{
  for arg in ${CL_ARGS}; do
    if [[ ${!arg} == "" ]]; then
      echo "Error: ${arg} not set properly"
      check_error=1
    fi
  done
  if [[ ${check_error} == 1 ]]; then 
    exit
  fi
}

usage ()
{
  echo "  Syntax: "
  echo "$(basename $0) [-s SERVER -p PORT] -t TOKEN -u USER -h HOSTNAME -c CRITICALITY -d DESCRIPTION"
  echo
}


# parse command-line arguments
while getopts "s:p:t:u:h:c:d:?" opt; do
  case $opt in
    s)
      CL_SERVER="$OPTARG"
      ;;
    p)
      CL_PORT="$OPTARG"
      ;;
    t)
      CL_TOKEN="$OPTARG"
      ;;
    u)
      CL_USER="$OPTARG"
      ;;
    h)
      CL_HOSTNAME="$OPTARG"
      ;;
    c)
      CL_CRITICALITY="$OPTARG"
      ;;
    d)
      CL_DESCRIPTION="$OPTARG"
      ;;
    ?)
      usage && exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage && exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Test if all required arguments were given
if [ "x" == "x${CL_TOKEN}" ]; then
  echo "Error: Missing -t argument"
  missing_arg=1
fi

if [ "x" == "x${CL_USER}" ]; then
  echo "Error: Missing -u argument"
  missing_arg=1
fi

if [ "x" == "x${CL_HOSTNAME}" ]; then
  echo "Error: Missing -h argument"
  missing_arg=1
fi

if [ "x" == "x${CL_CRITICALITY}" ]; then
  echo "Error: Missing -c argument"
  missing_arg=1
fi

if [ "x" == "x${CL_DESCRIPTION}" ]; then
  echo "Error: Missing -d argument"
  missing_arg=1
fi

if [[ ${missing_arg} == 1 ]]; then
  usage && exit 1
fi

#list_args
# validate parameters
check_args


# use you favorite editor to paste the actual body of the change (this is multi-line)
echo -e "### Contents of change below ### \n" > ${TEMPFILE}
"${EDITOR:-vi}" ${TEMPFILE}

# base64-encode the body (without line wrapping) to make it safe for storing as a blob
CL_BODY=`cat ${TEMPFILE} | base64 -w 0`

# POST to the API
CL_URI="http://${CL_SERVER}:${CL_PORT}/api/add"
echo "Sending change to ${CL_URI} ..."
curl ${CL_URI} -sS -X POST -H 'Content-Type: application/json' \
 -d "{\"token\": \"${CL_TOKEN}\", \"user\": \"${CL_USER}\", \"hostname\": \"${CL_HOSTNAME}\", \"criticality\": ${CL_CRITICALITY}, \"description\": \"${CL_DESCRIPTION}\", \"body\": \"${CL_BODY}\"}"
retval=$?
echo

rm -f ${TEMPFILE}

exit ${retval}

