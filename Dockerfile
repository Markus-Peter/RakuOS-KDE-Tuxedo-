# Offizielles RakuOS KDE Basis-Image von Quay.io
FROM quay.io/rakuos/rakuos-kde:latest

# 0. FIX für bootc-image-builder (NoReposError):
#    Fedora 45 legt .repo-Dateien nur noch in /usr/share/dnf5/repos.d ab,
#    der ISO-Depsolve im Builder liest aber ausschließlich /etc/yum.repos.d.
#    Deshalb alle vorhandenen Repo-Definitionen dorthin spiegeln.
RUN mkdir -p /etc/yum.repos.d && \
    shopt -s nullglob && \
    for f in /usr/share/dnf5/repos.d/*.repo; do \
        ln -sf "$f" "/etc/yum.repos.d/$(basename "$f")"; \
    done

# 0b. Alle vorhandenen GPG-Keys in die RPM-Datenbank importieren und
#     toten file://-GPG-Referenzen aus den Repo-Dateien entfernen.
RUN rpm --import /etc/pki/rpm-gpg/* || true && \
    find /etc/yum.repos.d /usr/share/dnf5/repos.d -name '*.repo' -exec sed -ri '/^gpgkey=file:\/\//d' {} + 2>/dev/null || true

# 1. Tuxedo-Repository: Repo-Datei mit hartgenaelter Fedora-Version schreiben,
#    Key vorladen, dann installieren.
#    HINWEIS: Falls RakuOS nicht Fedora 45 ist, '45' unten anpassen!
RUN FEDORA_VER=45 && \
    printf '[tuxedo]\nname=TUXEDO - Fedora %s - $basearch\nbaseurl=https://rpm.tuxedocomputers.com/fedora/%s/$basearch/base/\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.tuxedocomputers.com/fedora/%s/0x54840598.pub.asc\nskip_if_unavailable=False\n' "$FEDORA_VER" "$FEDORA_VER" "$FEDORA_VER" > /etc/yum.repos.d/tuxedo.repo && \
    rpm --import "https://rpm.tuxedocomputers.com/fedora/$FEDORA_VER/0x54840598.pub.asc" && \
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

# 4. Repo-Sichtbarkeit erzwingen
RUN rm -f /etc/yum.repos.d/*source*.repo && \
    ls -l /etc/yum.repos.d/
