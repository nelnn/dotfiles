

# Set up the service and timer
```bash
# Reload systemd user units
systemctl --user daemon-reexec
systemctl --user daemon-reload

systemctl enable --now randomise-wallpaper.service
systemctl enable --now randomise-wallpaper.timer
```

# Update Service
```bash
systemctl --user daemon-reload
systemctl restart randomise-wallpaper.service
systemctl restart randomise-wallpaper.timer
```
