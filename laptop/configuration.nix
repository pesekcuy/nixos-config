# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-".device = "/dev/disk/by-uuid/";
  networking.hostName = "panasdingin"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  boot.kernelParams = [ "quiet" ];
  fileSystems."/".options = [ "discard" "noatime" "nodiratime" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "Asia/Jakarta";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "id_ID.UTF-8";
    LC_IDENTIFICATION = "id_ID.UTF-8";
    LC_MEASUREMENT = "id_ID.UTF-8";
    LC_MONETARY = "id_ID.UTF-8";
    LC_NAME = "id_ID.UTF-8";
    LC_NUMERIC = "id_ID.UTF-8";
    LC_PAPER = "id_ID.UTF-8";
    LC_TELEPHONE = "id_ID.UTF-8";
    LC_TIME = "id_ID.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    autoLogin.user = "pesekcuy";
    defaultSession = "plasma";
  };
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
    khelpcenter
    krdp
    plasma-browser-integration
    print-manager
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "jp";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "jp106";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplip ];

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pesekcuy = {
    isNormalUser = true;
    description = "Adi Nugroho";
    extraGroups = [ "networkmanager" "wheel" "scanner" "lp" "adbusers" "libvirtd" ];
    packages = with pkgs; [
      adwaita-icon-theme
      (chromium.override {
        commandLineArgs = [
          "--enable-features=VaapiVideoDecodeLinuxGL"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
        enableWideVine = true;
      })
      ffmpeg-full
      firefox
      gimp
      git
      gnome.gnome-boxes
      inkscape
      kdePackages.kcalc
      kdePackages.skanlite
      kid3
      libreoffice-qt
      mpv
      opustags
      python3
      qbittorrent
      tigervnc
      yt-dlp
    ];
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    usbutils
    pciutils
    unrar
    gptfdisk
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.fwupd.enable = true;

  programs.adb.enable = true;
  programs.dconf.enable = true;

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Samba
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  networking.firewall.allowedTCPPorts = [
    5357 # wsdd
  ];
  networking.firewall.allowedUDPPorts = [
    3702 # wsdd
  ];
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = smbnix
      netbios name = smbnix
      security = user
      #use sendfile = yes
      #max protocol = smb2
      # note: localhost is the ipv6 localhost ::1
      hosts allow = 192.168.0. 192.168.1. 192.168.122. 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      panasdingin = {
        path = "/home/pesekcuy/";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "pesekcuy";
        "force group" = "users";
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  services.samba.openFirewall = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
  ];
  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif" ];
    sansSerif = [ "Noto Sans" ];
    monospace = [ "Hack" ];
  };

  # Integrated GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ intel-media-driver ];
    extraPackages32 = with pkgs.driversi686Linux; [ intel-media-driver ];
  };

  # Power management
  services.thermald.enable = true;
  powerManagement.powertop.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
