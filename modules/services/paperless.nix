{

  services.paperless = {
    enable = true;
    dataDir = "/mnt/data/paperless/data";
    mediaDir = "/mnt/data/paperless/media";
    user = "xinoi";
    passwordFile = config.sops.secrets.paperless_admin_pass.path;
    settings = {
      PAPERLESS_SECRET_KEY = config.sops.secrets.paperless_secret_key.path;
      PAPERLESS_URL = "https://docs.xinoi.net";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
    };
    };
  };

}
