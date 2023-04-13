# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Import the NixOS module system.
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.supportedFilesystems = [ "ntfs" ];

  # Set your time zone.
  time.timeZone = "America/Kentucky/Louisville";
  time.hardwareClockInLocalTime = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  networking = {
    wireless.enable = true;
    useDHCP = true;
    hostName = "nixos";
    wireless.userControlled.enable = true;
    networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  # Fonts
  fonts = {
	#fontconfig = {
	#  antialias = true;
	#  subpixel = {
	#    #rbga =  "none";
	#    lcdfilter = "none";
	#  };
	#};
    fonts = with pkgs; [
      fira-code
	    fira-code-symbols
      mononoki
      helvetica-neue-lt-std
      open-sans
      comic-mono
      hackgen-font
      hack-font
	    openmoji-color
	    font-awesome
	    jetbrains-mono
      comic-neue
    ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkbOptions in tty.
  };
  
  # Monitor script
  systemd.services.monitor_script = {
    enable = true;
    path = [ pkgs.bash pkgs.nix pkgs.xorg.xrandr ];
    description = "Auto switching betweeen internal and external monitors.";
    wants = [ "display-manager.service" ];
    requires = [ "display-manager.service" ];
    after = [ "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "roman";
      Environment = "DISPLAY=:0 XAUTHORITY=/home/roman/.Xauthority XDG_RUNTIME_DIR=/run/user/1000";
      ExecStart = "${pkgs.writers.writeBash "external_monitor_script" ''
          #!/usr/bin/env bash 

          IN=$(xrandr | grep "eDP" | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
          EXT=$(xrandr | grep "HDMI" | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")

          export DISPLAY=:0
          export XAUTHORITY=/home/roman/.Xauthority
          export XDG_RUNTIME_DIR=/run/user/1000
          xrandr --display $DISPLAY --auto
          if (xrandr | grep "$EXT disconnected"); then
              xrandr --output $EXT --off --output $IN --auto --dpi 120
          else
              xrandr --output $IN --off --output $EXT --auto --mode 3840x2160 --rate 144 --dpi 100
          fi
      ''}";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Allow packages with non-free license
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  services.picom = {
    enable = true;
    backend = "xrender";
    #shadow = true;
    #shadowExclude = [
    #  "name = 'Notification'"
    #];
    settings = {
      vsync = true;
    };
  };
  # Enable the X11 windowing system.

  services.xserver = {
    enable = true;
    layout = "us";
	  autoRepeatDelay = 250;
	  autoRepeatInterval = 25;
	  libinput.touchpad.naturalScrolling = true;
    libinput.enable = true;  # Enable touchpad support (enabled default in most desktopManagers).
	  displayManager.sddm.enable = true;
	  displayManager.sddm.theme = "plasma-chili";
    # 141 for edp, 113 for 4k
    #displayManager.sessionCommands = ''

    #   ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
    #      Xft.dpi: 113 
    #      Xcursor.theme: Adwaita
    #      Xcursor.size: 64
    #   EOF
    #   '';
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.xmonad.config = builtins.readFile "/home/roman/.config/xmonad/xmonad.hs";
    
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
		    rofi
        #dmenu
      ];
    };
  };
  
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  # Enable hidpi.
  hardware.video.hidpi.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.roman = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" "disk"
      "audio" "video"
      "systemd-journal"
    ]; # Enable ‘sudo’ for the user.
  };

  # %E{ID_FS_LABEL_ENC}
  # Two rules: automount removable media and autoswitching between ext/internal monitors.
  boot.kernelModules = [ "drm" ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{ID_FS_USAGE}=="filesystem", RUN{program}+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /media"       
    ACTION=="change", SUBSYSTEM=="drm", ENV{HOTPLUG}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start monitor_script.service"
  '';

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    firefox
    chromium
    tor-browser-bundle-bin
    git 
    ranger
    xfce.thunar
	  alacritty
    #wlr-randr
    haskellPackages.xmonad-contrib
    haskellPackages.xmobar
    taffybar #TODO
	  xorg.xbacklight
    xmonad-with-packages
    jetbrains.clion
    vscodium
    polybar
    vlc
	  flameshot
	  tdesktop
    signal-desktop
    slack
	  rustup
	  rustc
    rust-analyzer
    clippy
    ghc
	  gcc
	  gdb
    scala
    python3
    #python.pkgs.pip
    hexdump
    iaito
    #toybox
    killall
    htop
    zoom-us
    libinput
	  discord
	  spotify
	  libreoffice
	  neofetch
    lxappearance
    gImageReader
    vimix-gtk-themes
    vimix-icon-theme
    zip
	  xclip
    dzen2
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.light.enable = true;
  programs.vim.defaultEditor = true;
  #programs.sway.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall = {
    enable = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
  system.autoUpgrade = {
    enable = true;
    channel = https://nixos.org/channels/nixos-unstable;
  };
}
