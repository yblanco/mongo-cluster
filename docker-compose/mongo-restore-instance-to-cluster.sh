#!/bin/bash
error() {
  if [ -z "$1" ]
  then
    echo "¡Bye!"
  else
    echo "¡Oh, Oh¡"
    echo "¡ERROR! - ${1}"
  fi
  exit 1
}

help() {
  echo "Use:"
  echo "  sh backup.sh --database|-d {DB_NAME} [optionals args]"
  echo "  Required:"
  echo "    --database|-d {DB_NAME} - Database name for backup and restore"
  echo "    --backup_docker {DOCKER_NAME} - Momngo docker to backup"
  echo "  Optional:"
  echo "    --help|-h|help - show help"
  echo ""
  error "$1"
}

required() {
  NAME=$1
  VALUE=$2
  if [ -z "$VALUE" ]
  then
    help "Args ${NAME} required"
  fi
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"
  shift
  value="$1"
  shift
  case ${key} in
    --backup_docker|-b)
      DOCKER_NAME=$value
      ;;
    --database|-d)
      DB=$value
      ;;
    --help|help|-h)
      help
      ;;
    *)
      POSITIONAL+=("$value")
      ;;
    esac
done
echo "NO SIRVE"

# required "{--database|-d}" $DB
# required "{--backup_docker|-b}" $DOCKER_NAME
# docker exec ${DOCKER_NAME} apt-get update
# docker exec ${DOCKER_NAME} apt-get install -y lvm2
# docker exec ${DOCKER_NAME} lvcreate --size 100M --snapshot --name mdb-snap01 /dev/vg0/mongodb
#
# # LVCREATE=`(which lvcreate | wc -l)`
# # if [ ${LVCREATE} -eq 0 ]
# # then
# #   error "'lvcreate' is required. Please Install 'lvm2'"
# # fi
# #
# # if [ -z "${BACKUP_PATH}" ]
# # then
# #   error "Backup Path is Invalid"
# # else
# #   VOL_PATH="/docker_vgs"
# #   echo "> Creating Snapshot from ${BACKUP_PATH}"
# #   echo ">> Removing ${VOL_PATH}"
# #   sudo rm -rf ${VOL_PATH}
# #   echo ">> Creating ${VOL_PATH}"
# #   sudo mkdir ${VOL_PATH}
# #   echo ">> Creating Physical Volumen in ${VOL_PATH}"
# #   sudo pvcreate ${VOL_PATH}
# #   echo ">> Creating Virtual Volumen in ${VOL_PATH}"
# #   sudo vgcreate docker ${VOL_PATH}
# #   echo ">> Creating Snapshot"
# #   sudo lvcreate -L 15G -T docker/mongo-backup
# # fi
