(define-module (packages postgresql-client)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages texinfo))
  

(define-public postgresql-client
(package
  (name "postgresql-client")
  (version "13.4")
  (source
     (origin
       (method url-fetch)
       (uri "http://deb.debian.org/debian/pool/main/p/postgresql-13/postgresql-13_13.4.orig.tar.bz2")
       (sha256
        (base32 "1kf0gcsrl5n25rjlvkh87aywmn28kbwvakm5c7j1qpr4j01y34za"))))
  (build-system gnu-build-system)
  (arguments `())
  (native-inputs
    `(("autoconf" ,autoconf)
      ("automake" ,automake)
      ("pkg-config" ,pkg-config)
      ("texinfo" ,texinfo)))
  (inputs `(("readline" ,readline)
	    ("zlib" ,(@ (gnu packages compression) zlib))))
  (propagated-inputs `())
  (synopsis "Front-end programs for PostgreSQL 13")
  (description "This package contains client and administrative programs for PostgreSQL: these are the interactive terminal client psql and programs for creating and removing users and databases.")
  (home-page "www.labsolns.com")
  (license license:gpl3+)))

