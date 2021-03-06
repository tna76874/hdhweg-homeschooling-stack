#!/bin/bash
# This script exports docker images from a RUNNING docker-compose instance with TAGGED docker images.
export SCRIPT=$(readlink -f "$0")
export DIR="$PWD"
export COMPOSE_FILE="docker-compose.yml"

# Define functions
## Confirm function
confirm() {
    # call with a prompt string or use a default
    read -r -p "$@"" [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# check if file exists
isfile() {
  if [[ -r "${1:-}" ]]; then
      true
      return
  fi
  false
  return
}

# deploy as system script
deploysystem() {
    sudo cp "$SCRIPT" /usr/local/bin
    sudo chmod 755 /usr/local/bin/$(basename "$SCRIPT")
}

# export files from running docker-compose instance
get_export_data() {
    cd "$DIR"/..
    export EXPORT_FILE="$( realpath --relative-to=. "$DIR").tar"

    cd "$DIR"
    if isfile "$COMPOSE_FILE" ; then
        export EXP_IMAGES=$( docker-compose -f $COMPOSE_FILE images | tr -s ' ' | tail -n +3 | cut -d' ' -f 2-3 | tr ' ' ':' )

        echo -e "export\n\n$EXP_IMAGES\n"
        echo -e "to\n\n$EXPORT_FILE\n\n"
    else
        echo -e "\n \n ==> $COMPOSE_FILE not found. <==\n\n" && usage && exit 1
    fi  
}

export_docker_images() {
    cd "$DIR"
    docker save ${EXP_IMAGES} -o $EXPORT_FILE
}

# ###### Parsing arguments

#Usage print
usage() {
    echo "Usage: $0 -[f|d|h]" >&2
    echo "
   -f [FILE],   Select docker-compose.yml file.
   -d,          Deploy as system script
   -h,          Print this help text
   "
    exit 1
}

while getopts ':f:d' opt
#putting : in the beginnnig suppresses the errors for invalid options
do
case "$opt" in
   'f')export COMPOSE_FILE="$OPTARG";
       ;;
   'd')deploysystem && exit 0 || exit 1;
       ;;
    *) usage;
       ;;
esac
done

get_export_data
if $(confirm "Export images?") ; then
    export_docker_images
fi