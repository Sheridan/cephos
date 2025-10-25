#!/bin/bash

. live_build_config/includes.chroot_after_packages/usr/local/lib/cephos/base.sh.lib
use_logfile=0

read -r -d '' help_text <<EOF
Usage: $0 [-c config] [-m CephFS directory] [-o results directory]

 Examples:
    $0 -c stress_test.fio -m /mnt/cephfs/test -o /data/fio_results
    $0 -m /mnt/cephfs
EOF

# -------------------------------
# Parse arguments
# -------------------------------
while getopts ":c:m:o:h" opt
do
  case ${opt} in
    c) fio_conf="$OPTARG" ;;
    m) mount_dir="$OPTARG" ;;
    o) result_base_dir="$OPTARG" ;;
    h) usage ;;
   \?) wrong_opt "Invalid option: -$OPTARG" ;;
    :) wrong_opt "Option -$OPTARG requires an argument." ;;
  esac
done
shift $((OPTIND -1))

# -------------------------------
# Set default values
# -------------------------------
timestamp=$(date +'%Y%m%d_%H%M%S')

result_base_dir="$(realpath ${result_base_dir})"
fio_conf="$(realpath ${fio_conf})"
conf_name="$(basename ${fio_conf} .fio)"
results_dir="$(realpath ${result_base_dir}/${conf_name}_${timestamp})"
log_file="${results_dir}/fio_runtime.log"


# -------------------------------
# Environment checks
# -------------------------------
if [ ! -f "${fio_conf}" ]
then
  wrong_opt "Config file ${fio_conf} not found."
fi

if [ ! -d "${mount_dir}" ]
then
  wrong_opt "Directory ${mount_dir} does not exist or CephFS is not mounted."
fi

# -------------------------------
# Prepare results directory
# -------------------------------
mkdir -p "${results_dir}/graphs"
cd "${results_dir}" || exit 1

log_info "Configuration:"
log_info "  FIO config : ${fio_conf}"
log_info "  CephFS dir : ${mount_dir}"
log_info "  Results dir: ${results_dir}"
log_info "-----------------------------------------------"

# -------------------------------
# Run fio
# -------------------------------
log_info "Running FIO test..."
start_time=$(date +%s)

fio --debug=file,process,mem --directory="${mount_dir}" "${fio_conf}" | tee "${log_file}"

end_time=$(date +%s)
runtime=$((end_time - start_time))
log_info "Testing completed. Runtime: ${runtime} seconds."

# -------------------------------
# Post-processing
# -------------------------------
log_info "Generating graphs using fio2gnuplot..."
fio2gnuplot --verbose --iops      -g -d graphs -t "CephOS iops"
fio2gnuplot --verbose --bandwidth -g -d graphs -t "CephOS bandwidth"
log_info "Graphs saved in ${results_dir}/graphs"

# -------------------------------
# Cleanup temporary files
# -------------------------------
log_info "Cleaning CephFS test files..."
# rm -f "${mount_dir}/*"
find "${mount_dir}" -maxdepth 1 -type f -delete

log_info "Cleanup completed. All results saved in ${results_dir}"
exit 0
