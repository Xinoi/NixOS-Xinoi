{
  environment.etc."paperless-admin-pass".text = "admin";
  services.paperless = {
    enable = true;
    dataDir = "/mnt/data/paperless/data";
    mediaDir = "/mnt/data/paperless/media";
    address = "0.0.0.0";
    user = "xinoi";
    settings = {
      PAPERLESS_URL = "https://docs.xinoi.net";
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_OCR_USER_ARGS = {
        optimize = 1;
        pdfa_image_compression = "lossless";
      };
    };
  };
}
