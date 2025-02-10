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

    initialScript = pkgs.writeText "init-ttrss.sql" ''
      CREATE USER ttrss WITH ENCRYPTED PASSWORD 'ttrss-local';
      GRANT ALL PRIVILEGES ON DATABASE ttrss TO ttrss;
    '';
  };

  services.tt-rss = {
    enable = true; 
   selfUrlPath = "http://localhost"; 
    database = {
      type = "pgsql";
      host = "localhost";
      name = "ttrss";
      user = "ttrss";
      password = "ttrss-local";
      createLocally = false;

    };

    registration.enable = true;
  };
}
