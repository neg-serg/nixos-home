{
    programs.btop = {
        enable = true;
        settings = {
            truecolor = true;
            presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
            vim_keys = true;
            rounded_corners = false;
            graph_symbol = "braille";
            graph_symbol_cpu = "default";
            graph_symbol_gpu = "default";
            graph_symbol_mem = "default";
            graph_symbol_net = "default";
            graph_symbol_proc = "default";
            shown_boxes = "cpu mem proc";
            update_ms = 500; # Fast update
            proc_sorting = "cpu lazy";
            proc_reversed = false; # Reverse sorting order, true; or false;.
            proc_tree = false; # Show processes as a tree.
            proc_colors = true; # Use the cpu graph colors in the process list.
            proc_gradient = true; # Use a darkening gradient in the process list.
            proc_per_core = true; # If process cpu usage should be of the core it's running on or usage of the total available cpu power.
            proc_mem_bytes = true; # Show process memory as bytes instead of percent.
            proc_cpu_graphs = true; # Show cpu graph for each process.
            proc_info_smaps = false; # Use /proc/[pid]/smaps for memory information in the process info box (very slow but more accurate)
            proc_left = true; # Show proc box on left side of screen instead of right.
            proc_filter_kernel = true; # (Linux) Filter processes tied to the Linux kernel(similar behavior to htop).
            proc_aggregate = true; # In tree-view, always accumulate child process resources in the parent process.
            cpu_graph_upper = "total";
            cpu_graph_lower = "total";
            show_gpu_info = "Auto"; # If gpu info should be shown in the cpu box. Available values = "Auto", "On" and "Off".
            cpu_invert_lower = true; # Toggles if the lower CPU graph should be inverted.
            cpu_single_graph = false; # Set to true; to completely disable the lower CPU graph.
            cpu_bottom = false; # Show cpu box at bottom of screen instead of top.
            show_uptime = true; # Shows the system uptime in the CPU box.
            check_temp = true; # Show cpu temperature.
            cpu_sensor = "Auto"; # Which sensor to use for cpu temperature, use options menu to select from list of available sensors.
            show_coretemp = true; # Show temperatures for cpu cores also if check_temp is true; and sensors has been found.
            cpu_core_map = "";
            temp_scale = "celsius"; # Which temperature scale to use, available values: "celsius", "fahrenheit", "kelvin" and "rankine".
            base_10_sizes = false; # Use base 10 for bits/bytes sizes, KB = 1000 instead of KiB = 1024.
            show_cpu_freq = true; # Show CPU frequency.
            clock_format = "%X";
            background_update = true; # Update main ui in background when menus are showing, set this to false if the menus is flickering too much for comfort.
            custom_cpu_name = ""; # Custom cpu model name, empty string to disable.
            disks_filter = "";
            mem_graphs = false; # Show graphs instead of meters for memory values.
            mem_below_net = false; # Show mem box below net box instead of above.
            zfs_arc_cached = true; # Count ZFS ARC in cached and available memory.
            show_swap = true; # If swap memory should be shown in memory box.
            swap_disk = true; # Show swap as a disk, ignores show_swap value above, inserts itself after first disk.
            show_disks = false; # If mem box should be split to also show disks info.
            only_physical = true; # Filter out non physical disks. Set this to false; to include network disks, RAM disks and similar.
            use_fstab = true; # Read disks list from /etc/fstab. This also disables only_physical.
            zfs_hide_datasets = false; # Setting this to true; will hide all datasets, and only show ZFS pools. (IO stats will be calculated per-pool)
            disk_free_priv = false; # Set to true to show available disk space for privileged users.
            show_io_stat = true; # Toggles if io activity % (disk busy time) should be shown in regular disk usage view.
            io_mode = true; # Toggles io mode for disks, showing big graphs for disk read/write speeds.
            io_graph_combined = false; # Set to true; to show combined read/write io graphs in io mode.
            io_graph_speeds = "";
            net_download = 100;
            net_upload = 100;
            net_auto = true; # Use network graphs auto rescaling mode, ignores any values set above and rescales down to 10 Kibibytes at the lowest.
            net_sync = false; # Sync the auto scaling for download and upload to whichever currently has the highest scale.
            net_iface = ""; # Starts with the Network Interface specified here.
            show_battery = false; # Show battery stats in top right if battery is present.
            selected_battery = "Auto"; # Which battery to use if multiple are present. "Auto" for auto detection.
            log_level = "WARNING";
            nvml_measure_pcie_speeds = true; # Measure PCIe throughput on NVIDIA cards, may impact performance on certain cards.
            gpu_mirror_graph = true; # Horizontally mirror the GPU graph.
            custom_gpu_name0 = ""; # Custom gpu0 model name, empty string to disable.
            custom_gpu_name1 = ""; # Custom gpu1 model name, empty string to disable.
            custom_gpu_name2 = ""; # Custom gpu2 model name, empty string to disable.
            custom_gpu_name3 = ""; # Custom gpu3 model name, empty string to disable.
            custom_gpu_name4 = ""; # Custom gpu4 model name, empty string to disable.
            custom_gpu_name5 = ""; # Custom gpu5 model name, empty string to disable.
        };
    };
}
