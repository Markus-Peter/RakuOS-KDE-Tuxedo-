# Offizielles RakuOS KDE Basis-Image von Quay.io
FROM quay.io/rakuos/rakuos-kde:latest

# 0. FIX für bootc-image-builder (NoReposError):
#    Fedora 45 legt .repo-Dateien nur noch in /usr/share/dnf5/repos.d ab,
#    der ISO-Depsolve im Builder liest aber ausschließlich /etc/yum.repos.d.
#    Deshalb alle vorhandenen Repo-Definitionen dorthin spiegeln.
RUN mkdir -p /etc/yum.repos.d && \
    for f in /usr/share/dnf5/repos.d/*.repo; do \
        [ -e "$f" ] && ln -sf "$f" "/etc/yum.repos.d/$(basename "$f")"; \
    done; \
    if [ ! -f /etc/yum.repos.d/fedora.repo ]; then \
        printf '[fedora]\nname=Fedora $releasever - $basearch\nmetalink=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch\nenabled=1\nmetadata_expire=7d\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch\nskip_if_unavailable=False\n\n[fedora-updates]\nname=Fedora $releasever - $basearch - Updates\nmetalink=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f$releasever&arch=$basearch\nenabled=1\nmetadata_expire=6h\ngpgcheck=1\ngpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch\nskip_if_unavailable=False\n' > /etc/yum.repos.d/fedora.repo; \
    fi

# 1. Tuxedo-Repository hinzufügen, Key holen und Treiber installieren
RUN dnf config-manager addrepo --from-repofile="https://rpm.tuxedocomputers.com/fedora/tuxedo.repo" && \
    mkdir -p /etc/pki/rpm-gpg && \
    curl -fsSL https://rpm.tuxedocomputers.com/fedora/45/0x54840598.pub.asc -o /etc/pki/rpm-gpg/RPM-GPG-KEY-tuxedo && \
    dnf install -y tuxedo-drivers tuxedo-control-center && \
    dnf clean all

# 2. Virtualisierung (VMM / Virt-Manager / QEMU) und Nautilus installieren
RUN dnf install -y \
    virt-manager \
    qemu-kvm \
    libvirt \
    nautilus && \
    dnf clean all

# 3. Workaround für doppelte gpg-pubkey Einträge in der RPM-Datenbank
RUN rpm -q gpg-pubkey | xargs rpm -e --allmatches || true

# 4. Repo-Sichtbarkeit erzwingen: Nach 'dnf clean all' aufräumen und
#    sicherstellen, dass beim ISO-Build genau diese Repos gefunden werden
RUN rm -f /etc/yum.repos.d/*source*.repo && \
    ls -l /etc/yum.repos.d/
