#!/bin/bash

dataset_path="datasets/tum"
log_dir="logs/submap_size"
mkdir -p "$log_dir"

scenes=(
    rgbd_dataset_freiburg1_desk
    rgbd_dataset_freiburg1_room
    rgbd_dataset_freiburg1_360
)

sizes=(8 16 32)

log_path="$log_dir/results.txt"
echo "Dataset,submap_size,ATE_RMSE,FPS,Peak_GPU_MB" > "$log_path"

for size in "${sizes[@]}"; do
    echo "=== submap_size = $size ==="
    for scene in "${scenes[@]}"; do
        echo "--- Running: $scene ---"
        python3 main.py \
            --image_folder "${dataset_path}/${scene}/rgb" \
            --submap_size "$size" \
            --lc_thres 0.95 \
            --min_disparity 50 \
            --conf_threshold 25.0 \
            --max_loops 1 \
            --log_results \
            --log_path "${log_dir}/${scene}_sm${size}.txt" \
            --skip_dense_log
    done
done

echo ""
echo "=== Computing ATE RMSE ==="
for size in "${sizes[@]}"; do
    for scene in "${scenes[@]}"; do
        echo "--- $scene submap_size=$size ---"
        evo_ape tum \
            "${dataset_path}/${scene}/groundtruth.txt" \
            "${log_dir}/${scene}_sm${size}.txt" \
            --align --correct_scale
    done
done
