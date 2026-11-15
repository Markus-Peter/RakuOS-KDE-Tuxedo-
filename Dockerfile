# Offizielles RakuOS KDE Basis-Image von Quay.io
FROM quay.io/rakuos/rakuos-kde:latest

# 1. Tuxedo-Treiber und Control Center über das COPR-Repository installieren
RUN dnf copr enable -y sspreitzer/tuxedo && \
    dnf install -y tuxedo-drivers tuxedo-control-center

# 2. Virtualisierung (VMM/QEMU) und Nautilus installieren
RUN dnf install -y \
    virt-manager \
    qemu-kvm \
    libvirt \
    nautilus && \
    dnf clean all

# 3. Den Virtualisierungs-Dienst (libvirtd) automatisch beim Start aktivieren
RUN systemctl enable libvirtd
