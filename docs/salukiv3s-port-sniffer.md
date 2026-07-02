
# Port Sniffer Debug Feature

Fog-ghaf supports configuration for enabling the KSZ9477 switch port sniffer service. Once started, the sniffer port receives traffic which is mirrored from all monitored ports.

## Configuration

### Predefined Settings
- **Monitored ports**: 0, 1, 3, 4 (LAN1, LAN2, LAN4, Orin NX)
- **Sniffer port**: 2 (LAN3)
- **Direction**: both (ingress and egress traffic)

## Usage

The port sniffer service is enabled in fog-ghaf by default.

### Starting the Service

**Option 1: Using systemctl**
```bash
sudo systemctl start switch-port-sniffer-service-host
```

**Option 2: Direct command**
```bash
sudo switch-sniffer-controller
```

### Checking Status

**Service status:**
```bash
sudo systemctl status switch-port-sniffer-service-host
```

**Port sniffer functionality status:**
```bash
sudo switch-sniffer-controller --status
```

### Stopping the Service

**Option 1: Using systemctl**
```bash
sudo systemctl stop switch-port-sniffer-service-host
```

**Option 2: Direct command**
```bash
sudo switch-sniffer-controller --disable
```

### Additional Information

For detailed usage instructions:
```bash
switch-sniffer-controller --help
```
