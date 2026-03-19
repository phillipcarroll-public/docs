# Ollama Vulkan Support

This will enable vulkan support for non-NVIDIA and unsupported AMD/Intel GPUs, basically RDNA4 and ARC GPUs in 2025.

Check `vulkaninfo` for your GPU id relating to GGML_VK_VISIBLE_DEVICES, for instance my ARC B580 is id 0, if you had dual or quad vulkan capable gpus you could set ...=0,1,2,3 or ...=0,1. OLLAMA_KEEP_ALIVE=0 just dumps vram/ram allocations for the model when you exit and does not keep it in ram for the short default timer.

Stop ollama.

`sudo systemctl stop ollama.service`

Edit the ollama service file.

`sudo micro /etc/systemd/system/ollama.service`

Add these under `[Service]`

- OLLAMA_VULKAN=1
    - Enable Vulkan API support
- OLLAMA_KEEP_ALIVE=0
    - This disables holding models in RAM/VRAM after you exit ollama
- GGML_VK_VISIBLE_DEVICES=0
    - Set what GPU ID will be used with the Vulkan API

```bash
Environment="OLLAMA_VULKAN=1"
Environment="OLLAMA_KEEP_ALIVE=0"
Environment="GGML_VK_VISIBLE_DEVICES=0"
```

Save and exit, then reload daemons.

`sudo systemctl daemon-reload`

Start the ollama service.

`sudo systemctl start ollama.service`

You can use `ollama ps` to see your new gpu/cpu split. 