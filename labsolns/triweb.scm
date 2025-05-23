(define-module (labsolns triweb)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages guile)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages linux)
  #:use-module (labsolns limsn)
  #:use-module (labsolns conmanv6)
  #:use-module (labsolns ebbot)
  #:use-module (labsolns artanis-122)
  #:use-module (json)

  )

(define-public triweb
             (let ((commit "1624463e1b874ce9085e63a5fe2effb294172b18")
        (revision "4"))
(package
  (name "triweb")
  (version (string-append "0.1." (string-take commit 7)))
  (source (origin
           (method git-fetch)
                (uri (git-reference
                      (url "https://github.com/mbcladwell/triweb")
                      (commit commit)))
                        (file-name (git-file-name name version))
                (sha256 
             (base32 "0xa9c44vsgybncd2d3hfb7yaxsaxh9mixgrfg4a32wkda5fscsfa"))))
  (build-system guile-build-system)
  
  (native-inputs
    `(("guile" ,guile-3.0)))
  (propagated-inputs `(("bash" ,bash)("limsn" ,limsn)("conman" ,conmanv6)("ebbot" ,ebbot)("artanis" ,artanis-122)))
  (synopsis "AWS setup providing limsn, artanis, babweb, and conman")
  (description "AWS setup providing limsn, artanis, babweb, and conman")
  (home-page "www.labsolns.com")
  (license license:gpl3+))))




