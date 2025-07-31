{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "json-patch";
  version = "5.9.11";

  src =
    fetchFromGitHub {
      owner = "evanphx";
      repo = "json-patch";
      rev = "v${version}";
      sha256 = "sha256-lRgz3Bw2mwQSfXvXmKUcWfexEf3YHBFy47tqWB6lzWs=";
    }
    + "/v5";

  vendorHash = "sha256-W6XVd68MS0ungMgam8jefYMVhyiN6/DB+bliFzs2rdk=";

  doCheck = false;
  subPackages = [ "cmd/json-patch" ];

  meta = with lib; {
    description = "Tool to apply RFC6902 patches and create and apply RFC7386 patches";
    homepage = "https://github.com/evanphx/json-patch/";
    license = licenses.bsd3;
    maintainers = with maintainers; [ tboerger ];
  };
}
