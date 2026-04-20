#!/bin/bash

dataset_path="datasets/tum"
log_dir="logs/lc_thres"
mkdir -p "$log_dir"

scenes=(
    rgbd_dataset_freiburg1_desk
    rgbd_dataset_freiburg1_room
    rgbd_dataset_freiburg1_360
)

thresholds=(0.85 0.90 0.95)

log_path="$log_dir/results.txt"
echo "Dataset,lc_thres,ATE_RMSE,Loops" > "$log_path"

for thres in "${thresholds[@]}"; do
    echo "=== lc_thres = $thres ==="
    for scene in "${scenes[@]}"; do
        echo "--- Running: $scene ---"
        python3 main.py \
            --image_folder "${dataset_path}/${scene}/rgb" \
            --submap_size 16 \
            --lc_thres "$thres" \
            --min_disparity 50 \
            --conf_threshold 25.0 \
            --max_loops 1 \
            --log_results \
            --log_path "${log_dir}/${scene}_lc${thres}.txt" \
            --skip_dense_log
    done
done

echo ""
echo "=== Computing ATE RMSE ==="
for thres in "${thresholds[@]}"; do
    for scene in "${scenes[@]}"; do
        echo "--- $scene lc_thres=$thres ---"
        evo_ape tum \
            "${dataset_path}/${scene}/groundtruth.txt" \
            "${log_dir}/${scene}_lc${thres}.txt" \
            --align --correct_scale
    done
done
