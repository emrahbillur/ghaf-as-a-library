# Partition table in fog-ghaf

| Partition | Description           |
| --------- | -----------           |
| nvme0n1p1 | Persistent partition  |
| nvme0n1p2 | Boot partition        |
| nvme0n1p3 | OS partition          |
| nvme0n1p4 | Data partition        |

```mermaid
flowchart TD
    subgraph "Persistent content"
        deviceidkeys[Device identity keys]
        provisioningstate[Provisioning state]
        tee[tee / HSM pins]
    end

    subgraph "fog-ghaf"
        ghafboot[Boot partition]
        ghafroot[Root partition]
    end

    subgraph "fog-hyper managed content"
        vmimages[VM images]
        containerimages[Container images]
        runtimestate[Runtime state]
    end

    subgraph "Partitions"
        persistent
        boot
        root
        data
    end

    deviceidkeys -- stored in --> persistent
    provisioningstate -- stored in --> persistent
    tee -- stored in --> persistent

    ghafboot -- 1:1 flash --> boot
    ghafroot -- 1:1 flash --> root

    vmimages -- stored in --> data
    containerimages -- stored in --> data
    runtimestate -- stored in --> data
```

# Partition lifecycles


## Persistent partition table-of-contents


```shell
Persistent/
├── certificates/                         # DAC data store
│   ├── identity.pem
│   ├── ca.pem
│   └── dac.json
│
├── tee/                                  # OPTEE data store (Proposal)
│   ├── 0
│   ├── 1
│   ...
│   └── ff
│
├── hsm-pins/                             # HSM pins store (Proposal)
│
│       
└── provisioning-data/                    # Fleet management provisioning
    ├── subfolder1
    ├── ca-certificate.pem
    ├── client-certificate.pem
    ├── client-certificate-request.pem
    ├── client.key
    ├── device-registered.txt
    ├── nats-url.txt
    ├── .provisioning_done.flag
    ├── .registration_done.flag
    └── serial-number.txt

```

## Persistent data lifecycles

```mermaid
sequenceDiagram
    participant Init
    participant Op-Init
    participant Operational
    participant Op-Decommision
    participant Decommision

    Init->>Decommision: DAC
    Op-Init->>Op-Decommision: OPTEE Data store
    Op-Init->>Op-Decommision: HSM Pins
    Op-Init->>Op-Decommision: Fleet Management Provisioning
```
| Partition      | Description                                               |
| ---------      | -----------                                               |
| Init           | Device factory initialization                             |
| Op-Init        | Customer provisioning of device (Identity, certificates)  |
| Operational    | Operational state                                         |
| Op-Decommision | Revocation of customer identities and certificates        |
| Decommision    | Revocation of identities and data generated in init state |

