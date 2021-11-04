(define-module (labsolns lnpg)
  #:use-module (guix packages)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix download)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages databases)
  #:use-module (labsolns postgresql-client)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages maths)
   #:use-module (guix git-download)
  #:use-module (gnu packages texinfo))
  
(define-public lnpg
(package
  (name "lnpg")
  (version "0.1")
   (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "http://github.com/mbcladwell/labsolns/blob/main/labsolns/lnpg-0.1.tar.gz")
             (branch "main")
             (commit version)))
       (file-name (git-file-name name version))
       (sha256
        (base32 "193pi2pl22hcb9c4fvjswd8my3i2g1k1g1w9n35kn3cn8ip3sqph"))))
  (build-system gnu-build-system)
  (arguments `(#:tests? #false ; there are none
			#:phases (modify-phases %standard-phases
    		       (add-after 'unpack 'patch-prefix
			       (lambda* (#:key inputs outputs #:allow-other-keys)
				 (substitute* '("scripts/install-pg.sh"
						"lnpg/lnpg.scm")
						(("abcdefgh")
						(assoc-ref outputs "out" )) )
					#t))		    
		       (add-before 'install 'make-scripts-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/scripts"))
					   (bin-dir (string-append out "/bin"))
					   (dummy (install-file "scripts/install-pg.sh" bin-dir))
					   (dummy (mkdir-p scripts-dir)))            				       
				       (copy-recursively "./scripts" scripts-dir)
				       #t)))
		       (add-after 'install 'wrap-install-pg
				  (lambda* (#:key inputs outputs #:allow-other-keys)
				    (let* ((out (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (dummy (chmod (string-append out "/bin/install-pg.sh") #o555 ))) ;;read execute, no write
				      (wrap-program (string-append out "/bin/install-pg.sh")
						    `( "PATH" ":" prefix  (,bin-dir) ))		    
				      #t)))	       
		       )))
  (native-inputs
    `(("autoconf" ,autoconf)
      ("automake" ,automake)
      ("pkg-config" ,pkg-config)
      ("texinfo" ,texinfo)    
     ))
  (inputs `(("guile" ,guile-3.0)
	    ("gnuplot" ,gnuplot)))
  (propagated-inputs `( ("artanis" ,artanis)
			("postgresql" ,postgresql)
			("postgresql-client" ,postgresql-client)
			))
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+)))

