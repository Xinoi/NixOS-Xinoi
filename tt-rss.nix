{ config, pkgs, ...}:

{
  
  services.postgresql = {
    enable = true; 
    ensureDatabases = [ "ttrss" ];
    ensureUsers = [ 
      {
        name = "ttrss";
        ensureDBOwnership = true;
      }
    ];
  };

  services.tt-rss = {
    enable = true; 
    virtualHost = "localhost";
    database = {
      type = "pgsql";
      host = "localhost";
      name = "ttrss";
      user = "ttrss";
      password = "ttrss-local";
    };
    registration.enable = true;
  };

  services.nginx.enable = true;
}
