# Basis-Image: RakuOS KDE
# (Hinweis: Prüfe kurz auf der RakuOS-Seite, ob der Name genau so stimmt, z.B. ghcr.io/rakuos/rakuos-kde:latest)
FROM ghcr.io/rakuos/rakuos-kde:latest

# 1. Tuxedo Repository aktivieren und Treiber + Control Center installieren
RUN dnf copr enable -y sspreitzer/tuxedo && \
    dnf install -y tuxedo-drivers tuxedo-control-center

# 2. Virtualisierung (VMM / Virt-Manager + KVM) und Nautilus installieren
RUN dnf install -y \
    virt-manager \
    qemu-kvm \
    libvirt \
    nautilus && \
    dnf clean all

# 3. Virtualisierungs-Dienst automatisch beim Systemstart aktivieren
RUN systemctl enable libvirtd
