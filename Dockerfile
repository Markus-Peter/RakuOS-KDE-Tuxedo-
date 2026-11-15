# Offizielles RakuOS KDE Basis-Image von Quay.io
FROM quay.io/rakuos/rakuos-kde:latest

# 1. Offizielles Tuxedo-Repository für Fedora hinzufügen und Treiber + Control Center installieren
RUN dnf config-manager addrepo --from-repofile="https://rpm.tuxedocomputers.com/fedora/tuxedo.repo" && \
    dnf install -y tuxedo-drivers tuxedo-control-center

# 2. Virtualisierung (VMM / Virt-Manager / QEMU) und Nautilus installieren
RUN dnf install -y \
    virt-manager \
    qemu-kvm \
    libvirt \
    nautilus && \
    dnf clean all

# 3. Den Virtualisierungs-Dienst (libvirtd) automatisch beim Start aktivieren
RUN systemctl enable libvirtd
