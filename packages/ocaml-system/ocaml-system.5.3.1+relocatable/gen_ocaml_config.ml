let () =
  let exe = ".exe" in
  let ocamlc =
    let (base, suffix) =
      let s = Sys.executable_name in
      if Filename.check_suffix s exe then
        (Filename.chop_suffix s exe, exe)
      else
        (s, "") in
    base ^ "c" ^ suffix in
  if Sys.ocaml_version <> "5.3.1+relocatable" then
    (Printf.eprintf
       "ERROR: The compiler found at %s has version %s,\n\
        and this package requires 5.3.1+relocatable.\n\
        You should use e.g. 'opam switch create ocaml-system.%s' \
        instead."
       ocamlc Sys.ocaml_version Sys.ocaml_version;
     exit 1)
  else
  let ocamlc_digest = Digest.to_hex (Digest.file ocamlc) in
  let libdir =
    if Sys.command (ocamlc^" -where > ocaml-system.config") = 0 then
      let ic = open_in "ocaml-system.config" in
      let r = input_line ic in
      close_in ic;
      Sys.remove "ocaml-system.config";
      r
    else
      failwith "Bad return from 'ocamlc -where'"
  in
  let graphics = Filename.concat libdir "graphics.cmi" in
  let graphics_digest =
    if Sys.file_exists graphics then
      Digest.to_hex (Digest.file graphics)
    else
      String.make 32 '0'
  in
  let oc = open_out "ocaml-system.config" in
  Printf.fprintf oc "opam-version: \"2.0\"\n\
                     file-depends: [ [ %S %S ] [ %S %S ] ]\n\
                     variables { path: %S }\n"
    ocamlc ocamlc_digest graphics graphics_digest (Filename.dirname ocamlc);
  close_out oc
