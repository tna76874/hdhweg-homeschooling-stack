#!/bin/bash
export RESTIC_REPOSITORY="/restic/backup"
export RESTIC_PASSWORD_FILE="/root/RESTIC_PASSWORD"

restic "$@"