#!/usr/bin/env bash
# prometheus_collector.sh - Exports detailed update metrics for Prometheus node_exporter.
#
# This script generates metrics about the state of Podman container update checks.
# It is designed to be sourced by podcheck.sh and then invoked with:
#
#   prometheus_exporter <num_no_updates> <num_updates> <num_errors> <total_containers> <check_duration_seconds>
#
# Metrics:
#   podcheck_no_updates:
#       Number of containers that are already on the latest image.
#   podcheck_updates:
#       Number of containers with updates available.
#   podcheck_errors:
#       Number of containers that encountered errors during the update check.
#   podcheck_total:
#       Total number of containers checked.
#   podcheck_check_duration:
#       Duration (in seconds) it took to perform the update check.
#   podcheck_last_check_timestamp:
#       Epoch timestamp when the update check was performed.
#
# The metrics are written to a file named podcheck.prom in the specified 
# CollectorTextFileDirectory, or /tmp if not specified.
#

prometheus_exporter() {
  local no_updates="$1"
  local updates="$2"
  local errors="$3"
  local total="${4:-$((no_updates + updates + errors))}"
  local check_duration="${5:-0}"
  local collector_dir="${CollectorTextFileDirectory:-/tmp}"
  local metrics_file="${collector_dir}/podcheck.prom"
  local tmp_file="${metrics_file}.$$"
  local last_check_timestamp
  last_check_timestamp=$(date +%s)

  {
    echo "# HELP podcheck_images_analyzed Podman images that have been analyzed."
    echo "# TYPE podcheck_images_analyzed gauge"
    echo "podcheck_images_analyzed $total"

    echo "# HELP podcheck_images_outdated Podman images that are outdated."
    echo "# TYPE podcheck_images_outdated gauge"
    echo "podcheck_images_outdated $updates"

    echo "# HELP podcheck_images_latest Podman images that are on the latest image."
    echo "# TYPE podcheck_images_latest gauge"
    echo "podcheck_images_latest $no_updates"

    echo "# HELP podcheck_images_error Podman images with analysis errors."
    echo "# TYPE podcheck_images_error gauge"
    echo "podcheck_images_error $errors"

    echo "# HELP podcheck_images_analyze_timestamp_seconds Last podcheck run time."
    echo "# TYPE podcheck_images_analyze_timestamp_seconds gauge"
    echo "podcheck_images_analyze_timestamp_seconds $last_check_timestamp"

    echo "# HELP podcheck_no_updates Number of containers already on latest image."
    echo "# TYPE podcheck_no_updates gauge"
    echo "podcheck_no_updates $no_updates"
    
    echo "# HELP podcheck_updates Number of containers with updates available."
    echo "# TYPE podcheck_updates gauge"
    echo "podcheck_updates $updates"
    
    echo "# HELP podcheck_errors Number of containers with errors during update check."
    echo "# TYPE podcheck_errors gauge"
    echo "podcheck_errors $errors"
    
    echo "# HELP podcheck_total Total number of containers checked."
    echo "# TYPE podcheck_total gauge"
    echo "podcheck_total $total"
    
    echo "# HELP podcheck_check_duration Duration in seconds for the update check."
    echo "# TYPE podcheck_check_duration gauge"
    echo "podcheck_check_duration $check_duration"
    
    echo "# HELP podcheck_last_check_timestamp Epoch timestamp of the last update check."
    echo "# TYPE podcheck_last_check_timestamp gauge"
    echo "podcheck_last_check_timestamp $last_check_timestamp"
  } > "$tmp_file" && mv "$tmp_file" "$metrics_file"
}
