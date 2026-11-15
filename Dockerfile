# Offizielles RakuOS KDE Basis-Image von Quay.io
FROM quay.io/rakuos/rakuos-kde:latest

# 0. Repo-Spiegelung nach /etc/yum.repos.d (fuer bootc-image-builder)
RUN mkdir -p /etc/yum.repos.d && \
    shopt -s nullglob && \
    for f in /usr/share/dnf5/repos.d/*.repo; do \
        ln -sf "$f" "/etc/yum.repos.d/$(basename "$f")"; \
    done

# 0b. GPG-Keys vorladen, tote file://-Pfade entfernen
RUN rpm --import /etc/pki/rpm-gpg/* || true && \
    find /etc/yum.repos.d /usr/share/dnf5/repos.d -name '*.repo' -exec sed -ri '/^gpgkey=file:\/\//d' {} + 2>/dev/null || true

# 1. Tuxedo-Repo (hartgenaelte Fedora-Version)
RUN FEDORA_VER=45 && \
    printf '[tuxedo]\nname=TUXEDO - Fedora %s - $basearch\nbaseurl=https://rpm.tuxedocomputers.com/fedora/%s/$basearch/base/\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.tuxedocomputers.com/fedora/%s/0x54840598.pub.asc\nskip_if_unavailable=False\n' "$FEDORA_VER" "$FEDORA_VER" "$FEDORA_VER" > /etc/yum.repos.d/tuxedo.repo && \
    rpm --import "https://rpm.tuxedocomputers.com/fedora/$FEDORA_VER/0x54840598.pub.asc" && \
    dnf install -y tuxedo-drivers tuxedo-control-center

# 2. Virtualisierung + Nautilus
RUN dnf install -y virt-manager qemu-kvm libvirt nautilus

# === DIAGNOSE ( temporaer, nur um das ISO-Problem zu verstehen ) ===
RUN echo '--- which dnf/rum/rpm-ostree ---'; \
    command -v dnf dnf5 rum rpm-ostree rpm || true; \
    echo '--- dnf is symlink to? ---'; ls -l "$(command -v dnf)" || true; \
    echo '--- repo dirs ---'; ls -la /etc/yum.repos.d /usr/share/dnf5/repos.d /etc/rakudos* /etc/rakuos* /etc/rum* 2>/dev/null || true; \
    echo '--- all repo files anywhere ---'; find / -name '*.repo' -not -path '/proc/*' 2>/dev/null; \
    echo '--- can dnf see grub2-tools? ---'; dnf list available grub2-tools kernel anaconda 2>&1 | head -30; \
    echo '--- ostree deployment state ---'; ostree admin status 2>&1 | head; cat /run/ostree-booted 2>/dev/null; ls -la /sysroot 2>/dev/null | head; \
    echo '--- rpm db pkg count ---'; rpm -qa | wc -l
# === ENDE DIAGNOSE ===

# 3. Workaround doppelte gpg-pubkey Eintraege
RUN rpm -q gpg-pubkey | xargs rpm -e --allmatches || true

# 4. Aufraeumen
RUN rm -f /etc/yum.repos.d/*source*.repo && ls -l /etc/yum.repos.d/
