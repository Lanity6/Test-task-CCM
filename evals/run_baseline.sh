#!/bin/bash

dataset_path="datasets/tum"
log_dir="logs/baseline"
mkdir -p "$log_dir"

scenes=(
    rgbd_dataset_freiburg1_desk
    rgbd_dataset_freiburg1_room
    rgbd_dataset_freiburg1_360
    rgbd_dataset_freiburg1_xyz
    rgbd_dataset_freiburg1_rpy
)

log_path="$log_dir/results.txt"
echo "Dataset,ATE_RMSE,FPS,Loops,Peak_GPU_MB" > "$log_path"

for scene in "${scenes[@]}"; do
    echo "=== Running: $scene ==="
    python3 main.py \
        --image_folder "${dataset_path}/${scene}/rgb" \
        --submap_size 16 \
        --lc_thres 0.95 \
        --min_disparity 50 \
        --conf_threshold 25.0 \
        --max_loops 1 \
        --log_results \
        --log_path "${log_dir}/${scene}.txt" \
        --skip_dense_log
done

echo ""
echo "=== Computing ATE RMSE ==="
for scene in "${scenes[@]}"; do
    echo "--- $scene ---"
    evo_ape tum \
        "${dataset_path}/${scene}/groundtruth.txt" \
        "${log_dir}/${scene}.txt" \
        --align --correct_scale
done
