# 1. Basis-Image von RakuOS KDE verwenden
FROM ghcr.io/rakuos/rakuos:kde

# 2. Tuxedo-Treiber und Control Center über das COPR-Repository installieren
RUN dnf copr enable -y sspreitzer/tuxedo && \
    dnf install -y tuxedo-drivers tuxedo-control-center

# 3. Virtualisierung (VMM / Virt-Manager / QEMU) und den Nautilus Dateimanager installieren
RUN dnf install -y \
    virt-manager \
    qemu-kvm \
    libvirt \
    nautilus && \
    dnf clean all

# 4. Den Virtualisierungs-Dienst (libvirtd) automatisch beim Start aktivieren
RUN systemctl enable libvirtd
