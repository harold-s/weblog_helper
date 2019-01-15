docker build -t weblog_helper . > /dev/null 2>&1

if [ "${*: -1}" = '--help' ]
then
  docker run --rm weblog_helper ruby ./bin/weblog_helper.rb --help
  exit 0
fi

if ! [ -f ${*: -1} ]
then
  echo "Last argument must be a file. Received ${*: -1}"
  exit -1
fi

ARGV_WITHOUT_LAST_ARG=${*%${!#}}
DOCKER_FILE_TARGET=/target
# docker requires an absolute path for mounting a file
FILE_NAME=$(readlink --canonicalize -- ${*: -1})

docker run\
  --mount type=bind,source=$FILE_NAME,target=$DOCKER_FILE_TARGET\
  --rm weblog_helper\
  ruby ./bin/weblog_helper.rb $ARGV_WITHOUT_LAST_ARG $DOCKER_FILE_TARGET
