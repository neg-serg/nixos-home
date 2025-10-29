{
  hy3,
  system,
  pkgs,
}: {
  hy3Plugin = hy3.packages.${system}.hy3;
  bpf-host-latency = pkgs.neg.bpf_host_latency;
}
