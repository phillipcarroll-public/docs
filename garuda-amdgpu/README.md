## Garuda AMD GPU/ROCm Install

Install MESA Driver version of Garuda

```bash
sudo pacman -S --needed linux-zen-headers rocm-hip-sdk rocm-opencl-runtime
sudo gpasswd -a $USER render
sudo gpasswd -a $USER video
sudo reboot
```

