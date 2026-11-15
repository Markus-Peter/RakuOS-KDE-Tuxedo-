# Offizielles RakuOS KDE Basis-Image von Quay.io
FROM quay.io/rakuos/rakuos-kde:latest

# 1. Offizielles Tuxedo-Repository hinzufügen und Treiber + Control Center installieren
RUN dnf config-manager addrepo --from-repofile="https://rpm.tuxedocomputers.com/fedora/tuxedo.repo" && \
    dnf install -y tuxedo-drivers tuxedo-control-center

# 2. Virtualisierung (VMM / Virt-Manager / QEMU) und Nautilus installieren
RUN dnf install -y \
    virt-manager \
    qemu-kvm \
    libvirt \
    nautilus && \
    dnf clean all

# 3. Workaround für doppelte gpg-pubkey Einträge in der RPM-Datenbank
RUN rpm -q gpg-pubkey | xargs rpm -e --allmatches || true
