flowchart TD
    A([Inicio]) --> B{¿v_COD_BITACORA_ALERT tiene valor?}
    B -- Sí --> R1["v_COLOR = 'R'<br/>Alerta OSINFOR"]
    B -- No --> C[Continuar]
    R1 --> C
    C --> D{¿Hay caducidad?<br/>v_CNT5>0 o v_CADUCA_TH_RD_TER_1/2/3=1}
    D -- Sí --> E{¿v_CNT7 > 0?}
    E -- Sí --> R2["v_COLOR = 'R'<br/>Caducidad por resolución de término PAU"]
    E -- No --> F[Evaluar estado PAU]
    D -- No --> F
    R2 --> F

    F --> G{¿ESTADO_PAU='ARCHIVO_PRELIMINAR'<br/>y v_COLOR <> 'R'?}
    G -- Sí --> H{¿BUEN_MANEJO=1?}
    H -- Sí --> I{¿COD_MTIPO='0000017'?}
    I -- Sí --> X1["v_COLOR=' '"]
    I -- No --> V1["v_COLOR='V'<br/>Archivo por buen manejo"]
    H -- No --> J[Revisar causales]
    X1 --> J
    V1 --> J
    J --> K{¿Deficiencia notificación=1?}
    K -- Sí --> N1["v_COLOR='N'"]
    K -- No --> L{¿Deficiencia técnica=1?}
    L -- Sí --> N2["v_COLOR='N'"]
    L -- No --> M{¿Muerte titular / Nueva supervisión / Evidencia irregularidad=1?}
    M -- Sí --> X2["v_COLOR=' '"]

    G -- "PAU_ARCHIVADO / PAU_ARCHIVADO_MUERTE" --> P{¿v_CNT12>0?}
    P -- Sí --> V2["v_COLOR='V'<br/>Archivo del PAU"]
    G -- "PAU_ARCHIVADO_TFFS" --> V3["v_COLOR='V'<br/>Archivo por TFFS"]

    N1 --> Q
    N2 --> Q
    X2 --> Q
    V2 --> Q
    V3 --> Q
    M -- No --> Q

    Q{¿v_COLOR <> 'V'?}
    Q -- No --> Z([Fin: conserva Verde])
    Q -- Sí --> S{¿v_COLOR='N'?}
    S -- Sí --> T{¿Vol. injustificado >=100%<br/>o árboles inexistentes >=100%?}
    T -- Sí --> NR["v_COLOR='NR'"]
    T -- No --> Z
    NR --> Z
    S -- No --> U{¿Vol. injustificado >=100%?}
    U -- Sí --> R3["v_COLOR='R'"]
    U -- No --> W{¿Árboles inexistentes >=100%?}
    W -- Sí --> R4["v_COLOR='R'"]
    W -- No --> Z
    R3 --> Z
    R4 --> Z
